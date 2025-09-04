import pkg/[prologue], pkg/karax/[karaxdsl, vdom]
import ../meta

proc renderHomepage(): string =
  let vnode = buildHtml(html):
    head:
      title:
        text "feko"

      link(rel = "preconnect", href = "https://fonts.googleapis.com")
      link(rel = "preconnect", href = "https://fonts.gstatic.com")
      link(
        href =
          "https://fonts.googleapis.com/css2?family=Source+Code+Pro:ital,wght@0,200..900;1,200..900&display=swap",
        rel = "stylesheet",
      )
      link(
        rel = "stylesheet",
        href =
          "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css",
      )
      link(rel = "stylesheet", href = "/static/style.css")

    body:
      form(action = "/create-paste", `method` = "get"):
        textarea(
          name = "content", placeholder = "Start typing here", spellcheck = "false"
        )

        tdiv(class = "option-palette"):
          button(`type` = "submit", title = "Create new paste"):
            italic(class = "fas fa-plus")

          br()
          italic(class = "fas fa-lock")
          input(
            `type` = "password",
            name = "password",
            placeholder = "Password (Optional)",
            size = "20",
          )

          p(class = "powered-by-txt"):
            text "Powered by "
            a(href = RepoUrl):
              text "feko"

  $vnode

proc homePage*(ctx: Context) {.async.} =
  resp htmlResponse(renderHomepage())
