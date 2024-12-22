defmodule Day18 do
  @moduledoc """
  A module to solve a maze problem with obstacles and find the shortest path.
  """

  @doc """
  Creates a grid of dimensions max_c x max_r filled with `.`.
  """
  def create_grid(max_c, max_r) do
    for _ <- 0..max_r, do: List.duplicate(".", max_c + 1)
  end

  @doc """
  Parses the obstacles from a multiline string and returns them as a set of tuples.
  Only the first max_o obstacles are used.
  """
  def parse_obstacles(obstacles_str) do
    obstacles_str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  @doc """
  Places obstacles into the grid.
  """
  def place_obstacles(grid, obstacles) do
    Enum.reduce(obstacles, grid, fn {x, y}, acc ->
      List.update_at(acc, y, fn row ->
        List.replace_at(row, x, "#")
      end)
    end)
  end

  @doc """
  Places the path into the grid by marking visited cells with `0`.
  """
  def place_path(grid, path) do
    Enum.reduce(path, grid, fn {x, y}, acc ->
      List.update_at(acc, y, fn row ->
        List.replace_at(row, x, "0")
      end)
    end)
  end

  @doc """
  Prints the grid.
  """
  def print_grid(grid) do
    Enum.each(grid, &IO.puts(Enum.join(&1)))
  end

  @doc """
  Finds the shortest path in the maze from (0, 0) to (max_c, max_r) using Dijkstra's algorithm.

  ## Parameters:
    - max_c: maximum column index (inclusive)
    - max_r: maximum row index (inclusive)
    - obstacles: a set of tuples representing obstacle coordinates

  Returns a list of coordinates representing the shortest path or :no_path if no path exists.
  """
  def shortest_path(max_c, max_r, obstacles) do
    start = {0, 0}
    goal = {max_c, max_r}

    case dijkstra(
           %{start => 0},
           %{start => nil},
           MapSet.new([start]),
           goal,
           obstacles,
           max_c,
           max_r
         ) do
      :no_path -> :no_path
      path -> Enum.reverse(path)
    end
  end

  defp dijkstra(distances, previous_nodes, visited, goal, obstacles, max_c, max_r) do
    if Map.has_key?(distances, goal) do
      reconstruct_path(previous_nodes, goal)
    else
      if Map.keys(distances) == [] do
        :no_path
      else
        {current, current_dist} = Enum.min_by(distances, fn {_node, dist} -> dist end)

        distances = Map.delete(distances, current)
        visited = MapSet.put(visited, current)

        neighbors =
          valid_neighbors(current, max_c, max_r, obstacles, visited)

        {distances, previous_nodes} =
          Enum.reduce(neighbors, {distances, previous_nodes}, fn neighbor,
                                                                 {distances, previous_nodes} ->
            tentative_distance = current_dist + 1

            if tentative_distance < Map.get(distances, neighbor, :infinity) do
              {
                Map.put(distances, neighbor, tentative_distance),
                Map.put(previous_nodes, neighbor, current)
              }
            else
              {distances, previous_nodes}
            end
          end)

        dijkstra(distances, previous_nodes, visited, goal, obstacles, max_c, max_r)
      end
    end
  end

  defp reconstruct_path(previous_nodes, goal) do
    Enum.reverse(do_reconstruct_path(previous_nodes, goal, []))
  end

  defp do_reconstruct_path(_previous_nodes, nil, path), do: path

  defp do_reconstruct_path(previous_nodes, current, path) do
    do_reconstruct_path(previous_nodes, Map.get(previous_nodes, current), [current | path])
  end

  defp valid_neighbors({x, y}, max_c, max_r, obstacles, visited) do
    directions = [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]

    directions
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.filter(fn {nx, ny} ->
      nx >= 0 and ny >= 0 and nx <= max_c and ny <= max_r and
        not MapSet.member?(obstacles, {nx, ny}) and
        not MapSet.member?(visited, {nx, ny})
    end)
  end

  def get_sample_data do
    obstacles_str = """
    5,4
    4,2
    4,5
    3,0
    2,1
    6,3
    2,4
    1,5
    0,6
    3,3
    2,6
    5,1
    1,2
    5,5
    2,5
    6,5
    1,4
    0,4
    6,4
    1,1
    6,1
    1,0
    0,5
    1,6
    2,0
    """

    max_c = 6
    max_r = 6
    max_o = 12
    {obstacles_str, max_c, max_r, max_o}
  end

  def get_real_data do
    obstacles_str = File.read!("/Users/niki/aoc2024/input/day18.txt")
    max_c = 70
    max_r = 70
    max_o = 1024
    {obstacles_str, max_c, max_r, max_o}
  end

  def find_imp(_path, _, _, []), do: :all_clear

  def find_imp(max_c, max_r, working_obstacles, [h | t]) do
    new_obstacles = MapSet.put(working_obstacles, h)
    path = shortest_path(max_c, max_r, new_obstacles)

    if path != :no_path,
      do: find_imp(max_c, max_r, new_obstacles, t),
      else: h |> IO.inspect(label: "Deal breaker")
  end

  def solution do
    {obstacles_str, max_c, max_r, max_o} = get_real_data()
    obstacles = Day18.parse_obstacles(obstacles_str)
    working_obstacles = Enum.take(obstacles, max_o) |> MapSet.new()
    IO.puts("Size of obstacles #{MapSet.size(working_obstacles)}")

    rem_obst =
      Enum.drop(obstacles, max_o)

    IO.inspect(length(rem_obst), label: "Size of remaining obstacles")
    IO.inspect(length(obstacles), label: "Size of all obstacles")
    # grid = Day18.create_grid(max_c, max_r)
    # grid_with_obstacles = Day18.place_obstacles(grid, MapSet.to_list(working_obstacles))

    # Day18.print_grid(grid_with_obstacles)

    path = Day18.shortest_path(max_c, max_r, working_obstacles)
    IO.puts("Shortest Path: #{inspect(path)}")

    if path != :no_path do
      IO.puts("Path Length: #{length(path) - 1}")
      # grid_with_path = Day18.place_path(grid_with_obstacles, path)
      # IO.puts("Grid with Path:")
      # Day18.print_grid(grid_with_path)

      # |> IO.inspect(label: "Remaining obstacles")

      Day18.find_imp(max_c, max_r, working_obstacles, rem_obst) |> IO.inspect(label: "First hit")
    else
      IO.puts("No Path Found")
    end
  end
end
