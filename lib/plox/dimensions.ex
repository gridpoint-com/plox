defmodule Plox.Dimensions do
  @moduledoc """
  Data structure for defining the dimensions of a graph, including width,
  height, margin, and padding.
  """

  alias Plox.Box

  defstruct [:width, :height, :margin, :padding]

  @doc """
  Creates a new `Plox.Dimensions` struct.

  Accepts width and height as numbers or strings, and optional keyword
  arguments for margin and padding. Default margin is `{35, 70}` and
  default padding is `0`. See `Plox.Box` for more information on how
  margins and padding may be input.

  ## Example

      iex> Plox.Dimensions.new(800, 600, margin: {20, 30}, padding: 10)
      %Plox.Dimensions{
        width: 800,
        height: 600,
        margin: %Plox.Box{top: 20, right: 30, bottom: 20, left: 30},
        padding: %Plox.Box{top: 10, right: 10, bottom: 10, left: 10}
      }
  """
  def new(width, height, opts \\ []) do
    margin = Keyword.get(opts, :margin, {35, 70})
    padding = Keyword.get(opts, :padding, 0)

    %__MODULE__{
      width: number(width),
      height: number(height),
      margin: Box.new(margin),
      padding: Box.new(padding)
    }
  end

  defp number(string) when is_binary(string), do: String.to_integer(string)
  defp number(number) when is_number(number), do: number
end
