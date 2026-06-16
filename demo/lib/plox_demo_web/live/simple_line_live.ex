defmodule PloxDemoWeb.SimpleLineLive do
  @moduledoc """
  LiveView displaying the "Simple Line" example.
  """
  use PloxDemoWeb, :live_view

  import Plox
  import PloxDemoWeb.CodeHelpers
  import PloxDemoWeb.Headings

  def mount(_params, _session, socket) do
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

    socket =
      assign(socket,
        graph:
          to_graph(
            scales: [date_scale: date_scale, number_scale: number_scale],
            datasets: [dataset: dataset]
          )
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.heading1>Simple Line Plot</.heading1>

    <div class="flex flex-col 2xl:flex-row gap-4">
      <div class="space-y-4">
        <.example_graph graph={@graph} />

        <.heading2>HEEx Template</.heading2>

        <.code_block code={code()} />
      </div>

      <div>
        <.heading2>Setup</.heading2>

        <.code_block code={setup()} />
      </div>
    </div>
    """
  end

  defp example_graph(assigns) do
    ~H"""
    <.graph :let={graph} id="simple_line" for={@graph} width="670" height="250">
      <:legend>
        <.legend_item color="#EC7E16" label="Data" />
      </:legend>

      <.x_axis :let={date} scale={graph[:date_scale]}>
        <%= Calendar.strftime(date, "%-m/%-d") %>
      </.x_axis>

      <.y_axis :let={value} scale={graph[:number_scale]} ticks={5}>
        <%= value %>
      </.y_axis>

      <.line_plot dataset={graph[:dataset]} />

      <.points_plot dataset={graph[:dataset]} />
    </.graph>
    """
  end

  defp code() do
    """
    <.graph :let={graph} id="simple_line" for={@graph} width="670" height="250">
      <:legend>
        <.legend_item color="#EC7E16" label="Data" />
      </:legend>

      <.x_axis :let={date} scale={graph[:date_scale]}>
        <%= Calendar.strftime(date, "%-m/%-d") %>
      </.x_axis>

      <.y_axis :let={value} scale={graph[:number_scale]} ticks={5}>
        <%= value %>
      </.y_axis>

      <.line_plot dataset={graph[:dataset]} />

      <.points_plot dataset={graph[:dataset]} />
    </.graph>
    """
  end

  defp setup() do
    """
    # 1. fetch data

    data = [
      %{date: ~D[2023-08-01], value: 35.0},
      %{date: ~D[2023-08-02], value: 60.0},
      %{date: ~D[2023-08-03], value: 65.0},
      %{date: ~D[2023-08-04], value: 10.0},
      %{date: ~D[2023-08-05], value: 50.0}
    ]

    # 2. set up `Plox.Scale`s for the x and y scales

    date_scale = date_scale(Date.range(~D[2023-08-01], ~D[2023-08-05]))
    number_scale = number_scale(0.0, 80.0)

    # 3. set up `Plox.Dataset`s with data and scales

    dataset =
      dataset(data,
        x: {date_scale, & &1.date},
        y: {number_scale, & &1.value}
      )

    # 4. assign newly constructed `Plox.Graph` to the socket

    assign(socket,
      graph:
        to_graph(
          scales: [date_scale: date_scale, number_scale: number_scale],
          datasets: [dataset: dataset]
        )
    )
    """
  end
end
