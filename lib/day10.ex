defmodule Day10 do
  @directions [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  # Parse a multiline string into a grid of integers
  def parse_grid(input) do
    input
    # Split by newline and trim empty lines
    |> String.split("\n", trim: true)
    # Convert each line into a list of integers
    |> Enum.map(&parse_row/1)
  end

  # Helper to parse a single row
  defp parse_row(row) do
    row
    # Split the string into individual characters
    |> String.graphemes()
    # Convert each character to an integer
    |> Enum.map(&String.to_integer/1)
  end

  # Main function to compute reachable 9s for all zeros in the grid
  def count_reachable_9s(grid) do
    for x <- 0..(length(grid) - 1),
        y <- 0..(length(Enum.at(grid, x)) - 1),
        Enum.at(grid, x) |> Enum.at(y) == 0,
        into: %{} do
      {{x, y}, bfs(grid, {x, y})}
    end
  end

  # Perform BFS from a given starting position
  defp bfs(grid, start) do
    queue = :queue.in(start, :queue.new())
    visited = MapSet.new([start])
    bfs_traverse(grid, queue, visited, 0)
  end

  defp bfs_traverse(grid, queue, visited, reachable_9s) do
    # Check if the queue is empty (instead of using a guard)
    if :queue.is_empty(queue) do
      reachable_9s
    else
      {{:value, {x, y}}, queue} = :queue.out(queue)
      current_value = Enum.at(grid, x) |> Enum.at(y)

      # Explore neighbors
      {queue, visited, reachable_9s} =
        Enum.reduce(@directions, {queue, visited, reachable_9s}, fn {dx, dy},
                                                                    {queue, visited, reachable_9s} ->
          nx = x + dx
          ny = y + dy

          if in_bounds?(grid, nx, ny) and not MapSet.member?(visited, {nx, ny}) do
            neighbor_value = Enum.at(grid, nx) |> Enum.at(ny)

            if neighbor_value == current_value + 1 do
              visited = MapSet.put(visited, {nx, ny})
              queue = :queue.in({nx, ny}, queue)

              # Increment the count if we reach a 9
              reachable_9s =
                if neighbor_value == 9, do: reachable_9s + 1, else: reachable_9s

              {queue, visited, reachable_9s}
            else
              {queue, visited, reachable_9s}
            end
          else
            {queue, visited, reachable_9s}
          end
        end)

      bfs_traverse(grid, queue, visited, reachable_9s)
    end
  end

  # Helper to check if a cell is within bounds
  defp in_bounds?(grid, x, y) do
    x >= 0 and x < length(grid) and y >= 0 and y < length(Enum.at(grid, x))
  end

  def example_1 do
    """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """
  end

  def solve_example_1, do: example_1() |> solve()

  def data do
    File.read!("/Users/niki/aoc2024/input/day10.txt")
  end

  def solve_1 do
    data()
    |> solve()
  end

  def solve(input) do
    grid = Day10.parse_grid(input)
    IO.inspect(grid, label: "Parsed Grid")

    result = Day10.count_reachable_9s(grid)
    IO.inspect(result, label: "Reachable 9s")
    Map.values(result) |> Enum.sum()
  end
end
