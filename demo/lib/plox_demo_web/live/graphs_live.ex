defmodule PloxDemoWeb.GraphsLive do
  @moduledoc false
  use PloxDemoWeb, :live_view

  import Plox

  def mount(_params, _session, socket) do
    {:ok, socket |> mount_simple_line() |> mount_logo_graph() |> mount_math_stuff()}
  end

  def render(assigns) do
    ~H"""
    <header class="px-4 sm:px-6 lg:px-8">
      <img class="mx-auto" src={~p"/images/logo-plot@2x.png"} width="400" />
    </header>

    <div class="space-y-8">
      <.simple_line {@simple_line} />

      <.logo_graph {@logo_graph} />

      <.math_stuff {@math_stuff} />
    </div>
    """
  end

  defp mount_simple_line(socket) do
    data = [
      %{date: ~D[2023-08-01], value: 35.0},
      %{date: ~D[2023-08-02], value: 60.0},
      %{date: ~D[2023-08-03], value: 65.0},
      %{date: ~D[2023-08-04], value: 10.0},
      %{date: ~D[2023-08-05], value: 50.0}
    ]

    dimensions = Plox.Dimensions.new(670, 250)

    x_axis =
      Plox.XAxis.new(Plox.DateScale.new(Date.range(~D[2023-08-01], ~D[2023-08-05])), dimensions)

    y_axis = Plox.YAxis.new(Plox.NumberScale.new(0.0, 80.0), dimensions)

    dataset =
      Plox.Dataset.new(data,
        x: {x_axis, & &1.date},
        y: {y_axis, & &1.value}
      )

    assign(socket,
      simple_line: %{
        dimensions: dimensions,
        x_axis: x_axis,
        y_axis: y_axis,
        dataset: dataset
      }
    )
  end

  defp simple_line(assigns) do
    ~H"""
    <div>
      <.heading navigate={~p"/simple_line"}>1. Simple Line</.heading>

      <.graph dimensions={@dimensions}>
        <%!-- <:legend>
          <.legend_item color="#EC7E16" label="Data" />
        </:legend> --%>

        <.x_axis_labels :let={date} axis={@x_axis} class="text-sm">
          <%= Calendar.strftime(date, "%-m/%-d") %>
        </.x_axis_labels>

        <.y_axis_labels :let={value} axis={@y_axis} ticks={5} class="text-sm">
          <%= value %>
        </.y_axis_labels>

        <.x_axis_grid_lines axis={@x_axis} class="stroke-gray-100 dark:stroke-gray-900" />
        <.y_axis_grid_lines axis={@y_axis} ticks={5} class="stroke-gray-100 dark:stroke-gray-900" />

        <.line_plot dataset={@dataset} class="stroke-orange-500 dark:stroke-orange-400 stroke-2" />

        <%!-- <.circles dataset={@dataset} class="fill-orange-500 dark:fill-orange-400" /> --%>
      </.graph>
    </div>
    """
  end

  defp mount_logo_graph(socket) do
    dimensions = Plox.Dimensions.new(440, 250)
    x_axis = Plox.XAxis.new(Plox.NumberScale.new(0.0, 10.0), dimensions)
    y_axis = Plox.YAxis.new(Plox.NumberScale.new(0.0, 6.0), dimensions)

    # Letter "P"
    p_data = [
      %{x: 1, y: 5},
      %{x: 2.5, y: 4},
      %{x: 1, y: 3},
      %{x: 1, y: 1}
    ]

    p_dataset =
      Plox.Dataset.new(p_data,
        x: {x_axis, & &1.x},
        y: {y_axis, & &1.y}
      )

    # Letter "L"
    l_data = [
      %{x: 3.5, y: 4.5},
      %{x: 3.5, y: 1}
    ]

    l_dataset =
      Plox.Dataset.new(l_data,
        x: {x_axis, & &1.x},
        y: {y_axis, & &1.y}
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
      Plox.Dataset.new(o_data,
        x: {x_axis, & &1.x},
        y: {y_axis, & &1.y}
      )

    # Letter "X"
    x1_data = [
      %{x: 7, y: 3},
      %{x: 9, y: 1}
    ]

    x1_dataset =
      Plox.Dataset.new(x1_data,
        x: {x_axis, & &1.x},
        y: {y_axis, & &1.y}
      )

    x2_data = [
      %{x: 7, y: 1},
      %{x: 9, y: 3}
    ]

    x2_dataset =
      Plox.Dataset.new(x2_data,
        x: {x_axis, & &1.x},
        y: {y_axis, & &1.y}
      )

    assign(socket,
      logo_graph: %{
        dimensions: dimensions,
        x_axis: x_axis,
        y_axis: y_axis,
        p_dataset: p_dataset,
        l_dataset: l_dataset,
        o_dataset: o_dataset,
        x1_dataset: x1_dataset,
        x2_dataset: x2_dataset
      }
    )
  end

  defp logo_graph(assigns) do
    ~H"""
    <div>
      <.heading navigate={~p"/logo"}>2. Logo</.heading>

      <.graph dimensions={@dimensions}>
        <.x_axis_labels :let={value} axis={@x_axis} class="text-sm">
          <%= value %>
        </.x_axis_labels>

        <.y_axis_labels :let={value} axis={@y_axis} ticks={7} class="text-sm">
          <%= value %>
        </.y_axis_labels>

        <.x_axis_grid_lines axis={@x_axis} class="stroke-gray-100 dark:stroke-gray-900" />
        <.y_axis_grid_lines axis={@y_axis} ticks={7} class="stroke-gray-100 dark:stroke-gray-900" />

        <.line_plot dataset={@p_dataset} stroke-width="5" stroke="#FF9330" />
        <%!-- <.circles dataset={@p_dataset} r="8" fill="#FF9330" /> --%>

        <.line_plot dataset={@l_dataset} stroke-width="5" stroke="#78C348" />
        <%!-- <.circles dataset={@l_dataset} r="8" fill="#78C348" /> --%>

        <.line_plot dataset={@o_dataset} stroke-width="5" stroke="#71AEFF" />
        <%!-- <.circles dataset={@o_dataset} r="8" fill="#71AEFF" /> --%>

        <.line_plot dataset={@x1_dataset} stroke-width="5" stroke="#FF7167" />
        <%!-- <.circles dataset={@x1_dataset} r="8" fill="#FF7167" /> --%>

        <.line_plot dataset={@x2_dataset} stroke-width="5" stroke="#FF7167" />
        <%!-- <.circles dataset={@x2_dataset} r="8" fill="#FF7167" /> --%>
      </.graph>
    </div>
    """
  end

  defp mount_math_stuff(socket) do
    dimensions = Plox.Dimensions.new(800, 250)

    sine_data =
      Enum.map(-360..360//30, fn deg ->
        %{degrees: deg, sin: :math.sin(deg * :math.pi() / 180)}
      end)

    cosine_data =
      Enum.map(-360..360//20, fn deg ->
        %{degrees: deg, cos: :math.cos(deg * :math.pi() / 180)}
      end)

    arctangent_data =
      Enum.map(-180..180//10, fn deg ->
        %{degrees: deg, atan: :math.atan(deg * :math.pi() / 180)}
      end)

    x_axis = Plox.XAxis.new(Plox.NumberScale.new(-360, 360), dimensions)
    y_axis = Plox.YAxis.new(Plox.NumberScale.new(-1.5, 1.5), dimensions)

    sine_dataset = Plox.Dataset.new(sine_data, x: {x_axis, & &1.degrees}, y: {y_axis, & &1.sin})

    cosine_dataset =
      Plox.Dataset.new(cosine_data, x: {x_axis, & &1.degrees}, y: {y_axis, & &1.cos})

    arctangent_dataset =
      Plox.Dataset.new(arctangent_data, x: {x_axis, & &1.degrees}, y: {y_axis, & &1.atan})

    assign(socket,
      math_stuff: %{
        dimensions: dimensions,
        x_axis: x_axis,
        y_axis: y_axis,
        sine: sine_dataset,
        cosine: cosine_dataset,
        arctangent: arctangent_dataset
      }
    )
  end

  defp math_stuff(assigns) do
    ~H"""
    <div class="space-y-4">
      <.heading navigate={~p"/math"}>3. Sine/Cosine/ArcTangent</.heading>

      <.graph dimensions={@dimensions}>
        <.x_axis_labels :let={degrees} axis={@x_axis} ticks={9} class="text-sm">
          <%= round(degrees) %>°
        </.x_axis_labels>

        <.y_axis_labels :let={y} axis={@y_axis} ticks={7} class="text-sm">
          <%= y %>
        </.y_axis_labels>

        <.x_axis_grid_lines axis={@x_axis} ticks={9} class="stroke-gray-100 dark:stroke-gray-900" />
        <.y_axis_grid_lines axis={@y_axis} ticks={7} class="stroke-gray-100 dark:stroke-gray-900" />

        <.line_plot dataset={@sine} stroke="#8FDA5D" stroke-dasharray="6" />

        <.line_plot dataset={@cosine} stroke="#35A9C0" stroke-width="2" stroke-dasharray="2" />
        <%!-- <.circles dataset={@cosine} fill="#35A9C0" /> --%>

        <.line_plot dataset={@arctangent} stroke="#FF5954" stroke-width="1" />
        <%!-- <.circles dataset={@arctangent} fill="#FF5954" r="3" /> --%>

        <.x_axis_label axis={@x_axis} value={-180} position={:top} class="text-sm" gap={20}>
          Start
        </.x_axis_label>

        <.x_axis_grid_line
          axis={@x_axis}
          value={-180}
          top_overdraw={12}
          class="stroke-gray-800 dark:stroke-gray-100"
          stroke-dasharray="2"
        />

        <.x_axis_label axis={@x_axis} value={180} position={:top} class="text-sm" gap={20}>
          End
        </.x_axis_label>

        <.x_axis_grid_line
          axis={@x_axis}
          value={180}
          top_overdraw={12}
          class="stroke-gray-800 dark:stroke-gray-100"
          stroke-dasharray="2"
        />
      </.graph>
    </div>
    """
  end

  attr :navigate, :string, default: nil
  slot :inner_block, required: true

  defp heading(assigns) do
    ~H"""
    <h2 class="bg-gray-100 dark:bg-gray-900 font-bold p-2 rounded-md w-fit">
      <.link navigate={@navigate} class="">
        <%= render_slot(@inner_block) %>
      </.link>
    </h2>
    """
  end
end
