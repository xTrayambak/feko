## Feko's backend service
##
## Copyright (C) 2025 Trayambak Rai
import std/[atomics, json, options, os, random, strutils, times]
import pkg/mummy, pkg/mummy/routers
import pkg/[chronicles, kiwi, jsony, shakar, toml_serialization, unicody, uuid4]
import ./[argparser, config]

logScope:
  topics = "backend"

const
  ## All endpoint paths
  NewPasteEndpoint* = "/paste/new"
  GetPasteEndpoint* = "/paste/get"

type
  ## /paste/new payload struct
  NewPasteRequest* = object
    content*: string
      ## The actual paste content. This is verified by the backend to be valid UTF-8.
    ttl*: Option[float]
      ## How many seconds until this paste is deleted? (If not provided, the paste is eternal)
    password*: Option[string] ## The password to this paste, if it needs to be protected.

  ## Internal paste data structure
  Paste* = object
    content*: string
    bornAt*: float
    diesAt*: Option[float]
    password*: Option[string]
    views*: uint64

  SlugSearchError* = object of ValueError
  SlugNotFound* = object of SlugSearchError
  SlugPasswordRequired* = object of SlugSearchError
  SlugInvalidPassword* = object of SlugSearchError

  SlugCreateError* = object of ValueError
  MalformedContent* = object of SlugCreateError
  ContentTooLarge* = object of SlugCreateError

var conf: pointer
var pasteStore: pointer

proc generateSlug(
    config: Config, store: kiwi.Store, content: string, nRecurse: uint8 = 0
): string =
  let state = store.state

  template verify(slug: string) =
    if state.contains(slug):
      if nRecurse > 250'u8:
        raise
          newException(ValueError, "Failed to generate unique slug in 250 attempts!")

      return generateSlug(config, store, content, nRecurse + 1)
    else:
      return ensureMove(slug)

  case config.backend.slugAlgorithm
  of SlugAlgorithm.AlphaNum:
    let chars = Letters + Digits
    var slug = newStringOfCap(8)
    for i in 0 .. 8:
      slug &= sample(chars)

    verify(slug)
  of SlugAlgorithm.UUID:
    verify($uuid4())

proc addNewPaste(data: NewPasteRequest, config: Config): string {.gcsafe.} =
  if validateUtf8(data.content) != -1:
    raise newException(
      MalformedContent, "The content for this paste cannot be proven to be valid UTF-8."
    )

  if data.content.len.uint64 > config.backend.maxPasteSize:
    raise newException(
      ContentTooLarge,
      "This paste's size (" & $data.content.len &
        " chars) exceeds the limit imposed by the server (" &
        $config.backend.maxPasteSize & " chars)",
    )

  let store = cast[ptr kiwi.Store](pasteStore)[]
  let slug = generateSlug(config, store, data.content)

  debug "Adding new paste to store",
    slug = slug, contentSize = data.content.len, password = data.password

  let birthTime = epochTime()
  store[slug] =
    $(
      %*Paste(
        content: data.content,
        bornAt: birthTime,
        diesAt:
          if *data.ttl:
            some(birthTime + &data.ttl)
          else:
            none(float),
        password: data.password,
      )
    )

  slug

proc getPaste(slug: string, password: Option[string]): Paste =
  var store = cast[ptr kiwi.Store](pasteStore)[]

  for pasteSlug in store:
    let (slugKey, slugValue) = pasteSlug
    if slugKey != slug:
      continue

    var paste = fromJson(slugValue, Paste)
    if *paste.password:
      if !password:
        raise newException(
          SlugPasswordRequired,
          "The paste associated with the slug is password-protected.",
        )

      if &password != &paste.password:
        raise newException(
          SlugInvalidPassword, "An incorrect password was provided to access the paste."
        )

    inc paste.views
    store[slugKey] = $(%*paste)

    return paste

  raise newException(SlugNotFound, "Failed to find any paste with slug: " & slug)

proc into*[T: object](req: Request, typ: typedesc[T]): Option[T] =
  try:
    return some(fromJson(req.body, T))
  except jsony.JsonError as exc:
    warn "Cannot parse body as valid JSON", err = exc.msg
    return none(T)

