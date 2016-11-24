defmodule JsonSvc.Mixfile do
  use Mix.Project

  def project do
    [app: :json_svc,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     # Docs
     name: "JsonSvcEx",
     source_url: "https://github.com/chiengineer/json_svc_ex",
     homepage_url: "https://github.com/chiengineer/json_svc_ex/wiki",
     docs: [
       main: "JsonSvcEx", # The main page in the docs
       extras: ["README.md"]
     ]
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :cowboy, :plug, :poison, :honeybadger, :kafka_ex],
     mod: {JsonSvc, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 0.12"},
     {:poison, "~> 1.4.0"},
     {:junit_formatter, "~> 1.1", only: [:test]},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:honeybadger, "~> 0.6"},
     {:kafka_ex, "~> 0.6"},
     { :uuid, "~> 1.1" },
     {:ex_doc, "~> 0.14", only: :dev}
   ]
  end
end
