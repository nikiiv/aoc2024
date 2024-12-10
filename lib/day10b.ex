defmodule Day10b do
  @directions [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  def parse_grid(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_row/1)
  end

  defp parse_row(row) do
    row
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  def count_reachable_9s(grid) do
    for x <- 0..(length(grid) - 1),
        y <- 0..(length(Enum.at(grid, x)) - 1),
        Enum.at(grid, x) |> Enum.at(y) == 0,
        into: %{} do
      {{x, y}, bfs(grid, {x, y})}
    end
  end

  # BFS start
  defp bfs(grid, start) do
    queue = :queue.in(start, :queue.new())
    visited = MapSet.new([start])
    bfs_traverse(grid, queue, visited, 0)
  end

  defp bfs_traverse(grid, queue, visited, reachable_9s) do
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

          if in_bounds?(grid, nx, ny) do
            neighbor_value = Enum.at(grid, nx) |> Enum.at(ny)

            # Allow multiple paths to revisit 9s
            if neighbor_value == current_value + 1 do
              queue = :queue.in({nx, ny}, queue)
              visited = MapSet.put(visited, {nx, ny})

              reachable_9s =
                if neighbor_value == 9 do
                  reachable_9s + 1
                else
                  reachable_9s
                end

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

  def example do
    # Example usage
    input = Day10.example_1()

    grid = Day10b.parse_grid(input)
    IO.inspect(grid, label: "Parsed Grid")

    result = Day10b.count_reachable_9s(grid)
    IO.inspect(result, label: "Reachable 9s")
  end

  def solve do
    grid = Day10b.parse_grid(Day10.data())
    IO.inspect(grid, label: "Parsed Grid")

    result = Day10b.count_reachable_9s(grid)
    IO.inspect(result, label: "Reachable 9s")
    result |> Map.values() |> Enum.sum()
  end
end
