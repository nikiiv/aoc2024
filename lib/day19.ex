defmodule Day19 do
  def main(dictionary_str, sequences_str) do
    dictionary =
      dictionary_str
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)
      |> MapSet.new()

    sequences =
      sequences_str
      |> String.split("\n", trim: true)

    sequences
    |> Enum.with_index()
    |> Enum.map(&word_break?(&1, dictionary))
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def word_break?({s, _i}, dictionary) do
    # IO.inspect(s, label: "Current Word #{inspect(i)}")
    can_break(s, dictionary) |> IO.inspect(label: s)
  end

  defp can_break("", _dictionary), do: true

  defp can_break(s, dictionary) do
    # If the result for the current substring is already computed, return it
    case MemoizationServer.get(s) do
      nil ->
        # IO.inspect(s, label: "Current word")
        # Attempt to find a prefix of `s` that is in the dictionary
        result =
          dictionary
          |> Enum.filter(fn word -> String.starts_with?(s, word) end)
          # |> IO.inspect(label: "filter")
          |> Enum.all?(fn word ->
            {_, rest} = String.split_at(s, String.length(word))
            # IO.puts("Trying #{rest} after using #{word}")
            can_break(rest, dictionary)
          end)

        MemoizationServer.put(s, result)
        result

      cached_result ->
        cached_result
    end
  end

  def hello, do: MemoizationServer.hello()

  def sample_data do
    dictionary_str = "r, wr, b, g, bwu, rb, gb, br"

    # sequences_str = """
    # brwrr
    # bggr
    # gbbr
    # rrbgbr
    # ubwu
    # bwurrg
    # brgr
    # bbrgwb
    # """

    sequences_str = "gbbr"

    [dictionary_str, sequences_str]
  end

  def real_date, do: File.read!("/Users/niki/aoc2024/input/day19.txt") |> String.split("\n\n")

  def solve do
    MemoizationServer.start_link()
    MemoizationServer.clear_data()
    [dictionary_str, sequences_str] = sample_data()
    main(dictionary_str, sequences_str)
    IO.inspect(MemoizationServer.print(), label: "Memo")
    MemoizationServer.get(:total) |> IO.inspect(label: "Total")
  end
end

# Day19.solve()
