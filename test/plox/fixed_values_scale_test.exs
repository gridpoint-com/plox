defmodule Plox.FixedValuesScaleTest do
  use ExUnit.Case

  alias Plox.FixedValuesScale
  alias Plox.Scale

  doctest Plox.FixedValuesScale

  describe "new/1" do
    test "creates a new FixedValuesScale" do
      scale = FixedValuesScale.new([:a, :b, :c, :d])

      assert %FixedValuesScale{
               values: [:a, :b, :c, :d],
               index_map: %{a: 0, b: 1, c: 2, d: 3},
               max_index: 3
             } = scale
    end

    test "raises an error for invalid input" do
      assert_raise ArgumentError, fn ->
        FixedValuesScale.new([1])
      end
    end
  end

  describe "values/1" do
    test "returns the values in the scale" do
      scale = FixedValuesScale.new([:a, :b, :c])
      assert Scale.values(scale) == [:a, :b, :c]
    end
  end

  describe "convert_to_range/3" do
    test "with valid input" do
      scale = FixedValuesScale.new([:a, :b, :c])
      assert Scale.convert_to_range(scale, :a, 0..100) == 0.0
      assert Scale.convert_to_range(scale, :b, 0..100) == 50.0
      assert Scale.convert_to_range(scale, :c, 0..100) == 100.0
    end

    test "raises an error for invalid values" do
      scale = FixedValuesScale.new([:a, :b, :c])

      assert_raise ArgumentError, fn ->
        Scale.convert_to_range(scale, :d, 0..100)
      end
    end
  end
end
