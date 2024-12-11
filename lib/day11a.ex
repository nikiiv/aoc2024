defmodule Memento do

  @type t() :: %{{integer(),integer()} => integer() }

  def new, do: %{}
  def get(memento, num, step), do: Map.get(memento, {num,step}, nil)
  def put(memento, num, step, val), do: Map.put(memento, {num, step}, val)
end


defmodule Day11a do
  @data  [1117,0, 8, 21078, 2389032, 142881, 93, 385]
  #data [1234123]

  def solve(memento, _single_num, 0), do: {1,memento}
  def solve(memento, single_num, step) do
    op = Memento.get(memento, single_num, step)
    case op do
      nil ->  compute(memento, single_num, step)
      _ -> {op, memento}
    end
  end

  @spec compute(Memento.t(), integer(), integer()) :: {integer(), Memento.t()}
  def compute(memento, single_num, step) do
    str = Integer.to_string(single_num)

    {steps, new_memento} =
    cond do
      single_num == 0 -> solve(memento, 1, step-1)

      rem(String.length(str),2) == 0 ->
        [left,right] = extract(str)
        {l,m1} = solve(memento, left, step-1)
        {r,m3} = solve(m1,right, step-1)
        {l+r,m3}

      true -> solve(memento, single_num*2024, step-1)
    end
    new_memento = Memento.put(new_memento, single_num, step, steps)
    {steps,new_memento}
  end

  def extract(str) do
    mid_index = div(String.length(str) , 2)
    String.split_at(str, mid_index) |> Tuple.to_list |>  Enum.map(&String.to_integer/1)
  end

  def solve(num, steps) do
    {steps, _memento} = solve(Memento.new, num, steps)
    steps
  end

  def solve(iter) do
    {total_steps, mem} =
    @data
    |> Enum.reduce({0, Memento.new}, fn num,{total_steps, memento} ->
      {steps, memento} = solve(memento, num, iter)
      {total_steps+steps, memento}
    end)
    IO.inspect(map_size(mem), label: "Final Memento size")
    total_steps
  end

  def solve, do: solve(75)



end
