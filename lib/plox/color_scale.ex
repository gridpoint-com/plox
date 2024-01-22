defprotocol Plox.ColorScale do
  @moduledoc """
  A protocol for graph color scales.

  Any graph color scale must implement this protocol in order to be used by the
  `Plox.graph` component.
  """

  @typedoc """
  Any struct that implements this protocol

  Built in implementations are:

  * `Plox.FixedColorsScale`
  """
  @type t :: any()

  @type color :: String.t()

  @doc """
  Converts a specific scale value to a color.
  """
  @spec convert_to_color(scale :: t(), any()) :: color() | nil
  def convert_to_color(scale, value)
end