template invalidValue(request: Request, endpoint: string, meth: string, msg: string) =
  var headers: HttpHeaders
  headers["Content-Type"] = "application/json"

  debug "Returning einval as response", path = endpoint, `method` = meth, message = msg

  request.respond(
    statusCode = 400,
    body = "{ \"message\": \"$1\" }" % [msg],
    headers = ensureMove(headers),
  )
  return

proc success(request: Request, endpoint: string, meth: string, body: string) =
  var headers: HttpHeaders
  headers["Content-Type"] = "application/json"

  debug "Returning success as response", path = endpoint, `method` = meth, output = body

  request.respond(statusCode = 200, body = body, headers = ensureMove(headers))

proc createNewPaste(request: Request) {.gcsafe.} =
  let struct = request.into(NewPasteRequest)
  if !struct:
    invalidValue(request, NewPasteEndpoint, "POST", "Invalid JSON struct provided")

  var headers: HttpHeaders
  headers["Content-Type"] = "application/json"

  try:
    let slug = addNewPaste(&struct, cast[ptr Config](conf)[])

    success(
      request,
      NewPasteEndpoint,
      "POST",
      """
{
  "slug": "$1"
}
    """ % [slug],
    )
  except MalformedContent as exc:
    request.respond(
      422,
      headers = ensureMove(headers),
      body =
        """{
  "error": "$1"
}    """ % [exc.msg],
    )
  except ContentTooLarge as exc:
    request.respond(
      413,
      headers = ensureMove(headers),
      body =
        """{
  "error": "$1"
}    """ % [exc.msg],
    )

proc getPasteData(request: Request) {.gcsafe.} =
  if not request.queryParams.contains("slug") or request.queryParams["slug"].len < 1:
    invalidValue(request, GetPasteEndpoint, "GET", "No `slug` query parameter provided")

  let slug = request.queryParams["slug"]
  var headers: HttpHeaders
  headers["Content-Type"] = "application/json"

  try:
    let paste = getPaste(
      slug,
      if request.headers.contains("Authorization"):
        some(request.headers["Authorization"])
      else:
        none(string),
    )

    request.respond(200, headers = headers, body = $(%*paste))
  except SlugNotFound as exc:
    request.respond(
      404,
      headers = ensureMove(headers),
      body =
        """{
  "error": "$1"
}""" % [exc.msg],
    )
  except SlugPasswordRequired as exc:
    request.respond(
      401,
      headers = ensureMove(headers),
      body =
        """{
  "error": "$1"
}""" % [exc.msg],
    )
  except SlugInvalidPassword as exc:
    request.respond(
      403,
      headers = ensureMove(headers),
      body =
        """{
  "error": "$1"
}""" % [exc.msg],
    )

proc attachRouterPaths(router: var Router) =
  info "Attaching API paths to router"

  router.post(NewPasteEndpoint, createNewPaste)
  router.get(GetPasteEndpoint, getPasteData)

proc loadPasteStore(input: argparser.Input): kiwi.Store =
  let path =
    if *input.flag("paste-store"):
      &input.flag("paste-store")
    else:
      getCurrentDir() / "pastes.kw"

  debug "Loading pastes key-value store", path = path

  return loadStore(path)

proc main() {.inline, sideEffect.} =
  let args = parseInput()
  var configStruct = loadConfig(
    if *args.flag("config"):
      &args.flag("config")
    else:
      config.DefaultConfigPath
  )

  var store = loadPasteStore(args)
  store.flushFrequency = configStruct.store.flushFrequency

  # FIXME: This is an ugly hack to an ugly problem.
  # I'm going off of the assumption here that since both
  # of these are backed by the RC, they won't randomly decide
  # to get freed.
  pasteStore = addr(store)
  conf = addr(configStruct)

  var router: Router
  attachRouterPaths(router)

  var server = newServer(ensureMove(router))

  info "feko's backend is now about to start serving",
    address = configStruct.backend.address, port = configStruct.backend.port

  randomize()
  server.serve(Port(configStruct.backend.port), configStruct.backend.address)

when isMainModule:
  main()
