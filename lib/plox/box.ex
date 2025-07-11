defmodule Plox.Box do
  @moduledoc """
  Data structure for defining a rectangular box with top, right, bottom, and
  left sides. This is useful for specifying margins and paddings in a format
  similar to CSS margin and padding properties.

  ## Examples

      iex> Plox.Box.new(10)
      %Plox.Box{top: 10, right: 10, bottom: 10, left: 10}

      iex> Plox.Box.new({5, 15})
      %Plox.Box{top: 5, right: 15, bottom: 5, left: 15}

      iex> Plox.Box.new({5, 15, 10})
      %Plox.Box{top: 5, right: 15, bottom: 10, left: 15}

      iex> Plox.Box.new({5, 15, 10, 20})
      %Plox.Box{top: 5, right: 15, bottom: 10, left: 20}
  """

  defstruct [:top, :right, :bottom, :left]

  def new(string) when is_binary(string) do
    string
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
    |> new()
  end

  def new({n}) when is_number(n), do: new(n)

  def new(n) when is_number(n), do: %__MODULE__{top: n, right: n, bottom: n, left: n}

  def new({top_bottom, right_left}),
    do: %__MODULE__{top: top_bottom, right: right_left, bottom: top_bottom, left: right_left}

  def new({top, right_left, bottom}), do: %__MODULE__{top: top, right: right_left, bottom: bottom, left: right_left}

  def new({top, right, bottom, left}), do: %__MODULE__{top: top, right: right, bottom: bottom, left: left}
end
