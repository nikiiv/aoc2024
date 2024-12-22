defmodule Day15 do
  def sample_data do
    """
    ##########
    #..O..O.O#
    #......O.#
    #.OO..O.O#
    #..O@..O.#
    #O#..O...#
    #O..O..O.#
    #.OO.O.OO#
    #....O...#
    ##########

    <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
    vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
    ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
    <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
    ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
    ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
    >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
    <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
    ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
    v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
    """
  end

  def real_data, do: File.read!("/Users/niki/aoc2024/input/day15.txt")

  def parse(data) do
    map = %{"<" => :left, "v" => :down, "^" => :up, ">" => :right}
    [maze, movements] = data |> String.split("\n\n", trim: true)
    maze = String.split(maze, "\n", trim: true) |> Enum.map(&String.graphemes/1)

    movements =
      String.split(movements, "\n")
      |> Enum.join("")
      |> String.graphemes()
      |> Enum.map(&Map.get(map, &1))

    {maze, movements}
  end

  def transpose(matrix) do
    matrix
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def rotate_up(matrix) do
    matrix
    |> Enum.reverse()
    |> transpose()
  end

  def rotate_down(matrix) do
    matrix
    |> transpose()
    |> Enum.reverse()
  end

  def rotate_mirror(matrix) do
    matrix
    |> Enum.map(&Enum.reverse/1)
    |> Enum.reverse()
  end

  def find_coordinate(matrix, target \\ "@") do
    # Enumerate rows with row_index
    Enum.with_index(matrix)
    |> Enum.find_value(fn {row, row_index} ->
      # Enumerate elements in the row with col_index
      row
      |> Enum.with_index()
      |> Enum.find_value(fn {char, col_index} ->
        if char == target, do: {row_index, col_index}, else: nil
      end)
    end)
  end

  def solve do
    {maze, movements} = real_data() |> parse()

    new_maze =
      Enum.reduce(movements, maze, fn op, maze ->
        # IO.inspect(op, label: "Operation")
        new_maze = move(maze, op)
        # IO.inspect(new_maze, label: "New Maze")
        new_maze
      end)

    new_maze
    # |> IO.inspect(label: "Final")
    |> Enum.with_index()
    |> Enum.map(fn {row, index} ->
      Enum.with_index(row)
      |> Enum.map(fn {el, rowi} ->
        if el == "O", do: rowi + 100 * index, else: 0
      end)
      |> IO.inspect()
      |> Enum.sum()
    end)
    |> IO.inspect()
    |> Enum.sum()
  end

  def move(maze, :up), do: maze |> rotate_up() |> move(:right) |> rotate_down()
  def move(maze, :down), do: maze |> rotate_down() |> move(:right) |> rotate_up()

  def move(maze, :left), do: maze |> rotate_mirror() |> move(:right) |> rotate_mirror()

  def move(maze, :right) do
    {row, pos} = find_coordinate(maze)
    l = Enum.at(maze, row)
    free = Enum.drop(l, pos + 1) |> Enum.find_index(&(&1 == "."))
    next_wall = Enum.drop(l, pos + 1) |> Enum.find_index(&(&1 == "#"))
    # IO.inspect({free, next_wall}, label: "Free/next")

    nl =
      if free < next_wall do
        free = free + pos

        mid = if free == pos, do: [], else: Enum.slice(l, (pos + 1)..free)

        Enum.take(l, pos) ++
          [".", "@"] ++ mid ++ Enum.drop(l, free + 2)
      else
        l
      end

    # IO.inspect([l, nl])
    List.replace_at(maze, row, nl)
  end
end
