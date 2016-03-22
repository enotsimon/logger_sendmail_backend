# logger_sendmail_backend

## overwiev

backend for Logger that sends letters thru sendmail


## install

add

`{:logger_sendmail_backend, git: "ssh://git@stash.sj-dev.local:7999/search/logger_sendmail_backend.git", branch: "master"}`

to your `mix.exs` file in `deps()` section


## usage

add to your config files something like this

```
config :logger,
  level: :info,
  backends: [LoggerSendmailBackend]

config :logger, LoggerSendmailBackend,
  level: :warn,
  sendmail_command: "cat", # '/usr/sbin/sendmail -t' by default, no need to set it if you got it
  subject: "elixir errors on node #{inspect node()}",
  to: ["mail@example.com"],
  from: "logger_sendmail_backend <another_mail@example.com>"
```

