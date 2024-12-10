defmodule Day09 do
  def parse(string) do
    string
    |> IO.inspect()
    |> String.replace(~r/\D/, "")
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.flat_map(&convert/1)
  end

  def solve_mini_1() do
    "2333133121414131402"
    |> parse
    |> Enum.with_index()
    |> Enum.reduce([], fn z, acc -> acc ++ convert(z) end)

    # |> solve_1
  end

  def solve_1, do: File.read!("/Users/niki/projects/aoc2024/input/day09.txt") |> parse |> solve_1

  def solve_1(list) do
    list

    # |> IO.inspect()
    |> Arrays.new()
    |> process()
    |> Enum.filter(&(&1 != "."))
    |> Enum.with_index()
    |> Enum.reduce(0, fn {id, indx}, acc -> acc + id * indx end)
  end

  def process(arr) do
    arr |> Enum.join("") |> IO.inspect()
    process(arr, 0, Arrays.size(arr) - 1)
  end

  def process(arr, left, right) when left >= right, do: arr

  def process(arr, left, right),
    do: process(arr, left, Arrays.get(arr, left), right, Arrays.get(arr, right))

  # def process(arr, left, right) do
  #   left_c = Arrays.get(arr,left)
  #   right_c = Arrays.get(arr,right)
  #   #IO.inspect([left, left_c, right, right_c])
  #   process(arr,left,left_c, right, right_c)
  # end

  # Left not under space, move forward
  def process(arr, left, left_c, right, _right_c) when left_c != ".",
    do: process(arr, left + 1, right)

  # left ready to be replaced, right not ready, move right back
  def process(arr, left, left_c, right, right_c) when left_c == "." and right_c == ".",
    do: process(arr, left, right - 1)

  def process(arr, left, left_c, right, right_c) when left_c == "." and right_c != "." do
    new_arr = Arrays.replace(arr, left, right_c) |> Arrays.replace(right, ".")
    IO.inspect(Enum.join(new_arr, ""))
    process(new_arr, left + 1, right)
  end

  def convert({"0", _i}), do: []

  def convert({n, i}) do
    # IO.inspect(["Convert",n,i,rem(i+2,2)])
    n = String.to_integer(n)

    case rem(i, 2) do
      1 -> Enum.map(1..n, fn _ -> "." end)
      0 -> Enum.map(1..n, fn _ -> round(i / 2) end)
    end
  end

  def swap(list, start_index, end_index, to_index) do
    # IO.inspect([start_index, end_index, to_index], label: "SWAP:", charlists: :as_list)

    # size = 1+end_index - start_index
    size = end_index - start_index
    # IO.inspect(
    #   [Enum.slice(list, 0..(to_index - 1)),"\n",
    # Enum.slice(list, start_index..end_index) ,"\n",
    # Enum.slice(list, (to_index + size)..(start_index - 1)) ,"\n",
    # Enum.slice(list, to_index..(-1+to_index + size)) ,"\n",
    # Enum.slice(list, end_index + 1, length(list) - 1)], charlists: :as_list
    # )

    arr = [
      Enum.slice(list, 0..(to_index - 1)),
      Enum.slice(list, start_index..end_index),
      Enum.slice(list, (to_index + size + 1)..(start_index - 1)),
      Enum.slice(list, to_index..(to_index + size)),
      Enum.slice(list, end_index + 1, length(list) - 1)
    ]

    # IO.inspect(arr, label: "SWAP RES", charlists: :as_list)
    Enum.flat_map(arr, fn x -> x end)
  end

  # Find the first sequence of `target` (either dots or numbers) with at least length `len`
  # Search direction can be `:left_to_right` (default) or `:right_to_left`
  def find_sequence(list, target, len, direction \\ :left_to_right) do
    # Reverse the list if searching right to left
    list_to_search = if direction == :right_to_left, do: Enum.reverse(list), else: list

    z = do_find_sequence(list_to_search, target, len, 0, 0, nil)
    # IO.inspect([list |> Enum.join(""), target, len, z], label: "find_seq")
    z
  end

  # Helper function to traverse the list
  # `index` - current index in the list (0-based)
  # `count` - number of consecutive occurrences of the target
  # `start_pos` - starting position of the current sequence
  defp do_find_sequence([], _target, _x, _index, _count, _start_pos), do: nil

  defp do_find_sequence([target | tail], target, x, index, count, start_pos) do
    count = count + 1

    if count == x do
      # Return 1-based index
      (start_pos || index - count + 1) + 1
    else
      do_find_sequence(tail, target, x, index + 1, count, start_pos || index)
    end
  end

  # When the current element is not the target
  defp do_find_sequence([_ | tail], target, x, index, _count, _start_pos) do
    do_find_sequence(tail, target, x, index + 1, 0, nil)
  end

  def find_next_file(list), do: Enum.reverse(list) |> Enum.find(&is_number(&1))

  def find_range_of_file(list, file_id) do
    indices =
      list
      |> Enum.with_index()
      |> Enum.filter(fn {x, _index} -> x == file_id end)
      |> Enum.map(fn {_x, index} -> index end)

    # |> IO.inspect(label: "For file_id #{inspect(file_id)}", charlists: :as_list)

    {List.first(indices), List.last(indices)}
  end

  def solve_2 do
    list = "2333133121414131402" |> Day09.parse() |> IO.inspect()
    max = find_next_file(list)
    # IO.inspect(max, label: "Max file id")

    # res = max..0//-1 |> Range.to_list |>  Enum.reduce(list, fn file_id, list ->  handle_file_id(file_id, list) end )
    res =
      for x <- max..0//-1, reduce: list, do: (list -> handle_file_id(x, list))

    res |> Enum.join() |> IO.inspect()

    res
    |> Enum.with_index()
    |> Enum.filter(fn {c, _} -> c != "." end)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end

  def handle_file_id(file_id, list) do
    {start_index, end_index} = find_range_of_file(list, file_id)
    res = end_index - start_index + 1
    to_index = find_sequence(list, ".", res)
    # IO.inspect(to_index, label: "To index for #{inspect({file_id, res})}")

    new_list =
      if to_index == nil || to_index > start_index,
        do: list,
        else: swap(list, start_index, end_index, to_index - 1)

    # IO.inspect(new_list |> Enum.join(""))
    new_list
  end
end
