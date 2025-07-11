defmodule Plox.LinearAxis do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
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

  def values(%__MODULE__{scale: scale}, opts \\ %{}), do: Scale.values(scale, opts)

  defimpl Plox.Axis.Protocol do
    @doc """
    Converts the given `value` to a graphable value linearly interpolated
    between the `min` and `max` of the axis.

    ## Example

        iex> scale = Plox.NumberScale.new(0, 10)
        iex> linear_axis = Plox.LinearAxis.new(scale, min: 0, max: 100)
        iex> Plox.Axis.Protocol.to_graph(linear_axis, 1)
        10.0
        iex> Plox.Axis.Protocol.to_graph(linear_axis, 2)
        20.0
    """
    def to_graph(%{scale: scale, min: min, max: max}, value) do
      Scale.convert_to_range(scale, value, min..max)
    end
  end
end
