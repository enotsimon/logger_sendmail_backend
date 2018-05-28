defmodule LoggerSendmailBackend.Mixfile do
  use Mix.Project

  @version File.read!("VERSION") |> String.trim

  def project do
    [
      app: :logger_sendmail_backend,
      version: @version,
      elixir: "~> 1.0",
      description: "backend for Logger that sends letters thru sendmail",
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [applications: []]
  end


  defp deps do
    []
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md VERSION),
      maintainers: ["Ivan Skorobogatko"],
      licenses: ["Unlicense"],
      links: %{"GitHub" => "https://github.com/enotsimon/logger_sendmail_backend"}
    ]
  end
end
