defmodule PloxDemoWeb.CodeHelpers do
  @moduledoc """
  Collection of components for easily rendering
  code snippets.
  """
  use Phoenix.Component

  attr :code, :string, required: true
  attr :language, :atom, values: [:elixir, :heex], default: :elixir

  def code_block(%{language: :elixir} = assigns) do
    ~H"""
    <div class="bg-slate-100 p-4 rounded-md w-fit">
      <%= @code |> Makeup.highlight() |> Phoenix.HTML.raw() %>
    </div>
    """
  end

  def code_block(%{language: :heex} = assigns) do
    ~H"""
    <div class="bg-slate-100 p-4 rounded-md w-fit">
      <%= @code |> Makeup.highlight(lexer: Makeup.Lexers.HEExLexer) |> Phoenix.HTML.raw() %>
    </div>
    """
  end
end
