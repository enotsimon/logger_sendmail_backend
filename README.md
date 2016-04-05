# logger_sendmail_backend

## overwiev

backend for Logger that sends letters thru sendmail


## install

add

`{:logger_sendmail_backend, git: "https://github.com/enotsimon/logger_sendmail_backend.git", branch: "master"}`

to your `mix.exs` file in `deps()` section


## usage

add to your config files something like this

```
config :logger,
  level: :info,
  backends: [LoggerSendmailBackend]

config :logger, LoggerSendmailBackend,
  level: :warn,
  #sendmail_command: "cat", # '/usr/sbin/sendmail -t' by default, no need to set it if you got it
  subject: "elixir errors in my <AppName>",
  to: ["mail1@example.com", "mail2@example.com"],
  from: "logger_sendmail_backend <another_mail@example.com>",
  aggregate_time: 5*60000, # 5 min
  msg_limit: 40 # 40 messages limit in one letter
```

