defmodule Day12 do
  @moduledoc """
  A module for parsing and manipulating a rectangular grid represented as a multiline string.
  """

  @doc """
  Parses a multiline string into a grid structure (list of lists).
  """
  def parse(grid_string) do
    grid_string
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  @doc """
  Prints the grid in a readable format.
  """
  def print(grid) do
    grid
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.each(&IO.puts/1)
  end

  @doc """
  Returns all unique letters in the grid.
  """
  def unique_letters(grid) do
    grid
    |> List.flatten()
    |> Enum.uniq()
  end

  @doc """
  Returns all coordinates of a specific letter in the grid.
  Coordinates are in the form {row, col} (0-indexed).
  """
  def coordinates_of(grid, letter) do
    for {row, row_index} <- Enum.with_index(grid),
        {cell, col_index} <- Enum.with_index(row),
        cell == letter,
        do: {row_index, col_index}
  end

  @doc """
  Returns the letter at the given coordinates.
  If the coordinates are outside the grid, returns ".".
  """
  def letter_at(grid, {row, col}) do
    if row < 0 or col < 0 or row >= length(grid) or col >= length(Enum.at(grid, row, [])) do
      "."
    else
      Enum.at(Enum.at(grid, row), col)
    end
  end

  @doc """
  For a given coordinate, returns the total number of neighbors that are different from the letter
  at that coordinate. Neighbors are checked to the left, up, right, and down. Out-of-bound neighbors
  are counted as different.
  """
  def different_neighbors(grid, {row, col}) do
    letter = letter_at(grid, {row, col})

    neighbors = [
      # left
      {row, col - 1},
      # up
      {row - 1, col},
      # right
      {row, col + 1},
      # down
      {row + 1, col}
    ]

    Enum.count(neighbors, fn neighbor ->
      letter_at(grid, neighbor) != letter
    end)
  end

  @doc """
  Detects and returns all regions of neighboring letters for a specific letter.
  Each region is a list of coordinates that are connected by sides.
  """
  def neighboring_regions(grid, letter) do
    all_coordinates = coordinates_of(grid, letter)

    Enum.reduce(all_coordinates, {[], MapSet.new()}, fn coord, {regions, visited} ->
      if MapSet.member?(visited, coord) do
        {regions, visited}
      else
        region = explore_region_r(grid, letter, coord, MapSet.new())
        {[region | regions], MapSet.union(visited, MapSet.new(region))}
      end
    end)
    |> elem(0)
  end

  defp explore_region_r(grid, letter, coord, visited) do
    if MapSet.member?(visited, coord) or letter_at(grid, coord) != letter do
      visited
    else
      neighbors = [
        # left
        {elem(coord, 0), elem(coord, 1) - 1},
        # up
        {elem(coord, 0) - 1, elem(coord, 1)},
        # right
        {elem(coord, 0), elem(coord, 1) + 1},
        # down
        {elem(coord, 0) + 1, elem(coord, 1)}
      ]

      Enum.reduce(neighbors, MapSet.put(visited, coord), fn neighbor, acc ->
        explore_region(grid, letter, neighbor, acc)
      end)
    end
  end

  @doc """
  For a given coordinate, recursively finds all elements of the same letter that are next to each other.
  Returns the list of coordinates sorted by row and then by column.
  """
  def find_regions(grid, {row, col}) do
    letter = letter_at(grid, {row, col})

    if letter == "." do
      []
    else
      explore_region(grid, letter, {row, col}, MapSet.new())
      |> MapSet.to_list()
      |> Enum.sort()
    end
  end

  defp explore_region(grid, letter, coord, visited) do
    if MapSet.member?(visited, coord) or letter_at(grid, coord) != letter do
      visited
    else
      neighbors = [
        # left
        {elem(coord, 0), elem(coord, 1) - 1},
        # up
        {elem(coord, 0) - 1, elem(coord, 1)},
        # right
        {elem(coord, 0), elem(coord, 1) + 1},
        # down
        {elem(coord, 0) + 1, elem(coord, 1)}
      ]

      # IO.inspect(visited)

      Enum.reduce(neighbors, MapSet.put(visited, coord), fn neighbor, acc ->
        explore_region(grid, letter, neighbor, acc)
      end)
    end
  end

  def solve do
    grid = example1() |> parse()
    letters = unique_letters(grid)

    _res =
      Enum.map(letters, fn l -> handle_letter(grid, l) end)
      |> Enum.flat_map(fn inner_list -> inner_list end)
      |> IO.inspect()
      |> Enum.map(&elem(&1, 3))
      |> Enum.sum()

    # IO.inspect(res)
    # res |> Enum.map(fn {_, pr} -> pr end) |> Enum.sum()
  end

  def handle_letter(grid, letter) do
    # IO.inspect(letter, label: "Handling letter")

    neighboring_regions(grid, letter)
    |> Enum.map(&MapSet.to_list/1)
    |> Enum.map(&process_region(grid, &1, letter))

    # |> Enum.flat_map(fn x -> x end)

    # |> IO.inspect()
  end

  def process_region(grid, coords, letter) do
    # IO.inspect(coords, label: "coordinates")
    area = coords |> Enum.count()
    perimeter = Enum.map(coords, fn c -> different_neighbors(grid, c) end) |> Enum.sum()
    {letter, area, perimeter, area * perimeter}
  end

  def example1 do
    """
    RRRRIICCFF
    RRRRIICCCF
    VVRRRCCFFF
    VVRCCCJFFF
    VVVVCJJCFE
    VVIVCCJJEE
    VVIIICJJEE
    MIIIIIJJEE
    MIIISIJEEE
    MMMISSJEEE
    """
  end
end
