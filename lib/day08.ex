defmodule Day08 do
  alias Day08.GridParser, as: U

  def sample_data do
    """
    ............
    ........0...
    .....0......
    .......0....
    ....0.......
    ......A.....
    ............
    ............
    ........A...
    .........A..
    ............
    ............
    """
  end

  def sample, do: sample_data() |> Day08.GridParser.parse()

  def test_data do
    File.read!("/Users/niki/aoc2024/input/day08.txt")
  end

  def mark_candidates(data_grid, func) do
    letters = U.unique_non_dot_chars(data_grid) |> Enum.filter(fn ch -> ch != " " end)
    canvas_grid = U.empty_canvas(data_grid)
    IO.inspect(letters)

    canvas =
      Enum.reduce(letters, canvas_grid, fn l, canvas_grid ->
        U.mark_candidates(l, data_grid, canvas_grid, func)
      end)

    canvas
  end

  def solve_1_sample, do: sample_data() |> solve(&U.possible_candidate_1?/3)
  def solve_1, do: test_data() |> solve(&U.possible_candidate_1?/3)

  def solve_2_sample, do: sample_data() |> solve(&U.possible_candidate_2?/3)
  def solve_2, do: test_data() |> solve(&U.possible_candidate_2?/3)

  def solve(data, func) do
    data_grid = U.parse(data)
    res = mark_candidates(data_grid, func)
    U.print_grid(data_grid)
    IO.inspect("ghahah")
    U.print_grid(res)
    res |> U.count_candidates()
  end
end
