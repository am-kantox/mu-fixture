defmodule MuFixture.Parser.Html do
  @moduledoc """
    Parses an external HTML, such as documentation, and produces elixir
    code based on it’s nested tables and data lists.
  """

  @behaviour Parser

  @table_selector "table.inner"

  @doc "Parses the HTML input and returns FIXME for tables and data lists"
  @spec parse(String.t) :: any
  def parse(file) do
    parse_html File.read!(file)
  end

  ##############################################################################
  ############################     PRIVATES     ################################
  ##############################################################################

  @spec parse_html(String.t) :: list
  defp parse_html(text) do
    [parse_dl(text) | parse_table(text)]
  end

  @spec parse_table(String.t) :: list
  defp parse_table(text) do
    for { "table", _, input } <- Floki.find(text, @table_selector) do
      titles = for {"tr", _, titles } <- input, { "th", _, title } <- titles do Floki.text(title) end
               |> Enum.map fn e -> e |> String.downcase |> String.replace(~r/[^a-z0-9]+/, "_") |> String.to_atom end
      values = for {"tr", _, values } <- input do
                 Enum.into(List.zip([titles, for { "td", _, value } <- values do Floki.text(value) end]), %{})
               end |> Enum.reject(&Enum.empty? &1)
      {:ok, titles, values}
    end
  end

  @spec parse_dl(String.t) :: list
  defp parse_dl(text) do
    for { "dl", _, input } <- Floki.find(text, "dl") do
      for { "p", [], content } <- input do
        case content do
          [{ "dt", _, [term] }, { "dd", _, [] }] -> { term, "" }
          [{ "dt", _, [term] }, { "dd", _, [desc] }] -> { term, String.strip(Floki.text(desc)) }
          [{ "dt", _, [term] }, { "dd", _, desc }] -> { term, String.strip(Floki.raw_html(desc)) } # AM FIXME join list as string
          _ -> :error
        end
      end |> Enum.reject( fn e -> e == :error end )
    end

    # { title, parse_methods(methods) }
  end

  @spec parse_node(any) :: any
  defp parse_node({""}) do
  end

end
