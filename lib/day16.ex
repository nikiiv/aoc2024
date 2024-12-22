defmodule Day16 do
  @directions [
    {:up, {-1, 0}},
    {:down, {1, 0}},
    {:left, {0, -1}},
    {:right, {0, 1}}
  ]

  def solve(maze_string) do
    maze = parse_maze(maze_string)
    {start, end_pos} = find_positions(maze)
    shortest_paths = dijkstra(maze, start, end_pos)
    # shortest_paths is a list of {path, cost}
    # Each path is in reverse order of how it was built; the first direction appended is at the head.
    # We'll return them as is; the caller can handle order.
    {maze, start, shortest_paths}
  end

  # Converts all final shortest paths into visited coordinates
  def final_paths_to_coordinates(maze_string) do
    {maze, start, shortest_paths} = solve(maze_string)

    # Convert each path (which is currently reversed) into forward order and then to coordinates
    visited_coordinates_per_path =
      Enum.map(shortest_paths, fn {path, _cost} ->
        path = Enum.reverse(path)
        path_to_coordinates(maze, start, path)
      end)

    visited_coordinates_per_path
  end

  # If you want a combined set of all visited coordinates across all shortest paths:
  def all_visited_coordinates(maze_string) do
    visited_coordinates_per_path = final_paths_to_coordinates(maze_string)

    visited_coordinates_per_path
    |> Enum.flat_map(& &1)
    |> Enum.uniq()
  end

  defp parse_maze(maze_string) do
    maze_string
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp find_positions(maze) do
    start = find_char_position(maze, "S")
    end_pos = find_char_position(maze, "E")
    {start, end_pos}
  end

  defp find_char_position(maze, char) do
    Enum.with_index(maze)
    |> Enum.reduce(nil, fn {row, i}, acc ->
      case Enum.find_index(row, &(&1 == char)) do
        nil -> acc
        j -> {i, j}
      end
    end)
  end

  # Dijkstra's algorithm to find all shortest paths
  defp dijkstra(maze, start, end_pos) do
    initial_state = %{pos: start, cost: 0, path: [], direction: nil}
    queue = :gb_sets.singleton({0, initial_state})
    visited = MapSet.new()
    solutions = []
    dijkstra_loop(maze, queue, end_pos, visited, solutions)
  end

  defp dijkstra_loop(maze, queue, end_pos, visited, solutions) do
    if :gb_sets.is_empty(queue) do
      solutions
    else
      {{cost, state}, queue} = :gb_sets.take_smallest(queue)
      %{pos: current_pos, path: path, direction: direction} = state

      if current_pos == end_pos do
        solutions =
          cond do
            solutions == [] -> [{path, cost}]
            cost < elem(hd(solutions), 1) -> [{path, cost}]
            cost == elem(hd(solutions), 1) -> [{path, cost} | solutions]
            true -> solutions
          end

        dijkstra_loop(maze, queue, end_pos, visited, solutions)
      else
        if MapSet.member?(visited, {current_pos, direction}) do
          dijkstra_loop(maze, queue, end_pos, visited, solutions)
        else
          new_visited = MapSet.put(visited, {current_pos, direction})

          neighbors =
            Enum.flat_map(@directions, fn {dir, {dx, dy}} ->
              next_pos = {elem(current_pos, 0) + dx, elem(current_pos, 1) + dy}
              next_cost = move_cost(direction, dir, cost, path)
              if valid_move?(maze, next_pos), do: [{next_cost, dir, next_pos}], else: []
            end)

          new_queue =
            Enum.reduce(neighbors, queue, fn {new_cost, dir, pos}, acc ->
              new_state = %{pos: pos, cost: new_cost, path: [dir | path], direction: dir}
              :gb_sets.add({new_cost, new_state}, acc)
            end)

          dijkstra_loop(maze, new_queue, end_pos, new_visited, solutions)
        end
      end
    end
  end

  defp move_cost(nil, dir, cost, []) when dir != :left, do: cost + 1001 + 1000
  defp move_cost(nil, _dir, cost, []), do: cost + 1
  defp move_cost(last_dir, last_dir, cost, _), do: cost + 1
  defp move_cost(_last_dir, _new_dir, cost, _), do: cost + 1001

  defp valid_move?(maze, {x, y}) do
    x >= 0 and y >= 0 and x < length(maze) and y < length(Enum.at(maze, 0)) and
      Enum.at(Enum.at(maze, x), y) in [".", "E"]
  end

  # Convert a path of directions into a list of visited coordinates
  defp path_to_coordinates(_maze, start, directions) do
    IO.inspect(start, label: "Starting point")
    # Starting from the start position, apply each direction
    Enum.scan(directions, start, fn dir, {x, y} ->
      case dir do
        :up -> {x - 1, y}
        :down -> {x + 1, y}
        :left -> {x, y - 1}
        :right -> {x, y + 1}
      end
    end)
    |> IO.inspect(label: "Res")
    |> Enum.uniq()
    |> Enum.count()
    |> IO.inspect()
    |> then(&(&1 + 1))
  end

  def example do
    # Example maze
    maze = """
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
    """

    # Solve the maze
    final_paths_to_coordinates(maze)
  end

  def solve,
    do:
      File.read!("/Users/niki/aoc2024/input/day17.txt")
      |> final_paths_to_coordinates()
end
