defmodule Plox.Dimensions do
  @moduledoc """
  TODO: this is a public module that graph component implementers will interact
  with, so it should be documented
  """

  alias Plox.Box

  defstruct [:width, :height, :margin, :padding]

  def new(width, height, opts \\ []) do
    margin = Keyword.get(opts, :margin, {35, 70})
    padding = Keyword.get(opts, :margin, 0)

    %__MODULE__{
      width: number(width),
      height: number(height),
      margin: Box.new(margin),
      padding: Box.new(padding)
    }
  end

  defp number(string) when is_binary(string), do: String.to_integer(string)
  defp number(number) when is_number(number), do: number
end
