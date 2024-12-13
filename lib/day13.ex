defmodule Day13 do

  @price_a  3
  @price_b  1

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
    regex = ~r/X[+=](\d+), Y[+=](\d+)/ # Regex to capture X and Y values
    case Regex.run(regex, line) do
      [_, x, y] -> {String.to_integer(x), String.to_integer(y)}
      _ -> {:error, "Invalid line format"}
    end
  end

  def max_cheap(max_x,max_y, b_x, b_y), do: min(div(max_x, b_x), div(max_y, b_y))
  #def max_a(max_x, max_y, a_x, a_y), do: max(div(max_x, a_x), div(max_y, a_y))

  def find_steps(step_b, _max_x, _max_y, _a_x, _a_y, _b_x, _b_y, acc) when step_b < 0, do: acc

  def find_steps(step_b, max_x, max_y, a_x, a_y, b_x, b_y, acc) do

    rem_a_x = rem(max_x - step_b * b_x, a_x)
    step_a = div(max_x - step_b * b_x, a_x)
    rem_a_y = rem(max_y - step_b * b_y, a_y)
    acc =
    if (rem_a_x == 0 && rem_a_y == 0), do:  acc ++ [{@price_a * step_a + @price_b*step_b, step_a, step_b}],     else: acc
    find_steps(step_b-1, max_x, max_y, a_x, a_y, b_x, b_y, acc )
 end

 def find(max_x, max_y, a_x, a_y, b_x, b_y) do
  step_b = max_cheap(max_x, max_y, b_x, b_y)
  ret = find_steps(step_b, max_x, max_y, a_x, a_y, b_x, b_y, [])
  ret = Enum.sort(ret, fn (a,b) -> elem(a,0) <= elem(b,0)  end) |> List.first()
  IO.inspect([ret, max_x, max_y, a_x, a_y, b_x, b_y], label: "Res")
  ret
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

 def data, do: File.read!("/Users/niki/projects/aoc2024/input/day13.txt")

 def solve_example do
  sample() |> play()
 end

 def solve, do: data() |> play

 def play(data) do
  games = parse_sections(data)
  #|> IO.inspect()
  |> Enum.map(fn {{a_x, a_y}, {b_x, b_y}, {max_x, max_y}} -> Day13.find(max_x, max_y, a_x, a_y, b_x, b_y) end)
  |> Enum.filter( fn x -> x end)

  |> Enum.filter( fn {_coins, a, b} -> a > 100 || b > 100 end)
  |> IO.inspect()
  |> Enum.map(fn {coins, _a, _b} -> coins end)
  {games |> Enum.count(), games|> Enum.sum}
 end


end
