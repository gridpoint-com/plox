defmodule Plox.LinearAxis do
  @moduledoc """
  LinearAxis implements the `Plox.Axis.Protocol` and is used to convert scale values
  to graphable values in a linear range between a minimum and maximum.

  This module implements the `Access` behaviour, allowing access to graphable
  values using the `[]` syntax:

      iex> scale = Plox.NumberScale.new(0, 10)
      iex> linear_axis = %Plox.LinearAxis{scale: scale, min: 0, max: 100}
      iex> linear_axis[1]
      10.0
      iex> linear_axis[2]
      20.0

  This is useful when rendering graph elements in a more intuitive way:

      <!-- Draw a red circle with a radius of 10 (at the given coordinates) -->
      <.circle cx={25.0} cy={50.0} fill="red" r={linear_axis[1]} />

  This module implements the `Plox.Axis.Protocol` and defines the `Plox.Axis.Protocol.to_graph/2`
  function. This function is called by the `Access` behaviour:

      iex> scale = Plox.NumberScale.new(0, 10)
      iex> linear_axis = Plox.LinearAxis.new(scale, min: 0, max: 100)
      iex> linear_axis[1] == Plox.Axis.Protocol.to_graph(linear_axis, 1)
      true
  """

  use Plox.Axis

  alias Plox.Scale

  defstruct [:scale, :min, :max]

  @doc """
  Creates a new `Plox.LinearAxis` struct.

  Accepts a `Plox.Scale` struct and `min` and `max` values.

  ## Example

      iex> scale = Plox.NumberScale.new(0, 10)
      iex> Plox.LinearAxis.new(scale, min: 0, max: 100)
      %Plox.LinearAxis{scale: scale, min: 0, max: 100}
  """
  def new(scale, opts \\ []) do
    Keyword.validate!(opts, [:min, :max])
    min = Keyword.fetch!(opts, :min)
    max = Keyword.fetch!(opts, :max)

    %__MODULE__{scale: scale, min: min, max: max}
  end

  defimpl Plox.Axis.Protocol do
    @doc """
    Converts the given `value` to a graphable value linearly interpolated
    between the `min` and `max` of the axis.
    """
    def to_graph(%{scale: scale, min: min, max: max}, value) do
      Scale.convert_to_range(scale, value, min..max)
    end
  end
end
