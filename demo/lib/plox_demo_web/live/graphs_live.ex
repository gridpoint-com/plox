defmodule PloxDemoWeb.GraphsLive do
  use PloxDemoWeb, :live_view

  import Plox

  def mount(_params, _session, socket) do
    {:ok, socket |> mount_simple_line()}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Welcome to Plox!</h1>
      <p>Here are some demos.</p>

      <div class="my-4">
        <.simple_line simple_line={@simple_line} />
      </div>
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
    <h2 class="bg-slate-100 font-bold p-2 rounded-md w-fit">1. Simple Line Plot</h2>

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
    """
  end
end
