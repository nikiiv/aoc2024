defmodule Day07 do
  @sample_input """
  190: 10 19
  3267: 81 40 27
  83: 17 5
  156: 15 6
  7290: 6 8 6 15
  161011: 16 10 13
  192: 17 8 14
  21037: 9 7 18 13
  292: 11 6 16 20
  """
  @operators ["+", "*", "||"]

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [expected_result, numbers] = String.split(line, ":")

    %{
      expected_result: String.to_integer(expected_result),
      numbers:
        numbers
        |> String.trim()
        |> String.split(" ")
        |> Enum.map(&String.to_integer/1)
    }
  end

  def evaluate([num]), do: num

  def evaluate([num1, op, num2 | rest]) do
    result =
      case op do
        "+" -> num1 + num2
        "*" -> num1 * num2
        "||" -> (Integer.to_string(num1) <> Integer.to_string(num2)) |> String.to_integer()
        _ -> raise ArgumentError, "Invalid operator: #{op}"
      end

    evaluate([result | rest])
  end

  def generate_combinations(numbers) when length(numbers) == 2,
    do: generate_combinations(numbers ++ [0])

  def generate_combinations(numbers) do
    numbers_count = length(numbers)

    operator_combinations =
      Enum.reduce(1..(numbers_count - 2), @operators, fn _, acc ->
        for op <- acc, operator <- @operators, do: [operator | List.wrap(op)]
      end)

    # IO.inspect(operator_combinations, label: "OPS")

    Enum.map(operator_combinations, fn ops ->
      interleave(numbers, ops)
    end)
  end

  defp interleave([n | numbers], [op | ops]) do
    [n, op | interleave(numbers, ops)]
  end

  defp interleave([n], []), do: [n]

  def sample_input, do: @sample_input

  def test1 do
    data = parse(@sample_input)
    solve1(data)
  end

  def do_it1 do
    {:ok, content} = File.read("/Users/niki/aoc2024/input/day07.txt")
    data = parse(content)
    solve1(data)
  end

  def solve1(data) do
    data
    |> Enum.map(fn row -> Task.async(fn -> verify_result(row) end) end)
    |> Enum.map(&Task.await/1)
    |> Enum.sum()

    # Enum.map(data, &verify_result(&1))
    # |> Enum.sum()
  end

  def verify_result(%{expected_result: expected_result, numbers: numbers}) do
    # IO.inspect(numbers)

    all_possible_values = generate_combinations(numbers)

    # IO.inspect(all_possible_values)
    ok =
      Enum.map(all_possible_values, &evaluate/1)
      # |> IO.inspect()
      |> Enum.any?(fn res -> res == expected_result end)

    if ok, do: expected_result, else: 0
  end
end
