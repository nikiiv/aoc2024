defmodule Day08.Solver do
  defstruct grid: %{}, width: 0, height: 0

  @doc """
  Parses a multi-line string into a grid structure, with coordinates starting from the lower-left corner (0, 0).
  """
  def parse(input) do
    lines = String.split(input, "\n", trim: true)

    height = length(lines)
    width = lines |> Enum.map(&String.length/1) |> Enum.max()

    grid =
      for {line, y} <- Enum.with_index(lines),
          {char, x} <- Enum.with_index(String.graphemes(line)),
          into: %{},
          do: {{x, height - 1 - y}, char}

    %__MODULE__{grid: grid, width: width, height: height}
  end

  @doc """
  Creates an empty canvas grid (all dots) with the same size as the given grid.
  """
  def empty_canvas(%__MODULE__{width: width, height: height}) do
    grid =
      for x <- 0..(width - 1),
          y <- 0..(height - 1),
          into: %{},
          do: {{x, y}, "."}

    %__MODULE__{grid: grid, width: width, height: height}
  end

  @doc """
  Checks if a candidate is on the same line as the two origin points.

  - The candidate must lie on the straight line formed by the two origin points.
  - The distance from the closest origin must be half the distance from the furthest origin.
  """

  def possible_candidate_2?(originA, originB, candidate) do
    {x1, y1} = originA
    {x2, y2} = originB
    {x3, y3} = candidate

    # Check if the points are collinear using the cross product of vectors (originA -> originB) and (originA -> candidate)
    collinear = (y2 - y1) * (x3 - x1) == (x2 - x1) * (y3 - y1)
    collinear
  end

  def possible_candidate_1?(originA, originB, candidate) do
    # Calculate the differences in x and y for the points
    {x1, y1} = originA
    {x2, y2} = originB
    {x3, y3} = candidate

    # Check if the points are collinear using the cross product of vectors (originA -> originB) and (originA -> candidate)
    collinear = (y2 - y1) * (x3 - x1) == (x2 - x1) * (y3 - y1)

    if collinear do
      # Calculate the absolute differences in x and y for both distances
      # Distance from originA to candidate
      diffA = {abs(x1 - x3), abs(y1 - y3)}
      # Distance from originB to candidate
      diffB = {abs(x2 - x3), abs(y2 - y3)}

      # Sort so that diffA is the closest and diffB is the furthest
      {closest, furthest} =
        if diffA <= diffB do
          {diffA, diffB}
        else
          {diffB, diffA}
        end

      # Extract coordinate differences
      {diffX_closest, diffY_closest} = closest
      {diffX_furthest, diffY_furthest} = furthest

      # Check if the closest point's difference is half of the furthest point's difference
      diffX_furthest == 2 * diffX_closest and diffY_furthest == 2 * diffY_closest
    else
      false
    end
  end

  @doc """
  Updates the canvas grid for each letter and its pairs.
  """
  def mark_candidates(letter, data_grid, func),
    do: mark_candidates(letter, data_grid, empty_canvas(data_grid), func)

  def mark_candidates(letter, data_grid, canvas_grid, possible_candidate_func) do
    # Get all coordinate pairs for the given letter
    # print_grid(data_grid)
    pairs = coordinates_of(data_grid, letter) |> pair_combinations()
    # IO.inspect(["woriking with ", letter, pairs])
    # Iterate through each pair
    Enum.reduce(pairs, canvas_grid, fn {originA, originB}, updated_canvas ->
      # Iterate through all dots (`.`) in the current canvas grid
      updated_canvas.grid
      |> Enum.filter(fn {_coord, value} -> value == "." end)
      |> Enum.reduce(updated_canvas, fn {{x, y}, _}, canvas_acc ->
        # If the current dot is a valid candidate, mark it as `#`
        if possible_candidate_func.(originA, originB, {x, y}) do
          # candidate", letter, originA, originB, {x, y}])
          update_char(canvas_acc, {x, y}, "#")
        else
          canvas_acc
        end
      end)
    end)
  end

  @doc """
  Counts the number of `#` symbols in the given grid.
  """
  def count_candidates(%__MODULE__{grid: grid}) do
    grid
    |> Map.values()
    |> Enum.count(&(&1 == "#"))
  end

  # Helper Functions
  @doc """
  Returns all unique non-dot characters in the grid.
  """
  def unique_non_dot_chars(%__MODULE__{grid: grid}) do
    grid
    |> Map.values()
    |> Enum.reject(&(&1 == "."))
    |> Enum.uniq()
  end

  @doc """
  Returns all coordinates where the given character is located.
  """
  def coordinates_of(%__MODULE__{grid: grid}, char) do
    grid
    |> Enum.filter(fn {_coord, value} -> value == char end)
    |> Enum.map(fn {coord, _value} -> coord end)
  end

  @doc """
  Takes a list of coordinate pairs and returns all possible pairwise combinations, no overlap
  """
  def pair_combinations(pairs) do
    for {p1, i} <- Enum.with_index(pairs),
        {p2, j} <- Enum.with_index(pairs),
        # Ensures pairs are not repeated (no (A, B) and (B, A))
        i < j,
        do: {p1, p2}
  end

  @doc """
  Updates the character at the given coordinates.
  """
  def update_char(%__MODULE__{grid: grid} = struct, {x, y}, char) do
    %{struct | grid: Map.put(grid, {x, y}, char)}
  end

  @doc """
  Prints the grid to the console in a human-readable format.
  """
  def print_grid(%__MODULE__{grid: grid, width: width, height: height}) do
    for y <- (height - 1)..0 do
      for x <- 0..(width - 1) do
        IO.write(Map.get(grid, {x, y}, "."))
      end

      IO.puts("")
    end
  end
end
