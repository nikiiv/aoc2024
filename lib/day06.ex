defmodule Day06GridParser do
  defstruct grid: %{}, width: 0, height: 0, caret: nil, steps: 1, stops_hit: 0, total_steps: 0

  def parse_file(file_path) do
    {:ok, content} = File.read(file_path)
    lines = String.split(content, "\n", trim: true)

    height = length(lines)
    width = String.length(List.first(lines))

    {grid, caret} =
      lines
      |> Enum.with_index()
      |> Enum.reduce({%{}, nil}, fn {line, y}, {acc, caret} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({acc, caret}, fn {char, x}, {acc, caret} ->
          new_caret = if char == "^", do: {x, height - y - 1}, else: caret
          {Map.put(acc, {x, height - y - 1}, char), new_caret}
        end)
      end)

    %__MODULE__{
      grid: grid,
      width: width,
      height: height,
      caret: caret,
      steps: 1,
      stops_hit: 0,
      total_steps: 0
    }
  end

  def get_character(%__MODULE__{grid: grid}, {x, y}) do
    Map.get(grid, {x, y}, nil)
  end

  def caret_coordinates(%__MODULE__{caret: caret}), do: caret

  def print_grid(%__MODULE__{grid: grid, width: width, height: height}) do
    for y <- (height - 1)..0 do
      for x <- 0..(width - 1) do
        IO.write(Map.get(grid, {x, y}, " "))
      end

      # Move to the next line after each row
      IO.puts("")
    end
  end

  def change_character(%__MODULE__{grid: grid} = state, {x, y}, new_char) do
    # Ensure the coordinates are within the bounds of the grid
    if Map.has_key?(grid, {x, y}) do
      updated_grid = Map.put(grid, {x, y}, new_char)
      %__MODULE__{state | grid: updated_grid}
    else
      raise ArgumentError, "Invalid coordinates: {#{x}, #{y}}"
    end
  end
end

defmodule Day06 do
  @directions [up: {0, +1}, right: {+1, 0}, down: {0, -1}, left: {-1, 0}]

  def get_test_grid, do: Day06GridParser.parse_file("/Users/niki/aoc2024/input/mini_day06.txt")
  def get_step1_grid, do: Day06GridParser.parse_file("/Users/niki/aoc2024/input/day06.txt")

  def get_next_direction(direction) do
    curr_dir = Enum.find_index(@directions, fn x -> elem(x, 0) == direction end)

    case curr_dir do
      3 -> Enum.at(@directions, 0)
      _ -> Enum.at(@directions, curr_dir + 1)
    end
  end

  def solve1 do
    curr_direction = List.first(@directions)
    grid = get_step1_grid()
    grid = Day06GridParser.change_character(grid, grid.caret, "X")
    go_to_next_step(grid, curr_direction)
  end

  def go_to_next_step(grid, _)
      when grid.stops_hit == 5 or grid.total_steps > grid.width * grid.height,
      do: true

  def go_to_next_step(grid, curr_dir) do
    next_coord = compute_next_coord(grid, curr_dir)
    next_position = Day06GridParser.get_character(grid, next_coord)
    direction = elem(curr_dir, 0)

    # IO.inspect([
    #   next_position,
    #   grid.caret,
    #   "->",
    #   next_coord,
    #   curr_dir,
    #   grid.steps,
    #   grid.stops_hit,
    #   "Total_Steps: ",
    #   grid.total_steps
    # ])

    case next_position do
      "." ->
        new_grid = %{grid | steps: grid.steps + 1, caret: next_coord}
        new_grid = Day06GridParser.change_character(new_grid, new_grid.caret, "X")
        go_to_next_step(new_grid, curr_dir)

      "X" ->
        new_grid = %{grid | total_steps: grid.total_steps + 1, caret: next_coord}
        go_to_next_step(new_grid, curr_dir)

      "#" ->
        go_to_next_step(grid, get_next_direction(direction))

      "O" ->
        new_grid = %{grid | stops_hit: grid.stops_hit + 1}
        go_to_next_step(new_grid, get_next_direction(direction))

      nil ->
        # Day06GridParser.print_grid(grid)
        # IO.inspect([grid.width, grid.height])
        grid.steps
    end
  end

  def compute_next_coord(grid, curr_dir) do
    caret = grid.caret
    # IO.inspect(["compute_next_coord", curr_dir, caret])
    {x, y} = caret
    {_dir, {dif_x, dif_y}} = curr_dir

    # IO.puts("Elem #{inspect(dif_x)}, #{inspect(dif_y)}")
    new_x = x + dif_x
    new_y = y + dif_y
    {new_x, new_y}
  end

  def solve2 do
    grid = get_step1_grid()
    # grid = get_test_grid()
    grid = Day06GridParser.change_character(grid, grid.caret, "X")

    potential_stoppers =
      for x <- 0..grid.width,
          y <- 0..grid.height,
          do: {x, y}

    potential_stoppers =
      potential_stoppers
      |> Enum.filter(fn x -> Day06GridParser.get_character(grid, x) in [".", "^"] end)

    Enum.filter(potential_stoppers, fn stopper -> is_stopper(grid, stopper) end)
    |> Enum.count()
  end

  def is_stopper(grid, stopper) do
    {x, y} = stopper
    z = (x + 1) * 130 + (y + 1)
    IO.puts("Stopper #{inspect(stopper)} for count #{inspect(z)}")
    if rem(x, 100) == 10, do: IO.inspect(["Step ", z])
    curr_direction = List.first(@directions)

    tmp_grid =
      Day06GridParser.change_character(grid, stopper, "O")

    new_grid = Day06GridParser.change_character(tmp_grid, tmp_grid.caret, "X")

    case(go_to_next_step(new_grid, curr_direction)) do
      true -> true
      _ -> false
    end
  end

  def zz do
    grid = get_step1_grid()
    is_stopper(grid, {5, 41})
  end
end
