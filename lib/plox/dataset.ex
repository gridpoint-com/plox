defmodule Plox.Dataset do
  @moduledoc """
  A collection of data points and some metadata for a graph
  """
  alias Plox.Axis
  alias Plox.DataPoint

  # defstruct [:data, :axes]
  defstruct [:data]

  def new(original_data, axis_fns) do
    data =
      original_data
      |> Enum.map(fn original ->
        graph =
          Map.new(axis_fns, fn {key, {axis, fun}} ->
            {key, Axis.to_graph(axis, fun.(original))}
          end)

        DataPoint.new(original, graph)
      end)

    # axes = Map.new(axis_fns, fn {key, {scale, _fun}} -> {key, scale} end)

    %__MODULE__{data: data}
  end

  def get_graph_values(%__MODULE__{data: data}, key_mapping) do
    Enum.map(data, fn data_point ->
      Map.new(key_mapping, fn {requested_key, axis_key} ->
        {requested_key, Map.get(data_point.graph, axis_key)}
      end)
    end)
  end
end
