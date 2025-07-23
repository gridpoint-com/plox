defmodule Plox.XAxis do
  @moduledoc """
  XAxis implements the `Plox.Axis.Protocol` and is used to convert scale values
  to graphable x-coordinates.

  This module implements the `Access` behaviour, allowing access to graphable
  values using the `[]` syntax:

      iex> scale = Plox.NumberScale.new(0, 10)
      iex> dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      iex> x_axis = %Plox.XAxis{scale: scale, dimensions: dimensions}
      iex> x_axis[1]
      10.0
      iex> x_axis[2]
      20.0

  This is useful when rendering graph elements in a more intuitive way:

      <!-- Draw a red circle where you expect x = 1 (at the given y-coordinate) -->
      <.circle cx={x_axis[1]} cy={50.0} fill="red" r="3" />

  This module implements the `Plox.Axis.Protocol` and defines the `Plox.Axis.Protocol.to_graph/2`
  function. This function is called by the `Access` behaviour:

      iex> scale = Plox.NumberScale.new(0, 10)
      iex> dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      iex> x_axis = Plox.XAxis.new(scale, dimensions)
      iex> x_axis[1] == Plox.Axis.Protocol.to_graph(x_axis, 1)
      true
  """

  use Plox.Axis

  alias Plox.Scale

  defstruct [:scale, :dimensions]

  @doc """
  Creates a new `Plox.XAxis` struct.

  Accepts a `Plox.Scale` struct and `Plox.Dimensions` struct.

  ## Example

      iex> scale = Plox.NumberScale.new(0, 10)
      iex> dimensions = Plox.Dimensions.new(100, 100)
      iex> Plox.XAxis.new(scale, dimensions)
      %Plox.XAxis{scale: scale, dimensions: dimensions}
  """
  def new(scale, dimensions) do
    %__MODULE__{scale: scale, dimensions: dimensions}
  end

  defimpl Plox.Axis.Protocol do
    @doc """
    Converts the given `value` to a graphable x-coordinate.
    """
    def to_graph(%{scale: scale, dimensions: dimensions}, value) do
      range =
        Range.new(
          dimensions.margin.left + dimensions.padding.left,
          dimensions.width - dimensions.margin.right - dimensions.padding.right
        )

      Scale.convert_to_range(scale, value, range)
    end
  end
end
