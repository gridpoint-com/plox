<img width="400" src="screenshots/logo-plot@2x.png#gh-light-mode-only" alt="Plox">
<img width="400" src="screenshots/logo-plot-dark@2x.png#gh-dark-mode-only" alt="Plox">

Server-side rendered SVG graphing/plotting components for Phoenix HEEx.

## Installation

Plox is [available in Hex](https://hex.pm/docs/publish), the package can be
installed by adding `plox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:plox, "~> 0.1.0"}
  ]
end
```

Documentation is published on [HexDocs](https://hexdocs.pm) and can be found at
<https://hexdocs.pm/plox>.

## Example

<img width="740" src="screenshots/readme-example-plot@2x.png" alt="Example screenshot">

Start by setting up your data, scales, and dataset:

```elixir
data = [
  %{date: ~D[2023-08-01], value: 35.0},
  %{date: ~D[2023-08-02], value: 60.0},
  %{date: ~D[2023-08-03], value: 65.0},
  %{date: ~D[2023-08-04], value: 10.0},
  %{date: ~D[2023-08-05], value: 50.0}
]

date_scale = date_scale(Date.range(~D[2023-08-01], ~D[2023-08-05]))
number_scale = number_scale(0.0, 80.0)

dataset =
  dataset(data,
    x: {date_scale, & &1.date},
    y: {number_scale, & &1.value}
  )

example_graph =
  to_graph(
    scales: [date_scale: date_scale, number_scale: number_scale],
    datasets: [dataset: dataset]
  )
```

Then you can simply render a `graph` directly within your HEEx template:

```heex
<.graph :let={graph} id="example_graph" for={@example_graph} width="800" height="250">
  <:legend>
    <.legend_item color="#EC7E16" label="Data" />
  </:legend>

  <.x_axis :let={date} scale={graph[:date_scale]}>
    <%= Calendar.strftime(date, "%-m/%-d") %>
  </.x_axis>

  <.y_axis :let={value} scale={graph[:number_scale]} ticks={5}>
    <%= value %>
  </.y_axis>

  <.line_plot dataset={graph[:dataset]} color="#EC7E16" />

  <.points_plot dataset={graph[:dataset]} color="#EC7E16" />
</.graph>
```
