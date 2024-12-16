defmodule Day17 do
  @directions [
    {:up, {-1, 0}},
    {:down, {1, 0}},
    {:left, {0, -1}},
    {:right, {0, 1}}
  ]

  # Main function to solve the maze
  def solve(maze_string) do
    maze = parse_maze(maze_string)
    {start, end_pos} = find_positions(maze)
    dijkstra(maze, start, end_pos)
  end

  # Parse the multiline string into a 2D list
  defp parse_maze(maze_string) do
    maze_string
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  # Find the start (S) and end (E) positions in the maze
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

  # Dijkstra's algorithm to find the shortest path with weights
  defp dijkstra(maze, start, end_pos) do
    initial_state = %{pos: start, cost: 0, path: [], direction: nil}
    # Min-priority queue
    queue = :gb_sets.singleton({0, initial_state})
    visited = MapSet.new()

    dijkstra_loop(maze, queue, end_pos, visited)
  end

  defp dijkstra_loop(maze, queue, end_pos, visited) do
    # Stop if queue is empty
    if :gb_sets.is_empty(queue) do
      {:no_solution, nil}
    else
      # Safe extraction of the smallest element
      {{cost, state}, queue} = :gb_sets.take_smallest(queue)

      %{pos: current_pos, path: path, direction: direction} = state

      # Return the solution if we reached the end
      if current_pos == end_pos do
        {Enum.reverse(path), cost}
      else
        # Mark the current position with direction as visited
        if MapSet.member?(visited, {current_pos, direction}) do
          dijkstra_loop(maze, queue, end_pos, visited)
        else
          new_visited = MapSet.put(visited, {current_pos, direction})

          # Explore neighbors and update the priority queue
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

          dijkstra_loop(maze, new_queue, end_pos, new_visited)
        end
      end
    end
  end

  # Calculate the cost for a move
  defp move_cost(nil, dir, cost, []) when dir != :left, do: cost + 1001
  defp move_cost(nil, dir, cost, []), do: cost + 1
  defp move_cost(last_dir, last_dir, cost, _), do: cost + 1
  defp move_cost(_last_dir, _new_dir, cost, _), do: cost + 1001

  # Check if the move is valid
  defp valid_move?(maze, {x, y}) do
    x >= 0 and y >= 0 and x < length(maze) and y < length(Enum.at(maze, 0)) and
      Enum.at(Enum.at(maze, x), y) in [".", "E"]
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
    {shortest_path, total_cost} = Day17.solve(maze)

    IO.inspect(shortest_path, label: "Shortest Scored Path")
    IO.inspect(total_cost, label: "Score of Shortest Path")
  end

  def solve,
    do: File.read!("/Users/niki/aoc2024/input/day17.txt") |> Day17.solve()
end
