defmodule ChromechatServer.Mixfile do
  use Mix.Project

  def project do
    [ app: :chromechat_server,
      version: "0.0.1",
      dynamos: [ChromechatServer.Dynamo],
      compilers: [:elixir, :dynamo, :app],
      env: [prod: [compile_path: "ebin"]],
      compile_path: "tmp/#{Mix.env}/chromechat_server/ebin",
      elixir: "~> 0.11.1-dev",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
      applications: [:cowboy, :dynamo],
      mod: { ChromechatServer, [] }
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat.git" }
  defp deps do
    [
      { :cowboy, github: "extend/cowboy" },
      { :dynamo, github: "elixir-lang/dynamo" },
      { :jazz, github: "meh/jazz" }
    ]
  end
end
