defmodule Day04 do
  @xmas "XMAS"

  def load_file(file_path) do
    File.read!(file_path)
    |> String.split("\n", trim: true)
  end

  # Gets the character at line x and position y, or '.' if out of bounds
  def get_char(lines, x, y) when x >= 0 and y >= 0 do
    case Enum.at(lines, x) do
      nil ->
        "."

      line ->
        case String.at(line, y) do
          nil -> "."
          char -> char
        end
    end
  end

  def get_char(_, _, _), do: "."

  def test_a do
    lines = load_file("/Users/niki/aoc2024/input/mini_day04.txt")
    start(lines)
  end

  def do_it_a do
    lines = load_file("/Users/niki/aoc2024/input/day04.txt")
    start(lines)
  end

  def wrap(lines) do
    rows = length(lines)
    cols = String.length(List.first(lines))
    _data = %{lines: lines, cols: cols, rows: rows}
  end

  def start(lines) do
    wrap(lines)
    |> solve1
    |> Enum.count(fn z -> z end)
  end

  def solve1(%{lines: lines, cols: cols, rows: rows} = _data) do
    zap =
      for x <- -1..1, y <- -1..1 do
        {x, y}
      end

    for x <- 0..(cols - 1), y <- 0..(rows - 1), z <- zap do
      # IO.inspect(["Verify", Enum.at(lines, x), x, y])
      verify(lines, x, y, z, 0)
    end
  end

  def verify(_, _, _, {0, 0}, _), do: false
  def verify(_, _, _, _, 4), do: true

  def verify(lines, x, y, z, step) do
    char = get_char(lines, x, y)
    check = String.at(@xmas, step)
    # IO.inspect([Enum.at(lines, x), char, check, x, y, z, step])

    if char == check,
      do: verify(lines, x + elem(z, 0), y + elem(z, 1), z, step + 1),
      else: false
  end

  def test_b do
    lines = load_file("/Users/niki/aoc2024/input/mini_day04_b.txt")

    wrap(lines)
    |> solve2()
    |> Enum.count(fn z -> z end)
  end

  def do_it_b do
    lines = load_file("/Users/niki/aoc2024/input/day04.txt")

    wrap(lines)
    |> solve2()
    |> Enum.count(fn z -> z end)
  end

  def solve2(%{lines: lines, cols: cols, rows: rows} = _data) do
    for x <- 1..(cols - 2), y <- 1..(rows - 2) do
      # IO.inspect(["Verify", Enum.at(lines, x), x, y])
      if get_char(lines, x, y) == "A", do: verify_x_mas(lines, x, y), else: false
    end
  end

  def verify_x_mas(lines, x, y) do
    tl =
      (get_char(lines, x - 1, y - 1) == "M" and get_char(lines, x + 1, y + 1) == "S") or
        (get_char(lines, x - 1, y - 1) == "S" and get_char(lines, x + 1, y + 1) == "M")

    tr =
      (get_char(lines, x + 1, y - 1) == "M" and get_char(lines, x - 1, y + 1) == "S") or
        (get_char(lines, x + 1, y - 1) == "S" and get_char(lines, x - 1, y + 1) == "M")

    tl and tr
  end
end
