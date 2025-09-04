## feko's frontend service
##
## Copyright (C) 2025 Trayambak Rai
import pkg/prologue, pkg/prologue/middlewares/staticfile
import pkg/karax/vdom
import pkg/shakar
import frontend/[home, create_paste, view_paste]
import ./[argparser, config]

proc main() {.inline.} =
  let input = parseInput()
  var configStruct = config.loadConfig(
    if *input.flag("config"):
      &input.flag("config")
    else:
      config.DefaultConfigPath
  )
  create_paste.conf = configStruct.addr
  view_paste.conf = configStruct.addr

  var app = newApp(
    newSettings(
      port = Port(configStruct.frontend.port),
      address = configStruct.frontend.address,
      debug = not defined(release),
    )
  )

  app.use(staticFileMiddleware("static"))
  app.addRoute("/unlock-paste", unlockPastePage)
  app.addRoute("/p/{slug}", viewPastePage)
  app.addRoute("/create-paste", createPastePage)
  app.addRoute("/", homePage)
  app.run()

when isMainModule:
  main()
