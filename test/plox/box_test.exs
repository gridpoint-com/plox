defmodule Plox.BoxTest do
  use ExUnit.Case

  alias Plox.Box

  doctest Box

  test "new/1" do
    assert Box.new(1) == %Box{top: 1, right: 1, bottom: 1, left: 1}
    assert Box.new({1}) == %Box{top: 1, right: 1, bottom: 1, left: 1}
    assert Box.new({1, 2}) == %Box{top: 1, right: 2, bottom: 1, left: 2}
    assert Box.new({1, 2, 3}) == %Box{top: 1, right: 2, bottom: 3, left: 2}
    assert Box.new({1, 2, 3, 4}) == %Box{top: 1, right: 2, bottom: 3, left: 4}
    assert Box.new("1") == %Box{top: 1, right: 1, bottom: 1, left: 1}
    assert Box.new("1 2") == %Box{top: 1, right: 2, bottom: 1, left: 2}
    assert Box.new("1 2 3") == %Box{top: 1, right: 2, bottom: 3, left: 2}
    assert Box.new("1 2 3 4") == %Box{top: 1, right: 2, bottom: 3, left: 4}
  end
end
