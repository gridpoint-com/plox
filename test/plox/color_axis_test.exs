defmodule Plox.ColorAxisTest do
  use ExUnit.Case

  alias Plox.Axis
  alias Plox.ColorAxis

  doctest ColorAxis

  setup do
    %{scale: Plox.FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})}
  end

  test "new/2", %{scale: scale} do
    assert ColorAxis.new(scale) == %ColorAxis{scale: scale}
  end

  test "implements to_graph/2", %{scale: scale} do
    color_axis = ColorAxis.new(scale)

    assert Axis.Protocol.to_graph(color_axis, :red) == "#ff0000"
    assert Axis.Protocol.to_graph(color_axis, :green) == "#00ff00"
    assert Axis.Protocol.to_graph(color_axis, :blue) == "#0000ff"
  end

  test "fetches graphable values using Access syntax", %{scale: scale} do
    color_axis = ColorAxis.new(scale)

    assert color_axis[:red] == "#ff0000"
    assert color_axis[:green] == "#00ff00"
    assert color_axis[:blue] == "#0000ff"
  end
end
