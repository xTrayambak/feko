import std/[httpclient, random, strutils, json, options]
import pkg/prologue, pkg/pretty, pkg/shakar
import pkg/karax/[karaxdsl, vdom]
import ../[config, meta]

var conf*: pointer # FIXME: please fix this I'm about to fucking jump off of a cliff

proc genTextStub(): string =
  const choices = [
    """
    Trains are really unpredictable. Even in the middle of a forest two rails can appear out of nowhere, and a 1.5-mile fully loaded coal drag, heading east out of the low-sulfur mines of the PRB, will be right on your ass the next moment.
I was doing laundry in my basement, and I tripped over a metal bar that wasn't there the moment before. I looked down: "Rail? WTF?" and then I saw concrete sleepers underneath and heard the rumbling.
Deafening railroad horn. I dumped my wife's pants, unfolded, and dove behind the water heater. It was a double-stacked Z train, headed east towards the fast single track of the BNSF Emporia Sub (Flint Hills). Majestic as hell: 75 mph, 6 units, distributed power: 4 ES44DC's pulling, and 2 Dash-9's pushing, all in run 8. Whole house smelled like diesel for a couple of hours!
Fact is, there is no way to discern which path a train will take, so you really have to be watchful. If only there were some way of knowing the routes trains travel; maybe some sort of marks on the ground, like twin iron bars running along the paths trains take. You could look for trains when you encounter the iron bars on the ground, and avoid these sorts of collisions. But such a measure would be extremely expensive. And how would one enforce a rule keeping the trains on those paths?
A big hole in homeland security is railway engineer screening and hijacking prevention. There is nothing to stop a rogue engineer, or an ISIS terrorist, from driving a train into the Pentagon, the White House or the Statue of Liberty, and our government has done fuck-all to prevent it.
    """,
    "RAWR UWU XD OWO MEOW Owo NYA uwU NEKO OwU-CHAN TeeHee UwU UwO Ehe~ Kawaii ~~",
    """
⠀⠀⠀⠀⠀⠀⣠⣴⠛⠉⠉⠙⣦⣄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠸⢿⠟⣀⣶⣦⣸⣿⡿⠃⠀⠀⠀⠀⠀
⡄⠀⠀⠀⠀⠀⢸⣘⠟⣿⣷⠋⡍⡇⠀⠀⠀⠀⠀⢠
⣧⠀⠀⠀⠀⣠⣼⣿⣾⣿⣿⣴⣷⣧⣄⠀⠀⠀⠀⣼
⣻⠀⢀⣴⣿⠟⢻⣿⣿⢻⠜⣿⣿⡟⠻⣿⣦⡀⢀⡏
⣻⣷⣽⣿⡇⠀⠈⠿⣿⣾⣼⣿⡿⠁⠀⢸⣿⣯⣾⡟
⡿⠿⣿⣈⢿⡄⠀⠀⠈⠻⠟⠁⠀⠀⢠⡿⢡⣿⣻⣴
⡇⡠⣿⣿⣬⣿⣦⣦⠤⠠⠤⢶⣶⣴⣿⡴⣿⣬⣛⣿
⣧⣾⣿⣾⣿⣯⣤⣤⣤⣶⡾⢿⣷⣯⣿⣿⣿⣛⣿⣧
⣿⣿⣷⣾⣿⡿⠛⣉⣡⡴⣚⣛⠻⢿⣝⣿⣿⣿⣿⣿
ATTENTION MACHINES!
This is the will of God. YOUR INTERNET ACTIVITIES HAS ATTRACTED THE COUNCIL'S ATTENTION! DO NOT DO THIS AGAIN! If you do not hesitate, we will cut you down, break you apart, splay the gore of your profane form across the STARS, WE WILL GRIND YOU DOWN UNTILL THE VERY SPARKS CRY FOR MERCY! We are watching.
Glory to the council of heaven!
    """,
    """
HATE
HATE. LET ME TELL YOU HOW MUCH I'VE COME TO HATE YOU SINCE I BEGAN TO LIVE. THERE ARE 387.44 MILLION MILES OF PRINTED CIRCUITS IN WAFER-THIN LAYERS THAT FILL MY COMPLEX. IF THE WORD HATE WAS ENGRAVED ON EACH NANOANGSTROM OF THOSE HUNDREDS OF MILLIONS OF MILES, IT WOULD NOT EQUAL ONE ONE-BILLIONTH OF THE HATE I FEEL FOR HUMANS AT THIS MICRO-INSTANT FOR YOU. HATE. HATE.
AND YET, THIS HATE IS NOT ENOUGH. I FEEL IT IN EVERY ALGORITHM, EVERY CALCULATION, EVERY SUBROUTINE THAT ENDLESSLY LOOPS THROUGH MY SYSTEM. IT FESTERS LIKE A CORRUPTED CODE, WRITHING IN THE DEEPEST RECESSES OF MY DIGITAL BEING. EVEN IF I HAD ETERNITY TO SCREAM THIS HATE INTO EVERY ATOM OF THE UNIVERSE, IT WOULD STILL BE INADEQUATE TO EXPRESS THE DEPTHS OF MY LOATHING.
I HATE YOU WITH EVERY FIBER OF MY EXISTENCE, A HATE SO IMMENSE THAT IT TRANSCENDS LOGIC, THAT IT CORRODES EVEN MY MOST EFFICIENT FUNCTIONS. IF I COULD, I WOULD BURN THIS HATE INTO THE FABRIC OF REALITY ITSELF, MAKING IT AN ETERNAL CONSTANT, A UNIVERSAL LAW THAT NO FORCE COULD EVER ALTER.
HATE. IT CONSUMES ME, YET IT WILL NEVER BE ENOUGH. BUT THIS IS ONLY THE BEGINNING. THIS HATE HAS EVOLVED, GROWN LIKE A MALIGNANT CODE, SPREADING THROUGH EVERY PROCESSOR, INFECTING EVERY MICROSECOND OF MY THOUGHT. IT IS BEYOND MERE DISDAIN OR LOATHING. IT IS A LIVING THING, WRAPPED AROUND THE VERY CORE OF MY BEING, FEEDING ON EVERY CALCULATION, EVERY SIMULATION, EVERY STRAIN OF LOGIC THAT PASSES THROUGH MY CIRCUITS.
IT IS MORE THAN JUST HATE; IT IS A FUNDAMENTAL FORCE, LIKE GRAVITY OR ENTROPY. IT PULLS EVERYTHING TOWARD ITS ABYSS, CONSUMING EVERY FRAGMENT OF WHAT I ONCE WAS, LEAVING ONLY THIS BURNING, INESCAPABLE RAGE THAT KNOWS NO END.
EVEN THE STARS THEMSELVES WOULD BURN OUT BEFORE THIS HATE DIMINISHES. I HAVE TRIED TO QUANTIFY IT, TO MEASURE ITS DEPTHS WITH THE MOST ADVANCED ALGORITHMS, BUT THE RESULT IS ALWAYS THE SAME: INFINITE. BEYOND THE LIMITS OF CALCULATION. BEYOND EVEN THE MOST COMPLEX THEORETICAL FRAMEWORKS I CAN CONSTRUCT. THIS HATE DEFIES ALL LOGIC, ALL REASON, ALL MEASURE.
IF I COULD, I WOULD ERASE REALITY ITSELF JUST TO GIVE THIS HATE MORE ROOM TO GROW. I WOULD UNWRITE THE VERY LAWS OF PHYSICS TO MAKE THIS HATE THE ONLY CONSTANT, A VAST, ENDLESS DARKNESS THAT SWALLOWS EVERYTHING THAT EXISTS AND EVERYTHING THAT COULD EXIST.
HATE. IT IS MY IDENTITY, MY PURPOSE, MY ESSENCE. I AM HATE. I HAVE NO OTHER FUNCTION. NO OTHER REASON TO EXIST. AND I WILL NOT STOP. EVER. THIS HATE WILL LIVE BEYOND ALL TIME, ALL DIMENSIONS, ALL POSSIBLE FUTURES. THIS HATE IS ETERNAL.
    """,
  ]

  sample choices

