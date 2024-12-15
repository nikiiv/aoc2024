defmodule Day12b do
  @moduledoc """
  Module for handling grid operations and perimeter walking algorithm.
  """

  @doc """
  Creates a new grid of specified rows and columns filled with '.' characters.
  Returns a list of lists representing the grid.
  """
  def create_grid(rows, cols) do
    for _row <- 1..rows do
      for _col <- 1..cols, do: "."
    end
  end

  @doc """
  Places a '*' character at the specified row and column in the grid.
  Returns the new grid with the modification.
  """
  def place_star(grid, row, col) when row >= 0 and col >= 0 do
    case Enum.at(grid, row) do
      nil ->
        # Return unchanged if row is out of bounds
        grid

      row_content ->
        case col < length(row_content) do
          true ->
            List.update_at(grid, row, fn row ->
              List.update_at(row, col, fn _x -> "*" end)
            end)

          false ->
            # Return unchanged if column is out of bounds
            grid
        end
    end
  end

  @doc """
  Helper function to display the grid.
  """
  def display_grid(grid) do
    grid
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  @doc """
  Walks around the perimeter of an enclosed area.
  Returns a list of tuples describing each step: {direction, {start_row, start_col}, {end_row, end_col}}
  """
  def walk_perimeter(grid) do
    # Find a starting point (first '*' we encounter)
    start_pos = find_start_position(grid)
    # Find an outside position adjacent to the start
    outside_start = find_outside_position(grid, start_pos)

    walk_perimeter(grid, outside_start, [], MapSet.new())
  end

  # Private helper functions

  defp walk_perimeter(grid, current_pos, steps, visited) do
    next_moves = get_possible_moves(grid, current_pos, visited)

    case next_moves do
      [] ->
        # If no more moves, we've completed the circuit
        steps

      [{direction, next_pos} | _] ->
        # Add this step to our path
        new_step = {direction, current_pos, next_pos}
        # Continue walking
        walk_perimeter(
          grid,
          next_pos,
          steps ++ [new_step],
          MapSet.put(visited, current_pos)
        )
    end
  end

  defp get_possible_moves(grid, {row, col}, visited) do
    [
      {"U", {row - 1, col}},
      {"R", {row, col + 1}},
      {"D", {row + 1, col}},
      {"L", {row, col - 1}}
    ]
    |> Enum.filter(fn {_, pos} ->
      # Position must be valid and not visited
      # Must have '*' adjacent to the path
      valid_position?(grid, pos) and not MapSet.member?(visited, pos) and
        has_adjacent_star?(grid, pos)
    end)
  end

  defp find_start_position(grid) do
    grid
    |> Enum.with_index()
    |> Enum.find_value(fn {row, row_idx} ->
      row
      |> Enum.with_index()
      |> Enum.find_value(fn
        {"*", col_idx} -> {row_idx, col_idx}
        _ -> nil
      end)
    end)
  end

  defp find_outside_position(grid, {row, col}) do
    # Check all adjacent positions for a non-'*' position
    [{row - 1, col}, {row, col + 1}, {row + 1, col}, {row, col - 1}]
    |> Enum.find(fn pos ->
      valid_position?(grid, pos) and get_cell(grid, pos) != "*"
    end)
  end

  defp valid_position?(grid, {row, col}) do
    row >= 0 and col >= 0 and row < length(grid) and col < length(hd(grid))
  end

  defp get_cell(grid, {row, col}) do
    grid |> Enum.at(row) |> Enum.at(col)
  end

  defp has_adjacent_star?(grid, {row, col}) do
    [{row - 1, col}, {row, col + 1}, {row + 1, col}, {row, col - 1}]
    |> Enum.any?(fn pos ->
      valid_position?(grid, pos) and get_cell(grid, pos) == "*"
    end)
  end

  def mark_path(grid, steps) do
    steps
    |> Enum.reduce(grid, fn {direction, {row, col}, _end}, acc_grid ->
      List.update_at(acc_grid, row, fn row ->
        List.update_at(row, col, fn _x -> direction end)
      end)
    end)
  end
end
