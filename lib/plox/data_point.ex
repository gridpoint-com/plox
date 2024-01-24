defmodule Plox.DataPoint do
  @moduledoc false
  # TODO: I dunno about docs yet

  alias Plox.GraphPoint
  alias Plox.GraphScalar
  alias Plox.GraphScale

  defstruct [:id, :original, :mapped]

  def new(id, original, mapped) do
    %__MODULE__{id: id, original: original, mapped: mapped}
  end

  def to_graph_point(%__MODULE__{} = data_point, x_scale, x_key, y_scale, y_key) do
    x_value = data_point.mapped[x_key]
    y_value = data_point.mapped[y_key]

    x = GraphScale.to_graph_x(x_scale, x_value)
    y = GraphScale.to_graph_y(y_scale, y_value)

    GraphPoint.new(x, y, data_point)
  end

  def to_graph_x(%__MODULE__{} = data_point, scale, key) do
    scale
    |> GraphScale.to_graph_x(data_point.mapped[key])
    |> GraphScalar.new(data_point)
  end

  def to_graph_y(%__MODULE__{} = data_point, scale, key) do
    scale
    |> GraphScale.to_graph_y(data_point.mapped[key])
    |> GraphScalar.new(data_point)
  end
end
