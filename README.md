# feko
Feko (Hindi for "throw", pronounced "fay-koh" / "fae-koh") is a simple-to-configure but powerful Pastebin-like service written in Nim. It's split into two binaries: the frontend service (using [prologue](https://github.com/planety/prologue)) and the backend service (using [mummy](https://github.com/guzba/mummy) and [kiwi](https://github.com/xTrayambak/kiwi)).

I wrote it to be a lightweight and fast paste service that can be hosted anywhere, from proper servers to resource-limited hobbyist homelabs.

# features
- basic paste creation (obviously)
- password locked pastes
- view counter for pastes
- simple TOML configuration
- UTF-8 validation for pastes
- two slug generation algorithms (`alphanum` and `uuid`)

all in ~800 lines of Nim.

# setup
## obtaining the source code
```bash
$ git clone https://github.com/xTrayambak/feko.git
```

## compiling feko
For this, you require a [Nim toolchain](https://nim-lang.org/install_unix.html), version 2.2.4 and above.
```bash
$ cd feko
$ nimble build --define:release
```

Now, you should have `feko_back` and `feko_front`. Do as you please with them - tie them into a systemd service or whatnot.

## configuration
Feko uses TOML for configuration.
It searches for the configuration at `~/.config/feko/config.toml` by default, but this behaviour can be modified using the `--config:/path/to/config.toml` flag.

Here's a basic `config.toml` that shows off all of the features Feko exposes.

```toml
# All config options for the backend service
[backend]
# The port at which the feko_back binary listens for connections at
port = 8080

# The address at which the feko_back binary listens for connections at
address = "localhost"

# The slug-generation algorithm used. `alphanum` is much cleaner but `uuid` has an almost-null collision chance.
slug_algorithm = "alphanum"

# The maximum number of characters that a single paste can have (default: 6000 chars)
max_paste_size = 80000

# All config options for the frontend service
[frontend]
# The port at which the feko_front binary listens for clients at
port = 8081

# The address at which the feko_front binary listens for clients at
address = "localhost"

# Config options for the actual paste store using Kiwi
[store]
# At every N seconds, flush the database to disk.
flush_frequency = 60.0
```

# contributing
Just send in MRs and I'll be more than happy to accept them, if they're needed.
