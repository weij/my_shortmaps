defmodule MyShortmaps do
  @moduledoc """
  Documentation for MyShortmaps.
  """
  @default_modifier ?s

  defmacro sigil_m(term, modifiers)
  defmacro sigil_m({:<<>>, line, [string]}, modifiers) do
    sigil_m_function(line, String.split(string), modifier(modifiers), __CALLER__)
  end

  def sigil_m_function(line, words, modifier, _caller) do
    pairs = make_pairs(words, modifier)
    IO.inspect(line, label: "line")
    IO.inspect(pairs, label: "pairs")
    {:%{}, line, pairs}
  end

  def make_pairs(words, modifier) do
    keys = Enum.map(words, &strip_pin/1)
    variables = Enum.map(words, &handle_var/1)

    # ensure_valid_variable_names(keys)

    case modifier do
      ?a -> keys |> Enum.map(&String.to_atom/1) |> Enum.zip(variables)
      ?s -> keys |> Enum.zip(variables)
      _ ->  keys |> Enum.map(&String.to_atom/1) |> Enum.zip(variables)
    end
  end

  defp strip_pin("^" <> name), do: name
  defp strip_pin(name), do: name

  defp handle_var("^" <> name) do
    {:^, [], [Macro.var(String.to_atom(name), nil)]}
  end
  defp handle_var(name) do
    String.to_atom(name) |> Macro.var(nil)
  end

  defp modifier([]), do: @default_modifier
  defp modifier([mod]) when mod in 'as', do: mod
  defp modifier(_), do: raise(ArgumentError, "only these modifiers are supported: s, a")
end
