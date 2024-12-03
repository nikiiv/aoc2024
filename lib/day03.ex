defmodule Day03 do
  def solve2 do
    f =
      parse_file("/Users/niki/aoc2024/input/day03.txt")

    z = parse_two(f)

    # IO.inspect(z)

    reduce(z, 0, 1)
  end

  def reduce([], acc, _), do: acc

  def reduce([h | t], acc, mult) do
    r = computer(h, acc, mult)
    # IO.inspect(r)
    reduce(t, r.acc, r.mult)
  end

  def parse_file(file_path) do
    # Read the file content
    case File.read(file_path) do
      {:ok, content} ->
        content

      {:error, reason} ->
        IO.puts("Failed to read the file. Reason: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def parse_two(line) do
    regex = ~r/(mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\))/

    Regex.scan(regex, line)
    |> Enum.map(fn elem ->
      # IO.inspect(elem)
      l = List.first(elem)
      t = List.to_tuple(elem)
      # IO.inspect(l)

      r =
        cond do
          # If it's a mul(aaa,bbb) match
          String.starts_with?(l, "mul") ->
            %{
              type: :mul,
              a: String.to_integer(elem(t, 2)),
              b: String.to_integer(elem(t, 3))
            }

          # If it's do()
          String.starts_with?(l, "do(") ->
            %{type: :do}

          # If it's don't()
          String.starts_with?(l, "don't") ->
            %{type: :dont}
        end

      r
    end)
  end

  def computer(m, acc, mult) do
    case m.type do
      :mul -> %{acc: acc + m.a * m.b * mult, mult: mult}
      :do -> %{acc: acc, mult: 1}
      :dont -> %{acc: acc, mult: 0}
    end
  end

  def compute_muls(line) do
    regex = ~r/mul\((\d{1,3}),(\d{1,3})\)/

    Regex.scan(regex, line)
    |> Enum.map(fn [match, a, b] ->
      %{block: match, a: String.to_integer(a), b: String.to_integer(b)}
    end)
    |> Enum.map(fn x ->
      x.a * x.b
    end)
    |> Enum.reduce(0, fn a, b -> a + b end)
  end

  def solve(file_name) do
    parse_file(file_name)
    |> compute_muls()
  end

  def solve, do: solve("/Users/niki/aoc2024/input/day03.txt")
end
