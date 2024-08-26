defprotocol Plox.Axis do
  @moduledoc """
  A protocol for graph axes.

  TODO: docs
  """

  @typedoc """
  Any struct that implements this protocol

  Built in implementations are:

  * `Plox.XAxis`
  * `Plox.YAxis`
  * `Plox.RadiusAxis`
  * `Plox.ColorAxis`
  """
  @type t :: any()

  @doc """
  Converts a specific scale value to a value usable by the graph components
  """
  @spec to_graph(axis :: t(), any()) :: any()
  def to_graph(axis, value)
end
