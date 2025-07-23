defmodule Plox.YAxis do
  @moduledoc """
  YAxis implements the `Plox.Axis.Protocol` and is used to convert scale values
  to graphable y-coordinates.

  This module implements the `Access` behaviour, allowing access to graphable
  values using the `[]` syntax. Note that y-coordinates go from top to bottom,
  meaning that lower y values correspond to higher y-coordinates and vice versa:

      iex> scale = Plox.NumberScale.new(0, 10)
      iex> dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      iex> y_axis = %Plox.YAxis{scale: scale, dimensions: dimensions}
      iex> y_axis[1]
      90.0
      iex> y_axis[8]
      20.0

  This is useful when rendering graph elements in a more intuitive way:

      <!-- Draw a red circle where you expect y = 1 (at the given x-coordinate) -->
      <.circle cx={50.0} cy={y_axis[1]} fill="red" r="3" />

  This module implements the `Plox.Axis.Protocol` and defines the `Plox.Axis.Protocol.to_graph/2`
  function. This function is called by the `Access` behaviour:

      iex> scale = Plox.NumberScale.new(0, 10)
      iex> dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      iex> y_axis = Plox.YAxis.new(scale, dimensions)
      iex> y_axis[1] == Plox.Axis.Protocol.to_graph(y_axis, 1)
      true
  """

  use Plox.Axis

  alias Plox.Scale

  defstruct [:scale, :dimensions]

  @doc """
  Creates a new `Plox.YAxis` struct.

  Accepts a `Plox.Scale` struct and `Plox.Dimensions` struct.

  ## Example

      iex> scale = Plox.NumberScale.new(0, 10)
      iex> dimensions = Plox.Dimensions.new(100, 100)
      iex> Plox.YAxis.new(scale, dimensions)
      %Plox.YAxis{scale: scale, dimensions: dimensions}
  """
  def new(scale, dimensions) do
    %__MODULE__{scale: scale, dimensions: dimensions}
  end

  defimpl Plox.Axis.Protocol do
    @doc """
    Converts the given `value` to a graphable y-coordinate.
    """
    def to_graph(%{scale: scale, dimensions: dimensions}, value) do
      range =
        Range.new(
          dimensions.height - dimensions.margin.bottom - dimensions.padding.bottom,
          dimensions.margin.top + dimensions.padding.top,
          -1
        )

      Scale.convert_to_range(scale, value, range)
    end
  end
end
