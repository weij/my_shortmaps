defmodule MyShortmaps do
  @moduledoc """
  Documentation for MyShortmaps.
  """
  @default_modifier ?s

  #
  # 步骤1: 先上个bodyless function
  #
  defmacro sigil_m(term, modifiers)

  #
  # 步骤2: quote expression 固定写法, 为什么? 自己看看sigil_m的quote expresion便明白了
  #
  # iex(1)> quote do: ~m("hello" :weijun)
  # iex(2)> {:sigil_m, [], [{:<<>>, [], ["\"hello\" :weijun"]}, []]}
  #
  defmacro sigil_m({:<<>>, line, [string]}, modifiers) do
    sigil_m_function(line, String.split(string), modifier(modifiers), __CALLER__)
  end

  #
  # 步骤3: 关键在make_pairs/2， 然后返回 {:%{}, line, pairs}, map的qute expression
  #
  def sigil_m_function(line, words, modifier, _caller) do
    pairs = make_pairs(words, modifier)
    IO.inspect(line, label: "line")
    IO.inspect(pairs, label: "pairs")
    {:%{}, line, pairs}
  end

  def make_pairs(words, modifier) do

    #
    # 步骤3.1: 准备collection keys
    #
    keys = Enum.map(words, &strip_pin/1)
    IO.inspect(keys, label: "after stripped pin")

    #
    # 步骤3.2: 获取目标模块的quote expression
    #
    variables = Enum.map(words, &handle_var/1)
    IO.inspect(variables, label: "get value input")
    # ensure_valid_variable_names(keys)

    #
    # 步骤3.3： 默认modifer为string, 不需要to_atom, 其他modifiers都to_atom
    #
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
