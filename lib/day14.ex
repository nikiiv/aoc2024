defmodule Day14 do
  @max_r 103
  @max_c 101
  @iter 100
  def sample_data do
    """
    p=0,4 v=3,-3
    p=6,3 v=-1,-3
    p=10,3 v=-1,2
    p=2,0 v=2,-1
    p=0,0 v=1,3
    p=3,0 v=-2,-2
    p=7,6 v=-1,-3
    p=3,0 v=-1,-2
    p=9,3 v=2,3
    p=7,3 v=-1,2
    p=2,4 v=2,-3
    p=9,5 v=-3,-3
    """
  end

  def real_data, do: File.read!("/Users/niki/aoc2024/input/day14.txt")

  def parse_data(data) do
    String.split(data, "\n", trim: true)
    |> Enum.map(fn line ->
      [p, v] = String.split(String.trim(line), ["p=", " v="], trim: true)
      {c, r} = parse_coordinates(p)
      {dc, dr} = parse_coordinates(v)
      {{c, r}, {dc, dr}}
    end)
  end

  defp parse_coordinates(coord_string) do
    # IO.inspect(coord_string)
    [a, b] = String.split(coord_string, ",")
    {String.to_integer(a), String.to_integer(b)}
  end

  def get_sector({col, row}) do
    # Determine if we're dealing with odd dimensions
    odd_row = rem(@max_r, 2) == 1
    odd_col = rem(@max_c, 2) == 1

    # Half points for division
    mid_row = div(@max_r, 2)
    mid_col = div(@max_c, 2)

    # Check if the point is on a boundary with odd dimensions
    if (odd_row and row == mid_row) or (odd_col and col == mid_col) do
      :none
    else
      # Assign sector based on position relative to midpoints
      cond do
        row < mid_row && col < mid_col -> :top_left
        row < mid_row && col > mid_col -> :top_right
        row > mid_row && col < mid_col -> :bottom_left
        true -> :bottom_right
      end
    end
  end

  def sample_1, do: real_data() |> parse_data() |> solve

  def solve(list_of_robos) do
    map = %{top_left: 0, top_right: 0, bottom_left: 0, bottom_right: 0}

    list_of_robos
    |> Enum.map(fn {pos, speed} -> predict_position(pos, speed, @iter) end)
    |> Enum.map(fn {x, y} = pos -> {get_sector(pos), x, y} end)
    |> Enum.filter(fn {loc, _, _} -> loc != :none end)
    # |> IO.inspect()
    |> Enum.reduce(map, fn {loc, _, _}, acc ->
      elem(Map.get_and_update(acc, loc, fn x -> {x, x + 1} end), 1)
    end)
    |> IO.inspect()
    |> Map.values()
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  def create_grid(max_r, max_c) do
    List.duplicate(List.duplicate(~c".", max_c), max_r)
  end

  def print_grid(grid, i) do
    IO.puts("Iteration #{i} GRID")

    Enum.each(grid, fn row ->
      IO.puts(Enum.join(row, ""))
    end)

    :ok
  end

  def update_grid(grid, row, col, char) do
    List.update_at(grid, row, fn row_list ->
      List.replace_at(row_list, col, char)
    end)
  end

  def solve2 do
    list_of_robos =
      real_data()
      |> parse_data()

    # |> IO.inspect()

    max_iter = 10_000

    all_robo_positions =
      list_of_robos
      |> Enum.map(fn {pos, speed} -> predict_position(pos, speed, max_iter) end)

    Enum.map(Range.to_list(1..max_iter), fn i ->
      Enum.map(all_robo_positions, fn r -> Map.get(r, i) end)
    end)
    |> Enum.with_index()
    |> Enum.map(&check_day(&1))
    |> Enum.filter(fn {has, _, _, _} -> has end)
    |> Enum.map(fn {_, i, _robo_pos, grid} -> print_grid(grid, i) end)

    # |> IO.inspect()
    :ok
  end

  def check_day({robo_pos, i}) do
    # robo_pos = Enum.map(all_robo_pos, fn r -> Map.get(r, i) end)
    # IO.puts("Step #{i}")
    if rem(i, 1000) == 0, do: IO.inspect(i)

    grid =
      Enum.reduce(robo_pos, create_grid(@max_r, @max_c), fn {c, r}, acc ->
        update_grid(acc, r, c, "*")
      end)

    ls = Enum.map(grid, &Enum.join(&1, ""))
    has = Enum.any?(ls, &String.contains?(&1, "*************"))
    if has, do: IO.inspect(i)
    {has, i, robo_pos, grid}
  end

  def predict_position(current_position, {dc, dr} = _speed, iterations) do
    Enum.reduce(1..iterations, %{0 => current_position}, fn i, acc ->
      {c, r} = Map.get(acc, i - 1)
      new_position = {rem(c + dc + @max_c, @max_c), rem(r + dr + @max_r, @max_r)}
      # IO.inspect(["Iter", i, current_position, speed, new_position])
      Map.put_new(acc, i, new_position)
    end)
  end
end
