defmodule Plox.FixedColorsScaleTest do
  use ExUnit.Case

  alias Plox.ColorScale
  alias Plox.FixedColorsScale

  doctest Plox.FixedColorsScale

  describe "new/1" do
    test "creates a new FixedColorsScale" do
      scale = FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})

      assert %FixedColorsScale{
               mapping: %{red: "#ff0000", green: "#00ff00", blue: "#0000ff"}
             } = scale
    end

    test "raises an error for invalid input" do
      assert_raise ArgumentError, fn ->
        FixedColorsScale.new(%{red: "#ff0000"})
      end
    end
  end

  describe "convert_to_color/2" do
    test "with valid input" do
      scale = FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})
      assert ColorScale.convert_to_color(scale, :red) == "#ff0000"
      assert ColorScale.convert_to_color(scale, :green) == "#00ff00"
      assert ColorScale.convert_to_color(scale, :blue) == "#0000ff"
    end

    test "raises an error for invalid values" do
      scale = FixedColorsScale.new(%{red: "#ff0000", green: "#00ff00", blue: "#0000ff"})

      assert_raise ArgumentError, fn ->
        ColorScale.convert_to_color(scale, :yellow)
      end
    end
  end
end
