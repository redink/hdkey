defmodule Hdkey.MixProject do
  use Mix.Project

  def project do
    [
      app: :hdkey,
      version: "0.1.0",
      elixir: "~> 1.6",
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
      {:libsecp256k1, "~> 0.1.10"},
      {:jason, "~> 1.1", only: [:test]}
    ]
  end
end
