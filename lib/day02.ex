defmodule Day02 do
  @file_name "/Users/niki/aoc2024/input/day02.txt"

  def parse_file(file_path) do
    # Read the file content
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_row/1)

      {:error, reason} ->
        IO.puts("Failed to read the file. Reason: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Parse a single row into a tuple of numbers
  defp parse_row(row) do
    row
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solve_problem, do: solve_problem(@file_name)

  def solve_problem(file_name) do
    data = parse_file(file_name)
    # IO.inspect(length(data))

    # call solve for problem1, solver for problem 2
    Enum.map(data, &solver/1)
    |> Enum.count(fn x -> x == :safe end)
  end

  # def solve([], acc), do: acc

  # def solve([h, t], acc) do
  # end

  def solver(orig_levels) do
    IO.inspect(orig_levels)

    variations =
      Enum.map(0..(length(orig_levels) - 1), fn x -> List.delete_at(orig_levels, x) end)

    IO.inspect(variations)
    sol = Enum.any?(variations, fn l -> :safe == solve(l) end)
    IO.inspect(sol)

    if sol do
      :safe
    else
      :unsafe
    end
  end

  def solve(nums) do
    direction = get_direction(nums)
    # IO.inspect(direction)

    case direction do
      :desc ->
        check(Enum.reverse(nums))

      :asc ->
        check(nums)
    end
  end

  def check([_num]), do: :safe

  def check([h | t] = _l) do
    # IO.puts("Checking #{inspect(l)} ")
    el = List.first(t)
    # IO.puts("Comparing #{inspect(h)} and #{inspect(el)}")

    cond do
      el == h -> :unsafe
      el - h > 3 -> :unsafe
      el - h < 4 and el - h > 0 -> check(t)
      true -> :unsafe
    end
  end

  def get_direction(l) do
    nums = List.to_tuple(l)
    size = tuple_size(nums)
    # IO.puts("#{inspect(nums)} of size #{inspect(size)}")
    last_elem = elem(nums, size - 1)
    prev_elem = elem(nums, size - 2)
    # IO.puts("L: #{inspect(last_elem)}, P: #{inspect(prev_elem)}")

    cond do
      last_elem > prev_elem -> :asc
      last_elem <= prev_elem -> :desc
    end
  end
end
