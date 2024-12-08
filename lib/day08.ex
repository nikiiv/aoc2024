defmodule Day08 do
  alias Day08.Solver, as: U

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

  def sample, do: sample_data() |> U.parse()

  def test_data do
    File.read!("/Users/niki/aoc2024/input/day08.txt")
  end

  def mark_candidates(data_grid, func) do
    letters = U.unique_non_dot_chars(data_grid)
    canvas_grid = U.empty_canvas(data_grid)
    IO.puts("Antenas #{inspect(letters)}")

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
    IO.puts("Source data")
    U.print_grid(data_grid)
    IO.puts("Result")
    U.print_grid(res)
    res |> U.count_candidates()
  end
end
