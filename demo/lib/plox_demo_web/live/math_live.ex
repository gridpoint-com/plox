# defmodule PloxDemoWeb.MathLive do
#   @moduledoc """
#   LiveView displaying the "Simple Line" example.
#   """
#   use PloxDemoWeb, :live_view

#   import Plox
#   import PloxDemoWeb.CodeHelpers
#   import PloxDemoWeb.Headings

#   def mount(_params, _session, socket) do
#     sine_data =
#       Enum.map(-360..360//30, fn deg ->
#         %{degrees: deg, sin: :math.sin(deg * :math.pi() / 180)}
#       end)

#     cosine_data =
#       Enum.map(-360..360//20, fn deg ->
#         %{degrees: deg, cos: :math.cos(deg * :math.pi() / 180)}
#       end)

#     arctangent_data =
#       Enum.map(-180..180//10, fn deg ->
#         %{degrees: deg, atan: :math.atan(deg * :math.pi() / 180)}
#       end)

#     x_scale = number_scale(-360, 360)
#     y_scale = number_scale(-1.5, 1.5)

#     sine_dataset = dataset(sine_data, x: {x_scale, & &1.degrees}, y: {y_scale, & &1.sin})
#     cosine_dataset = dataset(cosine_data, x: {x_scale, & &1.degrees}, y: {y_scale, & &1.cos})

#     arctangent_dataset =
#       dataset(arctangent_data, x: {x_scale, & &1.degrees}, y: {y_scale, & &1.atan})

#     socket =
#       assign(socket,
#         graph:
#           to_graph(
#             scales: [x_scale: x_scale, y_scale: y_scale],
#             datasets: [sine: sine_dataset, cosine: cosine_dataset, arctangent: arctangent_dataset]
#           )
#       )

#     {:ok, socket}
#   end

#   def render(assigns) do
#     ~H"""
#     <.heading1>Sine/Cosine/ArcTangent Plot</.heading1>

#     <div class="flex flex-col 2xl:flex-row gap-4">
#       <div class="space-y-4">
#         <.example_graph graph={@graph} />

#         <.heading2>HEEx Template</.heading2>

#         <.code_block code={code()} />
#       </div>

#       <div>
#         <.heading2>Setup</.heading2>

#         <.code_block code={setup()} />
#       </div>
#     </div>
#     """
#   end

#   defp example_graph(assigns) do
#     ~H"""
#     <.graph :let={graph} id="math_stuff" for={@graph} width={800} height={250}>
#       <.x_axis :let={degrees} scale={graph[:x_scale]} ticks={9}>
#         <%= round(degrees) %>°
#       </.x_axis>

#       <.y_axis :let={y} scale={graph[:y_scale]} ticks={7}>
#         <%= y %>
#       </.y_axis>

#       <.line_plot dataset={graph[:sine]} color="#8FDA5D" line_style={:dashed} />

#       <.line_plot dataset={graph[:cosine]} color="#35A9C0" width="2" line_style={:dotted} />
#       <.points_plot dataset={graph[:cosine]} color="#35A9C0" />

#       <.line_plot dataset={graph[:arctangent]} color="#FF5954" width="1" />
#       <.points_plot dataset={graph[:arctangent]} color="#FF5954" radius="3" />

#       <.marker at={-180} scale={graph[:x_scale]}>
#         Start
#       </.marker>

#       <.marker at={180} scale={graph[:x_scale]}>
#         End
#       </.marker>
#     </.graph>
#     """
#   end

#   defp code() do
#     """
#     <.graph :let={graph} id="math_stuff" for={@graph} width={800} height={250}>
#         <.x_axis :let={degrees} scale={graph[:x_scale]} ticks={9}>
#           <%= round(degrees) %>°
#         </.x_axis>

#         <.y_axis :let={y} scale={graph[:y_scale]} ticks={7}>
#           <%= y %>
#         </.y_axis>

#         <.line_plot dataset={graph[:sine]} color="#8FDA5D" line_style={:dashed} />

#         <.line_plot dataset={graph[:cosine]} color="#35A9C0" width="2" line_style={:dotted} />
#         <.points_plot dataset={graph[:cosine]} color="#35A9C0" />

#         <.line_plot dataset={graph[:arctangent]} color="#FF5954" width="1" />
#         <.points_plot dataset={graph[:arctangent]} color="#FF5954" radius="3" />

#         <.marker at={-180} scale={graph[:x_scale]}>
#           Start
#         </.marker>

#         <.marker at={180} scale={graph[:x_scale]}>
#           End
#         </.marker>
#       </.graph>
#     """
#   end

#   defp setup() do
#     """
#     # 1. calculate data

#     sine_data =
#       Enum.map(-360..360//30, fn deg ->
#         %{degrees: deg, sin: :math.sin(deg * :math.pi() / 180)}
#       end)

#     cosine_data =
#       Enum.map(-360..360//20, fn deg ->
#         %{degrees: deg, cos: :math.cos(deg * :math.pi() / 180)}
#       end)

#     arctangent_data =
#       Enum.map(-180..180//10, fn deg ->
#         %{degrees: deg, atan: :math.atan(deg * :math.pi() / 180)}
#       end)

#     # 2. set up `Plox.Scale`s for the x and y scales

#     x_scale = number_scale(-360, 360)
#     y_scale = number_scale(-1.5, 1.5)

#     # 3. set up `Plox.Dataset`s with data and scales

#     sine_dataset =
#       dataset(sine_data,
#         x: {x_scale, & &1.degrees},
#         y: {y_scale, & &1.sin}
#       )

#     cosine_dataset =
#       dataset(cosine_data,
#         x: {x_scale, & &1.degrees},
#         y: {y_scale, & &1.cos}
#       )

#     arctangent_dataset =
#       dataset(arctangent_data,
#         x: {x_scale, & &1.degrees},
#         y: {y_scale, & &1.atan}
#       )

#     # 4. assign newly constructed `Plox.Graph` to the socket

#     assign(socket,
#       graph:
#         to_graph(
#           scales: [x_scale: x_scale, y_scale: y_scale],
#           datasets: [
#             sine: sine_dataset,
#             cosine: cosine_dataset,
#             arctangent: arctangent_dataset
#           ]
#         )
#     )
#     """
#   end
# end
