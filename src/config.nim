## Configuration routines
##
## Copyright (C) 2025 Trayambak Rai
import std/[os, strutils]
import pkg/[chronicles, toml_serialization, shakar]

type
  SlugAlgorithm* {.pure, size: sizeof(uint8).} = enum
    AlphaNum = "alphanum"
    UUID = "uuid"

  BackendConfig* = object
    port*: uint16
    address*: string
    slug_algorithm*: SlugAlgorithm
    max_paste_size*: uint64

  StoreConfig* = object
    flush_frequency*: float

  FrontendConfig* = object
    port*: uint16
    address*: string

  Config* = object
    backend*: BackendConfig
    frontend*: FrontendConfig
    store*: StoreConfig

const DefaultConfigPath* {.strdefine.} =
  when defined(release):
    "$1" / ".config" / "feko" / "config.toml"
  else:
    "$2" / "config.toml"

let defaultConfiguration = Config(
  backend: BackendConfig(port: 8090, address: "localhost", maxPasteSize: 6000),
  frontend: FrontendConfig(port: 8091, address: "localhost"),
)

proc loadConfig*(path: string = DefaultConfigPath): Config =
  let path = path % [getHomeDir(), getCurrentDir()]

  debug "Loading configuration", path = path

  if not fileExists(path):
    info "Cannot find configuration for feko, using default builtin configuration."
    return defaultConfiguration
  else:
    try:
      return Toml.decode(readFile(path), Config)
    except toml_serialization.TomlReaderError as exc:
      error "Failed to decode configuration file for feko; using default builtin configuration.",
        err = exc.formatMsg(path)
      return defaultConfiguration

  unreachable
