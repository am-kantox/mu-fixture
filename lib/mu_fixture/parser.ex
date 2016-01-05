defmodule MuFixture.Parser do
  @moduledoc """
    Defines a behaviour for `Parser`s.
  """

  @callback parse(String.t) :: any
end
