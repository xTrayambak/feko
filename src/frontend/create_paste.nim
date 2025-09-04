import std/[httpclient, strutils, tables]
import pkg/prologue, pkg/pretty, pkg/shakar
import pkg/karax/[karaxdsl, vdom]
import ../config

proc renderCreatePastePage(msgOrRedirect: string, failed: bool): string =
  let vnode = buildHtml(html):
    head:
      title:
        text "Feko"

    body:
      if failed:
        h1:
          text "Failed to create new paste"
        h2:
          text msgOrRedirect
      else:
        h1:
          text "Paste has been created successfully!"

        h2:
          strong:
            text "/p/" & msgOrRedirect

  $vnode

var conf*: pointer # FIXME: please fix this I'm about to fucking jump off of a cliff

proc createPastePage*(ctx: Context) {.async.} =
  let content = ctx.getQueryParamsOption("content")
  if !content:
    resp htmlResponse(renderCreatePastePage("No content was specified.", true))

  let password = ctx.getQueryParamsOption("password")
  if !password:
    resp htmlResponse(renderCreatePastePage("No password was specified.", true))

  let client = newAsyncHttpClient()
  let conf = cast[ptr config.Config](conf)
  var data: Table[string, string]
  data["content"] = &content

  if *password and len(&password) > 0:
    data["password"] = &password

  let resp = await client.post(
    "http://" & conf.backend.address & ':' & $conf.backend.port & "/paste/new",
    body = $(%*data),
  )
  let bodyStr = await resp.body()
  if resp.code.int == 200:
    let body = parseJson(bodyStr)
    let slug = body["slug"].getStr()

    resp redirect("/p/" & slug)
  else:
    let err = parseJson(bodyStr)
    resp htmlResponse(
      renderCreatePastePage("An error occurred: " & err["error"].getStr(), true)
    )
