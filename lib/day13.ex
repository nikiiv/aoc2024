defmodule Day13 do
  def parse_sections(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&parse_section/1)
  end

  defp parse_section(section) do
    section
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_coordinates/1)
    |> List.to_tuple()
  end

  defp parse_coordinates(line) do
    # Regex to capture X and Y values
    regex = ~r/X[+=](\d+), Y[+=](\d+)/

    case Regex.run(regex, line) do
      [_, x, y] -> {String.to_integer(x), String.to_integer(y)}
      _ -> {:error, "Invalid line format"}
    end
  end

  # def find_a(max_x, max_y, a_x, a_y, b_x, b_y) do
  #   # step_b = (max_y * a_x - max_x) / (a_x * b_y - b_x * a_y)
  #   # step_a = (max_x - step_b * b_x) / a_x

  #   A = (p_x * b_y - prize_y * b_x) / (a_x * b_y - a_y * b_x)
  #   B = (a_x * p_y - a_y * p_x) / (a_x * b_y - a_y * b_x)

  #   if step_a == round(step_a) && step_b == round(step_b),
  #     do: {:ok, step_a, step_b} |> IO.inspect(),
  #     else: nil
  # end

  def find(max_x, max_y, a_x, a_y, b_x, b_y) do
    # Calculate the determinant of the coefficient matrix
    determinant = a_x * b_y - a_y * b_x

    if determinant == 0 do
      {:error, "The system of equations has no unique solution (determinant is zero)."}
    else
      # Calculate determinant_a
      determinant_a = max_x * b_y - max_y * b_x

      # Calculate determinant_b
      determinant_b = a_x * max_y - a_y * max_x

      # Solve for step_a and step_b
      step_a = determinant_a / determinant
      step_b = determinant_b / determinant

      if step_a == round(step_a) && step_b == round(step_b),
        do:
          {:ok, round(step_a), round(step_b)}
          |> IO.inspect(
            label:
              "For #{inspect([max_x, max_y, a_x, a_y, b_x, b_y, "x=", max_x - step_a * a_x - step_b * b_x, "b=", max_y - step_a * a_y - step_b * b_y])} and "
          ),
        else: nil
    end
  end

  def check(max_x, max_y, a_x, a_y, b_x, b_y) do
    IO.inspect([max_x, max_y, a_x, a_y, b_x, b_y], charlists: :as_list)
  end

  def sample do
    """
     Button A: X+94, Y+34
     Button B: X+22, Y+67
     Prize: X=8400, Y=5400

     Button A: X+26, Y+66
     Button B: X+67, Y+21
     Prize: X=12748, Y=12176

     Button A: X+17, Y+86
     Button B: X+84, Y+37
     Prize: X=7870, Y=6450

     Button A: X+69, Y+23
     Button B: X+27, Y+71
     Prize: X=18641, Y=10279
    """
  end

  def data, do: File.read!("/Users/niki/aoc2024/input/day13.txt")

  def solve_example do
    sample() |> play()
  end

  def solve, do: data() |> play

  def play(data) do
    games =
      parse_sections(data)
      # |> IO.inspect()
      |> Enum.map(fn {{a_x, a_y}, {b_x, b_y}, {max_x, max_y}} ->
        Day13.find(max_x + 10_000_000_000_000, max_y + 10_000_000_000_000, a_x, a_y, b_x, b_y)
      end)
      |> Enum.filter(fn x -> x end)
      # |> IO.inspect(label: "No nil")
      # |> Enum.filter(fn {_coins, a, b} -> a <= 100 || b <= 100 end)
      # |> IO.inspect(label: "Games")
      |> Enum.map(fn {:ok, a, b} -> a * 3 + b end)
      |> IO.inspect()

    {games |> Enum.count(), games |> Enum.sum()}
  end
end
