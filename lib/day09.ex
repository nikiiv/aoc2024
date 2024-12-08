defmodule Day09 do
  def parse(string) do
    string
    |> IO.inspect()
    |> String.replace(~r/\D/, "")
    |> String.graphemes()
  end

  def solve_mini_1() do
    "2333133121414131402"
    |> parse
    |> solve
  end

  def solve_1, do: File.read!("/Users/niki/projects/aoc2024/input/day09.txt") |> parse |> solve

  def solve(list) do
    list
    |> Enum.with_index()
    |> Enum.reduce([], fn ({n,i}, acc) -> acc ++ convert(String.to_integer(n),i) end)
   #|> IO.inspect()
    |> Arrays.new
    |> process()
    |> Enum.filter(&(&1!="."))
    |> Enum.with_index()
    |> Enum.reduce(0, fn {id,indx}, acc ->acc+ id*indx end)
  end

  def process(arr), do: process(arr,0, Arrays.size(arr)-1)
  def process(arr, left, right) when left>= right, do: arr
  def process(arr, left, right), do: process(arr,left, Arrays.get(arr,left), right, Arrays.get(arr,right))
  # def process(arr, left, right) do
  #   left_c = Arrays.get(arr,left)
  #   right_c = Arrays.get(arr,right)
  #   #IO.inspect([left, left_c, right, right_c])
  #   process(arr,left,left_c, right, right_c)
  # end


  def process(arr,left, left_c, right, _right_c) when left_c != ".", do: process(arr,left+1,right) # Left not under space, move forward
  def process(arr,left, left_c, right, right_c) when left_c == "." and right_c == ".", do: process(arr,left,right-1) #left ready to be replaced, right not ready, move right back
  def process(arr,left, left_c, right, right_c) when left_c == "." and right_c != "." do
    new_arr = Arrays.replace(arr, left, right_c) |> Arrays.replace(right, ".")
    IO.inspect(Enum.join(new_arr,""))
    process(new_arr, left+1, right)
  end



  def convert(0,_i), do: []
  def convert(n,i) do
    #IO.inspect(["Convert",n,i,rem(i+2,2)])
    case rem(i+2,2) do
      1 -> Enum.map(1..n, fn _ -> "." end)
      0 -> Enum.map(1..n, fn _ -> round(i/2) end)
    end

  end




end
