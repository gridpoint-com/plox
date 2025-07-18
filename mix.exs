defmodule Plox.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/gridpoint-com/plox"

  def project do
    [
      app: :plox,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "Server-side rendered SVG graphing components for Phoenix and LiveView",
      package: package(),

      # Docs
      name: "Plox",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Chris Dosé", "Cody Rogers", "Nikki Kyllonen"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(.formatter.exs mix.exs README.md CODE_OF_CONDUCT.md LICENSE lib)
    ]
  end

  defp docs do
    [
      main: "Plox",
      source_ref: "v#{@version}",
      logo: "images/plox-icon.png",
      source_url: @source_url,
      groups_for_modules: groups_for_modules(),
      groups_for_functions: [
        Components: &(&1[:type] == :component)
      ],
      extras: ["README.md", "LICENSE", "CODE_OF_CONDUCT.md", "docs/migration_guide.md"]
    ]
  end

  defp groups_for_modules do
    [
      Structs: [
        Plox.Box,
        Plox.DataPoint,
        Plox.Dataset,
        Plox.Dimensions
      ],
      Protocols: [
        Plox.Axis.Protocol,
        Plox.ColorScale,
        Plox.Scale
      ],
      Axes: [
        Plox.ColorAxis,
        Plox.LinearAxis,
        Plox.XAxis,
        Plox.YAxis
      ],
      Scales: [
        Plox.DateScale,
        Plox.DateTimeScale,
        Plox.FixedValuesScale,
        Plox.NumberScale
      ],
      "Color Scales": [
        Plox.FixedColorsScale
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decimal, "~> 2.0"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:phoenix_live_view, "~> 0.20 or ~> 1.0"},
      {:styler, "~> 0.11", only: [:dev, :test], runtime: false}
    ]
  end
end
