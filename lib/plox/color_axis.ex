defmodule Plox.ColorAxis do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  use Plox.Axis

  alias Plox.ColorScale

  defstruct [:scale]

  @doc """
  Creates a new `Plox.ColorAxis` struct.

  Accepts a `Plox.ColorScale` struct.

  ## Example

      iex> color_scale = Plox.FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})
      iex> Plox.ColorAxis.new(color_scale)
      %Plox.ColorAxis{scale: color_scale}
  """
  def new(scale) do
    %__MODULE__{scale: scale}
  end

  # def values(%__MODULE__{scale: scale}, opts \\ %{}), do: Scale.values(scale, opts)

  defimpl Plox.Axis.Protocol do
    @doc """
    Converts the given `value` to a graphable color.

    ## Example

        iex> color_scale = Plox.FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})
        iex> color_axis = Plox.ColorAxis.new(color_scale)
        iex> Plox.Axis.Protocol.to_graph(color_axis, :red)
        "#ff0000"
    """
    def to_graph(%{scale: scale}, value) do
      ColorScale.convert_to_color(scale, value)
    end
  end
end
