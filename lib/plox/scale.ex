defprotocol Plox.Scale do
  @moduledoc """
  A protocol for graph scales.

  Any graph scale must implement this protocol in order to be used by the
  `Plox.graph` component.
  """

  @typedoc """
  Any struct that implements this protocol

  Built in implementations are:

  * `Plox.DateScale`
  * `Plox.DateTimeScale`
  * `Plox.FixedValuesScale`
  * `Plox.NumberScale`
  """
  @type t :: any()

  @doc """
  Returns an enumerable of the "labeled values" in a scale

  Note: the returned values don't necessarily represent all the values in the
  scale, just the values meant to be labeled and rendered on the corresponding
  axis. e.g. the final value might not be equal to the scale's configured max.
  """
  @spec values(scale :: t(), opts :: keyword()) :: Enumerable.t()
  def values(scale, opts)

  @doc """
  Converts a specific scale value to a number within the requested range

  The destination range must be a valid integer range.
  """
  @spec convert_to_range(scale :: t(), any(), Range.t()) :: number()
  def convert_to_range(scale, value, to_range)
end
