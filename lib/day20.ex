defmodule Day20.MazeSolver do
  @moduledoc """
  A module to parse a maze, find a path from Start (S) to End (E),
  and perform alterations to improve the path.
  """

  @doc """
  The main function to execute the maze parsing, path finding, and alterations.
  """
  def run do
    _maze_sample = """
    ###############
    #...#...#.....#
    #.#.#.#.#.###.#
    #S#...#.#.#...#
    #######.#.#.###
    #######.#.#...#
    #######.#.###.#
    ###..E#...#...#
    ###.#######.###
    #...###...#...#
    #.#####.#.###.#
    #.#...#.#.#...#
    #.#.#.#.#.#.###
    #...#...#...###
    ###############
    """

    maze = File.read!("/Users/niki/aoc2024/input/day20.txt")

    # Step 1: Parse the maze into a grid
    grid = parse_maze(maze)

    # Step 2: Identify Start (S) and End (E) coordinates
    case find_start_end(grid) do
      {:error, message} ->
        IO.puts("Error: #{message}")

      {start_coord, end_coord} ->
        IO.puts("Start (S) found at: #{inspect(start_coord)}")
        IO.puts("End (E) found at: #{inspect(end_coord)}\n")

        # Step 3: Find the base path from Start to End
        base_path = bfs(grid, start_coord, end_coord)

        if base_path == [] do
          IO.puts("No path found from S to E. Cannot perform alterations.")
        else
          base_length = length(base_path)
          IO.puts("Base Path found! Path length: #{base_length}\n")

          # Step 4: Identify candidate bricks
          candidate_bricks = find_candidate_bricks(grid)
          total_candidates = length(candidate_bricks)
          IO.puts("Number of candidate bricks for alteration: #{total_candidates}\n")

          # Step 5: Perform alterations and evaluate paths
          qualifying_alterations =
            candidate_bricks
            |> Enum.map(fn brick ->
              altered_grid = Map.put(grid, brick, ".")
              altered_path = bfs(altered_grid, start_coord, end_coord)
              path_length = length(altered_path)
              difference = base_length - path_length
              {brick, path_length, difference}
            end)
            |> Enum.filter(fn {_brick, path_length, _difference} ->
              path_length > 0 and path_length < base_length
            end)
            |> Enum.sort_by(fn {_brick, _path_length, difference} -> -difference end)

          # Step 6: Print results
          if qualifying_alterations == [] do
            IO.puts("No alterations found that shorten the path.")
          else
            IO.puts("Qualifying Alterations (shorten path):\n")

            filtered =
              Enum.filter(qualifying_alterations, fn {_brick, _path_length, difference} ->
                difference >= 100
              end)

            filtered
            |> Enum.each(fn {brick, path_length, difference} ->
              IO.puts(
                "Brick at #{inspect(brick)} removed. Path length: #{path_length} (saved #{difference} steps)"
              )
            end)

            IO.puts("Total alterations #{length(filtered)}")
          end
        end
    end
  end

  @doc """
  Parses the maze string into a grid map.

  ## Parameters
    - maze: A multiline string representing the maze.

  ## Returns
    - A map with keys as {x, y} tuples and values as cell types.
  """
  def parse_maze(maze) do
    maze
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, x}, inner_acc ->
        Map.put(inner_acc, {x, y}, char)
      end)
    end)
  end

  @doc """
  Finds the coordinates of Start (S) and End (E) in the grid.

  ## Parameters
    - grid: The maze grid map.

  ## Returns
    - A tuple {start_coord, end_coord} if both are found.
    - {:error, message} if either is missing.
  """
  def find_start_end(grid) do
    start_coords =
      Enum.filter(grid, fn {_k, v} -> v == "S" end)
      |> Enum.map(fn {k, _v} -> k end)

    end_coords =
      Enum.filter(grid, fn {_k, v} -> v == "E" end)
      |> Enum.map(fn {k, _v} -> k end)

    cond do
      length(start_coords) == 0 and length(end_coords) == 0 ->
        {:error, "Start (S) and End (E) positions not found in the maze."}

      length(start_coords) == 0 ->
        {:error, "Start (S) position not found in the maze."}

      length(end_coords) == 0 ->
        {:error, "End (E) position not found in the maze."}

      length(start_coords) > 1 or length(end_coords) > 1 ->
        {:error, "Multiple Start (S) or End (E) positions found in the maze."}

      true ->
        {hd(start_coords), hd(end_coords)}
    end
  end

  @doc """
  Performs Breadth-First Search (BFS) to find the shortest path from Start to End.

  ## Parameters
    - grid: The maze grid map.
    - start_coord: The starting coordinate {x, y}.
    - end_coord: The ending coordinate {x, y}.

  ## Returns
    - A list of coordinates representing the path from Start to End.
    - Returns an empty list if no path is found.
  """
  def bfs(grid, start_coord, end_coord) do
    # Initialize BFS
    queue = :queue.in(start_coord, :queue.new())
    visited = Map.put(%{}, start_coord, nil)

    # Begin BFS
    visited = bfs_loop(grid, end_coord, queue, visited)

    reconstruct_path(visited, end_coord)
  end

  # Recursive BFS loop
  defp bfs_loop(grid, end_coord, queue, visited) do
    if :queue.is_empty(queue) do
      # No path found
      visited
    else
      {{:value, current}, queue_rest} = :queue.out(queue)

      if current == end_coord do
        # End found, return visited map for path reconstruction
        visited
      else
        # Explore neighbors
        neighbors = get_neighbors(current, grid)

        {new_queue, new_visited} =
          Enum.reduce(neighbors, {queue_rest, visited}, fn neighbor, {q, v} ->
            if not Map.has_key?(v, neighbor) do
              {:queue.in(neighbor, q), Map.put(v, neighbor, current)}
            else
              {q, v}
            end
          end)

        # Continue BFS
        bfs_loop(grid, end_coord, new_queue, new_visited)
      end
    end
  end

  @doc """
  Reconstructs the path from the visited map.

  ## Parameters
    - visited: The visited map from BFS, mapping coordinates to their predecessors.
    - end_coord: The ending coordinate {x, y}.

  ## Returns
    - A list of coordinates from Start to End.
    - Returns an empty list if the end was not reached.
  """
  def reconstruct_path(visited, end_coord) do
    if Map.has_key?(visited, end_coord) do
      traverse_path(visited, end_coord, [])
      |> Enum.reverse()
    else
      []
    end
  end

  # Helper function to traverse back from end to start
  defp traverse_path(visited, current, path) do
    predecessor = Map.get(visited, current)

    if predecessor == nil do
      [current | path]
    else
      traverse_path(visited, predecessor, [current | path])
    end
  end

  @doc """
  Retrieves valid neighboring coordinates (up, down, left, right) that are open.

  ## Parameters
    - coord: The current coordinate {x, y}.
    - grid: The maze grid map.

  ## Returns
    - A list of neighboring coordinates that are traversable.
  """
  def get_neighbors({x, y}, grid) do
    potential_neighbors = [
      # Up
      {x, y - 1},
      # Down
      {x, y + 1},
      # Left
      {x - 1, y},
      # Right
      {x + 1, y}
    ]

    potential_neighbors
    |> Enum.filter(fn coord ->
      case Map.get(grid, coord, "#") do
        # Wall
        "#" -> false
        # Open space (including S, E, and any other characters)
        _ -> true
      end
    end)
  end

  @doc """
  Identifies candidate bricks that can be altered.

  A candidate brick is a wall (`#`) that has both free cells either up and down or left and right.

  ## Parameters
    - grid: The maze grid map.

  ## Returns
    - A list of coordinates representing candidate bricks.
  """
  def find_candidate_bricks(grid) do
    Enum.filter(grid, fn {_coord, cell} ->
      cell == "#"
    end)
    |> Enum.map(fn {coord, _cell} -> coord end)
    |> Enum.filter(fn {x, y} ->
      # Check if both up and down are free
      up_free = Map.get(grid, {x, y - 1}, "#") != "#"
      down_free = Map.get(grid, {x, y + 1}, "#") != "#"

      # Check if both left and right are free
      left_free = Map.get(grid, {x - 1, y}, "#") != "#"
      right_free = Map.get(grid, {x + 1, y}, "#") != "#"

      (up_free and down_free) or (left_free and right_free)
    end)
  end
end