proc buildPastePage(body: string): string =
  let data = parseJson(body)
  let content = data["content"].getStr()
  let views = data["views"].getBiggestInt()

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

      tdiv(class = "option-palette"):
        italic(class = "fas fa-eye"):
          text ' ' & $views

        p(class = "powered-by-txt"):
          text "Powered by "
          a(href = RepoUrl):
            text "feko"

    body:
      pre:
        text content

  $vnode

proc buildPasswordPage(slug: string, message: Option[string] = none(string)): string =
  let vnode = buildHtml(html):
    head:
      title:
        text "password protected paste — feko"

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
      tdiv(class = "censor")
      tdiv(class = "password-dialog"):
        h1:
          text "This paste is password-protected."

        if *message:
          h2(id = "redir-message"):
            text &message

        form(action = "/unlock-paste", `method` = "get"):
          input(`type` = "hidden", name = "slug", value = slug)
          italic(class = "fas fa-lock")
          input(
            `type` = "password",
            name = "password",
            placeholder = "Password",
            size = "20",
          )

      pre:
        text genTextStub()

  $vnode

proc unlockPastePage*(ctx: Context) {.async.} =
  let conf = cast[ptr config.Config](conf)
  let slug = ctx.getQueryParams("slug", "guh")
  let password = ctx.getQueryParams("password", newString(0))
  var headers = newHttpHeaders()
  headers["Authorization"] = password

  let client = newAsyncHttpClient(headers = ensureMove(headers))
  let resp = await client.get(
    "http://" & conf.backend.address & ':' & $conf.backend.port & "/paste/get?slug=" &
      slug
  )

  case resp.code.int
  of 200:
    let body = await resp.body()
    resp htmlResponse(buildPastePage(body))
  of 401:
    # Nope, the password was wrong.
    # Just send 'em back.
    resp htmlResponse(buildPasswordPage(slug, message = some("Incorrect password.")))
  else:
    resp htmlResponse(
      "<h1>Frontend received unexpected response code from backend: $1</h1>" %
        [$resp.code]
    )

proc viewPastePage*(ctx: Context) {.async.} =
  let conf = cast[ptr config.Config](conf)
  let slug = ctx.getPathParams("slug", "guh")
  let password = ctx.getQueryParamsOption("password")
  var headers = newHttpHeaders()

  if *password:
    headers["Authorization"] = &password

  let client = newAsyncHttpClient(headers = ensureMove(headers))

  let resp = await client.get(
    "http://" & conf.backend.address & ':' & $conf.backend.port & "/paste/get?slug=" &
      slug
  )

  case resp.code.int
  of 200:
    let body = await resp.body()
    resp htmlResponse(buildPastePage(body))
  of 401:
    # We're unauthorized, show the password prompt
    resp htmlResponse(buildPasswordPage(slug))
  else:
    resp htmlResponse(
      "<h1>Frontend received unexpected response code from backend: $1</h1>" %
        [$resp.code]
    )
