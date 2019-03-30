defmodule MyShortmapsTest do
  use ExUnit.Case
  doctest MyShortmaps
  import MyShortmaps


  test "~m(name title) generates %{name: name, title: title}" do
    name =  "weijun"
    title = "engineer"

    %{name: name1, title: title1} = ~m(name title)
    assert name1 == name
    assert title1 == title
  end
end
