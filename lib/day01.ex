defmodule Day01 do
  @file_name "/Users/niki/aoc2024/input/day01.txt"

  def parse_csv, do: parse_csv(@file_name)

  def parse_csv(file_path) do
    # Read the file content
    {:ok, content} = File.read(file_path)

    # Split the content into rows and process them
    rows =
      content
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_row/1)

    # Separate the numbers into two lists
    {list1, list2} = split_columns(rows)

    IO.puts("First column: #{inspect(list1)}")
    IO.puts("Second column: #{inspect(list2)}")

    {list1, list2}
  end

  # Parse a single row into a tuple of numbers
  defp parse_row(row) do
    row
    |> String.split("   ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  # Split rows into two separate lists for each column
  defp split_columns(rows) do
    Enum.reduce(rows, {[], []}, fn {a, b}, {list1, list2} ->
      {[a | list1], [b | list2]}
    end)
    |> then(fn {list1, list2} -> {Enum.sort(list1), Enum.sort(list2)} end)
  end

  def count_occurrences(list, number) do
    Enum.count(list, fn x -> x == number end)
  end

  def solve2 do
    data = parse_csv(@file_name)
    list1 = elem(data, 0)
    list2 = elem(data, 1)
    solve2(list1, list2, 0)
  end

  def solve2([h | t], list, acc) do
    acc = acc + h * count_occurrences(list, h)
    solve2(t, list, acc)
  end

  def solve2([], _, acc), do: acc

  def solve do
    data = parse_csv()
    list1 = elem(data, 0)
    list2 = elem(data, 1)
    solve(list1, list2, 0)
  end

  def solve([], [], acc), do: acc

  def solve([h1 | t1], [h2 | t2], acc) do
    acc = acc + abs(h1 - h2)
    solve(t1, t2, acc)
  end
end
