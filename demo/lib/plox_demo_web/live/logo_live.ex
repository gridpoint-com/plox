defmodule PloxDemoWeb.LogoLive do
  @moduledoc """
  LiveView displaying the "Logo" example.
  """
  use PloxDemoWeb, :live_view

  import Plox
  import PloxDemoWeb.CodeHelpers
  import PloxDemoWeb.Headings

  def mount(_params, _session, socket) do
    x_scale = number_scale(0.0, 10.0)
    y_scale = number_scale(0.0, 6.0)

    # Letter "P"
    p_data = [
      %{x: 1, y: 5},
      %{x: 2.5, y: 4},
      %{x: 1, y: 3},
      %{x: 1, y: 1}
    ]

    p_dataset =
      dataset(p_data,
        x: {x_scale, & &1.x},
        y: {y_scale, & &1.y}
      )

    # Letter "L"
    l_data = [
      %{x: 3.5, y: 4.5},
      %{x: 3.5, y: 1}
    ]

    l_dataset =
      dataset(l_data,
        x: {x_scale, & &1.x},
        y: {y_scale, & &1.y}
      )

    # Letter "O"
    o_data = [
      %{x: 4.5, y: 2},
      %{x: 5.5, y: 3},
      %{x: 6.5, y: 2},
      %{x: 5.5, y: 1},
      %{x: 4.5, y: 2}
    ]

    o_dataset =
      dataset(o_data,
        x: {x_scale, & &1.x},
        y: {y_scale, & &1.y}
      )

    # Letter "X"
    x1_data = [
      %{x: 7, y: 3},
      %{x: 9, y: 1}
    ]

    x1_dataset =
      dataset(x1_data,
        x: {x_scale, & &1.x},
        y: {y_scale, & &1.y}
      )

    x2_data = [
      %{x: 7, y: 1},
      %{x: 9, y: 3}
    ]

    x2_dataset =
      dataset(x2_data,
        x: {x_scale, & &1.x},
        y: {y_scale, & &1.y}
      )

    socket =
      assign(socket,
        graph:
          to_graph(
            scales: [x_scale: x_scale, y_scale: y_scale],
            datasets: [
              p_dataset: p_dataset,
              l_dataset: l_dataset,
              o_dataset: o_dataset,
              x1_dataset: x1_dataset,
              x2_dataset: x2_dataset
            ]
          )
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.heading1>Logo Plot</.heading1>

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
    <.graph :let={graph} id="logo_graph" for={@graph} width="440" height="250">
      <.x_axis :let={value} scale={graph[:x_scale]}>
        <%= value %>
      </.x_axis>
      <.y_axis :let={value} scale={graph[:y_scale]} ticks={7}>
        <%= value %>
      </.y_axis>

      <.line_plot dataset={graph[:p_dataset]} width="5" />
      <.points_plot dataset={graph[:p_dataset]} radius="8" />

      <.line_plot dataset={graph[:l_dataset]} width="5" color="#78C348" />
      <.points_plot dataset={graph[:l_dataset]} radius="8" color="#78C348" />

      <.line_plot dataset={graph[:o_dataset]} width="5" color="#71AEFF" />
      <.points_plot dataset={graph[:o_dataset]} radius="8" color="#71AEFF" />

      <.line_plot dataset={graph[:x1_dataset]} width="5" color="#FF7167" />
      <.points_plot dataset={graph[:x1_dataset]} radius="8" color="#FF7167" />

      <.line_plot dataset={graph[:x2_dataset]} width="5" color="#FF7167" />
      <.points_plot dataset={graph[:x2_dataset]} radius="8" color="#FF7167" />
    </.graph>
    """
  end

  defp code() do
    """
    <.graph :let={graph} id="logo_graph" for={@graph} width="440" height="250">
      <.x_axis :let={value} scale={graph[:x_scale]}>
        <%= value %>
      </.x_axis>
      <.y_axis :let={value} scale={graph[:y_scale]} ticks={7}>
        <%= value %>
      </.y_axis>

      <.line_plot dataset={graph[:p_dataset]} width="5" />
      <.points_plot dataset={graph[:p_dataset]} radius="8" />

      <.line_plot dataset={graph[:l_dataset]} width="5" color="#78C348" />
      <.points_plot dataset={graph[:l_dataset]} radius="8" color="#78C348" />

      <.line_plot dataset={graph[:o_dataset]} width="5" color="#71AEFF" />
      <.points_plot dataset={graph[:o_dataset]} radius="8" color="#71AEFF" />

      <.line_plot dataset={graph[:x1_dataset]} width="5" color="#FF7167" />
      <.points_plot dataset={graph[:x1_dataset]} radius="8" color="#FF7167" />

      <.line_plot dataset={graph[:x2_dataset]} width="5" color="#FF7167" />
      <.points_plot dataset={graph[:x2_dataset]} radius="8" color="#FF7167" />
    </.graph>
    """
  end

  defp setup() do
    """
    # 1. set up `Plox.Scale`s for the x and y scales

    x_scale = number_scale(0.0, 10.0)
    y_scale = number_scale(0.0, 6.0)

    # 2. fetch data and set up `Plox.Dataset`s

    ## Letter "P"
    p_data = [
      %{x: 1, y: 5},
      %{x: 2.5, y: 4},
      %{x: 1, y: 3},
      %{x: 1, y: 1}
    ]

    p_dataset =
      dataset(p_data,
        x: {x_scale, & &1.x},
        y: {y_scale, & &1.y}
      )

    ## Letter "L"
    l_data = [
      %{x: 3.5, y: 4.5},
      %{x: 3.5, y: 1}
    ]

    l_dataset =
      dataset(l_data,
        x: {x_scale, & &1.x},
        y: {y_scale, & &1.y}
      )

    ## Letter "O"
    o_data = [
      %{x: 4.5, y: 2},
      %{x: 5.5, y: 3},
      %{x: 6.5, y: 2},
      %{x: 5.5, y: 1},
      %{x: 4.5, y: 2}
    ]

    o_dataset =
      dataset(o_data,
        x: {x_scale, & &1.x},
        y: {y_scale, & &1.y}
      )

    ## Letter "X"
    x1_data = [
      %{x: 7, y: 3},
      %{x: 9, y: 1}
    ]

    x1_dataset =
      dataset(x1_data,
        x: {x_scale, & &1.x},
        y: {y_scale, & &1.y}
      )

    x2_data = [
      %{x: 7, y: 1},
      %{x: 9, y: 3}
    ]

    x2_dataset =
      dataset(x2_data,
        x: {x_scale, & &1.x},
        y: {y_scale, & &1.y}
      )

    # 3. assign newly constructed `Plox.Graph` to the socket

    assign(socket,
      graph:
        to_graph(
          scales: [x_scale: x_scale, y_scale: y_scale],
          datasets: [
            p_dataset: p_dataset,
            l_dataset: l_dataset,
            o_dataset: o_dataset,
            x1_dataset: x1_dataset,
            x2_dataset: x2_dataset
          ]
        )
    )
    """
  end
end
