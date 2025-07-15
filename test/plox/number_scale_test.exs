defmodule Plox.NumberScaleTest do
  use ExUnit.Case

  alias Plox.NumberScale
  alias Plox.Scale

  doctest Plox.NumberScale

  describe "new/2" do
    test "with valid numbers" do
      scale = NumberScale.new(0, 10)
      assert scale.first == Decimal.new("0.0")
      assert scale.last == Decimal.new("10.0")
      refute scale.backwards?
    end

    test "with reversed numbers" do
      scale = NumberScale.new(10, 0)
      assert scale.first == Decimal.new("10.0")
      assert scale.last == Decimal.new("0.0")
      assert scale.backwards?
    end

    test "raises an error with identical numbers" do
      assert_raise ArgumentError, fn ->
        NumberScale.new(5, 5)
      end
    end
  end

  describe "values/2" do
    test "with default ticks" do
      scale = NumberScale.new(0, 10)
      assert Scale.values(scale) == [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    end

    test "with custom ticks" do
      scale = NumberScale.new(0, 10)
      assert Scale.values(scale, %{ticks: 5}) == [0.0, 2.5, 5.0, 7.5, 10.0]
    end

    test "with reversed scale" do
      scale = NumberScale.new(10, 0)
      assert Scale.values(scale) == [10.0, 9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0]
    end

    test "raises an error with invalid ticks" do
      scale = NumberScale.new(0, 10)

      assert_raise ArgumentError, fn ->
        Scale.values(scale, %{ticks: 1})
      end
    end
  end

  describe "convert_to_range/3" do
    test "with valid input" do
      scale = NumberScale.new(0, 10)
      assert Scale.convert_to_range(scale, 5, 0..100) == 50.0
    end

    test "with reversed scale" do
      scale = NumberScale.new(10, 0)
      assert Scale.convert_to_range(scale, 2, 0..100) == 80.0
    end

    test "raises an error with out of bounds input" do
      scale = NumberScale.new(0, 10)

      assert_raise ArgumentError, fn ->
        Scale.convert_to_range(scale, 11, 0..100)
      end
    end

    test "raises an error with invalid input" do
      scale = NumberScale.new(0, 10)

      assert_raise ArgumentError, fn ->
        Scale.convert_to_range(scale, "invalid", 0..100)
      end
    end
  end
end
