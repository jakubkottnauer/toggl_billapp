defmodule TogglBillapp.Mixfile do
  use Mix.Project

  def project do
    [
      app: :toggl_billapp,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      escript: [main_module: TogglBillapp.CLI],
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  def application do
    [applications: [:togglex]]
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:togglex, "~> 0.1.0"},
      {:excoveralls, "~> 0.7", only: :test},
      {:credo, "~> 0.3", only: [:dev, :test]}
    ]
  end
end
