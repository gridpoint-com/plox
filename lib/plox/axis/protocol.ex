defprotocol Plox.Axis.Protocol do
  @moduledoc """
  A protocol for graph axes. Requires axes to implement a method to convert scale values
  to graphable values.
  """

  @typedoc """
  Any struct that implements this protocol

  Built in implementations are:

  * `Plox.XAxis`
  * `Plox.YAxis`
  * `Plox.ColorAxis`
  """
  @type t :: any()

  @doc """
  Converts a specific scale value to a graphable value.
  """
  @spec to_graph(axis :: t(), any()) :: any()
  def to_graph(axis, value)
end
