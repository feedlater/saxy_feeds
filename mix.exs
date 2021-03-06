defmodule SaxyFeeds.MixProject do
  use Mix.Project

  def project do
    [
      app: :saxy_feeds,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:saxy, "~> 1.4"},
      {:timex, "~> 3.7"}
    ]
  end
end
