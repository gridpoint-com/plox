defmodule Plox.Dataset do
  @moduledoc """
  A collection of data points and some metadata for a graph
  """
  alias Plox.Axis
  alias Plox.DataPoint

  defstruct [:data, :axes]

  def new(original_data, axis_fns) do
    data =
      Enum.map(original_data, fn original ->
        graph = Map.new(axis_fns, fn {key, {axis, fun}} -> {key, Axis.to_graph(axis, fun.(original))} end)

        DataPoint.new(original, graph)
      end)

    # %{axis_name => {axis, function}, etc.}
    axes =
      Map.new(axis_fns, fn {key, {axis, _fun}} ->
        {key, axis}
      end)

    %__MODULE__{data: data, axes: axes}
  end
end
