defmodule Plox.Dataset do
  @moduledoc """
  A collection of data points and some metadata for a graph
  """
  alias Plox.Axis
  alias Plox.DataPoint

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

    %__MODULE__{data: data}
  end
end
