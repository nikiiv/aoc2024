defmodule Day25 do
  @moduledoc """
  A module to parse schematics for keys and locks based on the height of the pins/holes.
  """

  @doc """
  Parses the input string and separates keys and locks with their respective column heights.

  ## Parameters
    - input: A string containing multiple matrices separated by blank lines.

  ## Returns
    - A tuple containing two lists:
      - First list contains height lists for locks.
      - Second list contains height lists for keys.
  """
  def parse(input) do
    input
    |> split_matrices()
    |> Enum.map(&parse_matrix/1)
    |> separate_keys_locks()
  end

  defp split_matrices(input) do
    input
    # Split on two or more newlines
    |> String.split(~r/\R{2,}/)
    |> Enum.map(fn matrix ->
      matrix
      |> String.split(~r/\R/)
      |> Enum.map(&String.trim/1)
    end)
  end

  defp parse_matrix(lines) do
    top_row = List.first(lines)

    type = if is_lock?(top_row), do: :lock, else: :key

    heights = calculate_heights(lines)

    %{type: type, heights: heights}
  end

  defp is_lock?(top_row) do
    top_row && String.match?(top_row, ~r/^#+$/)
  end

  defp calculate_heights(lines) do
    lines
    |> Enum.map(&String.graphemes/1)
    |> transpose()
    |> Enum.map(&count_hashes/1)
  end

  defp count_hashes(column) do
    Enum.count(column, fn char -> char == "#" end)
  end

  defp transpose(rows) do
    rows
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp separate_keys_locks(parsed_matrices) do
    parsed_matrices
    |> Enum.reduce({[], []}, fn %{type: type, heights: heights}, {locks, keys} ->
      case type do
        :lock -> {[heights | locks], keys}
        :key -> {locks, [heights | keys]}
      end
    end)
    |> then(fn {locks, keys} -> {Enum.reverse(locks), Enum.reverse(keys)} end)
  end

  def solve do
    sample_input = """
    #####
    .####
    .####
    .####
    .#.#.
    .#...
    .....

    #####
    ##.##
    .#.##
    ...##
    ...#.
    ...#.
    .....

    .....
    #....
    #....
    #...#
    #.#.#
    #.###
    #####

    .....
    .....
    #.#..
    ###..
    ###.#
    ###.#
    #####

    .....
    .....
    .....
    #....
    #.#..
    #.#.#
    #####

    """

    # _sample_input_large = File.read!("/Users/niki/aoc2024/input/day25.txt") <> "\n"

    {locks, keys} = parse(sample_input)

    locks =
      locks
      |> Enum.filter(&(length(&1) > 0))
      |> Enum.map(fn sublist ->
        Enum.map(sublist, fn num -> num - 1 end)
      end)

    keys =
      keys
      |> Enum.filter(&(length(&1) > 0))
      |> Enum.map(fn sublist ->
        Enum.map(sublist, fn num -> num - 1 end)
      end)

    combos =
      for k <- keys, l <- locks, into: [] do
        {l, k}
      end

    IO.inspect(length(combos), label: "Total combos key lock")

    combos
    |> Enum.filter(&filter_combo/1)
    |> Enum.count()
  end

  def filter_combo({l, k} = _combo) do
    # IO.inspect(combo, label: "Current combo")

    Enum.zip(l, k)
    # |> IO.inspect()
    |> Enum.all?(fn {l1, k1} -> l1 + k1 < 6 end)

    # |> IO.inspect(label: "for Combo #{inspect(combo)}")
  end
end
