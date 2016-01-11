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
  #########################     PRIVATES::HTML     #############################
  ##############################################################################

  @spec parse_node([String.t]) :: String.t
  defp parse_node([node]) when is_binary(node) do
    String.strip(node)
  end

  @spec parse_node([any]) :: String.t
  defp parse_node([node]) do
    IO.puts "==1==============="
    IO.inspect node
    IO.puts "==1==============="
    String.strip(Floki.text(node))
  end

  @spec parse_node([String.t | any]) :: String.t
  defp parse_node([node | rest]) when is_binary(node) do
    IO.puts "==3==============="
    IO.inspect node
    IO.puts "--3---------------"
    IO.inspect rest
    IO.puts "==3==============="
    String.strip(node) <> parse_node(rest)
  end

  # {"br", [], []}
  @spec parse_node([{String.t, any, []} | any]) :: String.t
  defp parse_node([{node, _, []} | rest]) do
    ""
  end

  # {"u", [], ["StripOffsets"]}
  @spec parse_node([{String.t, any, [String.t]} | any]) :: String.t
  defp parse_node([{node, _, [text]} | rest]) when is_binary(text) do
    String.strip(text) <> parse_node(rest)
  end

  # {"span", [{"class", "s"}], [{"span", [{"class", "n"}], ...
  @spec parse_node([{String.t, any, any} | any]) :: String.t
  defp parse_node([{node, _, head} | rest]) do
    IO.puts "==2==============="
    IO.inspect node
    IO.puts "--2---------------"
    IO.inspect head
    IO.puts "==2==============="
    parse_node(head) <> parse_node(rest)
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
      titles = for {"tr", _, titles } <- input, { "th", _, title } <- titles do parse_node(title) end
               |> Enum.map fn e -> e |> String.downcase |> String.replace(~r/[^a-z0-9]+/, "_") |> String.to_atom end
      values = for {"tr", _, values } <- input do
                 Enum.into(List.zip([titles, for { "td", _, value } <- values do parse_node(value) end]), %{})
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
          [{ "dt", _, [term] }, { "dd", _, desc }] -> { term, parse_node(desc) }
          _ -> :error
        end
      end |> Enum.reject( fn e -> e == :error end )
    end

    # { title, parse_methods(methods) }
  end

end
