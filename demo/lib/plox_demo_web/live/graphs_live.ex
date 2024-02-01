defmodule PloxDemoWeb.GraphsLive do
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
      <.simple_line simple_line={@simple_line} />

      <.logo_graph logo_graph={@logo_graph} />

      <.math_stuff math_stuff={@math_stuff} />
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

    date_scale = date_scale(Date.range(~D[2023-08-01], ~D[2023-08-05]))
    number_scale = number_scale(0.0, 80.0)

    dataset =
      dataset(data,
        x: {date_scale, & &1.date},
        y: {number_scale, & &1.value}
      )

    assign(socket,
      simple_line:
        to_graph(
          scales: [date_scale: date_scale, number_scale: number_scale],
          datasets: [dataset: dataset]
        )
    )
  end

  defp simple_line(assigns) do
    ~H"""
    <div>
      <.heading navigate={~p"/simple_line"}>1. Simple Line</.heading>

      <.graph :let={graph} id="simple_line" for={@simple_line} width="670" height="250">
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
    </div>
    """
  end

  defp mount_logo_graph(socket) do
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

    assign(socket,
      logo_graph:
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
  end

  defp logo_graph(assigns) do
    ~H"""
    <div>
      <.heading>2. Logo</.heading>

      <.graph :let={graph} id="logo_graph" for={@logo_graph} width="440" height="250">
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
    </div>
    """
  end

  defp mount_math_stuff(socket) do
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

    x_scale = number_scale(-360, 360)
    y_scale = number_scale(-1.5, 1.5)

    sine_dataset = dataset(sine_data, x: {x_scale, & &1.degrees}, y: {y_scale, & &1.sin})
    cosine_dataset = dataset(cosine_data, x: {x_scale, & &1.degrees}, y: {y_scale, & &1.cos})

    arctangent_dataset =
      dataset(arctangent_data, x: {x_scale, & &1.degrees}, y: {y_scale, & &1.atan})

    assign(socket,
      math_stuff:
        to_graph(
          scales: [x_scale: x_scale, y_scale: y_scale],
          datasets: [sine: sine_dataset, cosine: cosine_dataset, arctangent: arctangent_dataset]
        )
    )
  end

  defp math_stuff(assigns) do
    ~H"""
    <div class="space-y-4">
      <.heading>3. Sine/Cosine/ArcTangent</.heading>

      <.graph :let={graph} id="math_stuff" for={@math_stuff} width={800} height={250}>
        <.x_axis :let={degrees} scale={graph[:x_scale]} ticks={9}>
          <%= round(degrees) %>°
        </.x_axis>

        <.y_axis :let={y} scale={graph[:y_scale]} ticks={7}>
          <%= y %>
        </.y_axis>

        <.line_plot dataset={graph[:sine]} color="#8FDA5D" line_style={:dashed} />

        <.line_plot dataset={graph[:cosine]} color="#35A9C0" width="2" line_style={:dotted} />
        <.points_plot dataset={graph[:cosine]} color="#35A9C0" />

        <.line_plot dataset={graph[:arctangent]} color="#FF5954" width="1" />
        <.points_plot dataset={graph[:arctangent]} color="#FF5954" radius="3" />

        <.marker at={-180} scale={graph[:x_scale]}>
          Start
        </.marker>

        <.marker at={180} scale={graph[:x_scale]}>
          End
        </.marker>
      </.graph>
    </div>
    """
  end

  attr :navigate, :string, default: nil
  slot :inner_block, required: true

  defp heading(assigns) do
    ~H"""
    <h2 class="bg-slate-100 font-bold p-2 rounded-md w-fit">
      <.link navigate={@navigate} class="">
        <%= render_slot(@inner_block) %>
      </.link>
    </h2>
    """
  end
end
