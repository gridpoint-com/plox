defmodule Plox.DataPoint do
  @moduledoc """
  Data structure for containing raw data and its mapped values for graphing.

  Calculated by `Plox.Dataset.new/2` when processing the raw data:

      iex> data = [%{foo: 1, bar: 2}, %{foo: 2, bar: 3}]
      iex> dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      iex> scale = Plox.NumberScale.new(0, 10)
      iex> x_axis = Plox.XAxis.new(scale, dimensions)
      iex> Plox.Dataset.new(data, %{x: {x_axis, & &1.foo}})
      %Plox.Dataset{
        data: [
          %Plox.DataPoint{original: %{foo: 1, bar: 2}, graph: %{x: 10.0}},
          %Plox.DataPoint{original: %{foo: 2, bar: 3}, graph: %{x: 20.0}}
        ],
        axes: %{
          x: %Plox.XAxis{
            scale: Plox.NumberScale.new(0.0, 10.0),
            dimensions: %Plox.Dimensions{
              width: 100,
              height: 100,
              margin: %Plox.Box{top: 0, right: 0, bottom: 0, left: 0},
              padding: %Plox.Box{top: 0, right: 0, bottom: 0, left: 0}
            }
          }
        }
      }
  """

  defstruct [:original, :graph]

  @doc """
  Creates a new `Plox.DataPoint` struct.

  Accepts the original data and a map of graphable values for each axis.

  ## Example

      iex> original = %{foo: 1, bar: 2}
      iex> graph = %{x: 10.0, y: 20.0}
      iex> Plox.DataPoint.new(original, graph)
      %Plox.DataPoint{original: %{foo: 1, bar: 2}, graph: %{x: 10.0, y: 20.0}}
  """
  def new(original, graph) do
    %__MODULE__{original: original, graph: graph}
  end
end
