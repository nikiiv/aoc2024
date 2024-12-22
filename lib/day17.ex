defmodule Day17 do
  alias Day17.Cpu, as: Cpu

  def sample_data do
    """
    Register A: 51342988
    Register B: 0
    Register C: 0

    Program: 2,4,1,3,7,5,4,0,1,3,0,3,5,5,3,0
    """
  end

  @opcodes %{
    0 => "adv",
    1 => "blx",
    2 => "bst",
    3 => "jnz",
    4 => "bxc",
    5 => "out",
    6 => "bdv",
    7 => "cdv"
  }

  def combo(_cpu, val) when val >= 0 and val <= 3, do: val
  def combo(cpu, 4), do: cpu.reg_a
  def combo(cpu, 5), do: cpu.reg_b
  def combo(cpu, 6), do: cpu.reg_v

  def step(cpu) do
    _opcode = Map.get(@opcodes, Arrays.get(cpu.mem, cpu.pc))
    # IO.puts("Execute #{opcode}")
    cpu = step(cpu, Arrays.get(cpu.mem, cpu.pc), Arrays.get(cpu.mem, cpu.pc + 1))
    # IO.gets("")
    if cpu.pc >= Arrays.size(cpu.mem), do: cpu, else: step(cpu)
  end

  def step(cpu, 0, oper),
    do: %{cpu | reg_a: trunc(cpu.reg_a / :math.pow(2, combo(cpu, oper))), pc: cpu.pc + 2}

  # |> IO.inspect(label: "adv")

  def step(cpu, 1, oper),
    # |> IO.inspect(label: "bxl")
    do: %{cpu | reg_b: Bitwise.bxor(cpu.reg_b, oper), pc: cpu.pc + 2}

  def step(cpu, 2, oper),
    # |> IO.inspect(label: "bst")
    do: %{cpu | reg_b: rem(combo(cpu, oper), 8), pc: cpu.pc + 2}

  def step(cpu, 3, _oper) when cpu.reg_a == 0,
    # |> IO.inspect(label: "jnz_nop")
    do: %{cpu | pc: cpu.pc + 2}

  # |> IO.inspect(label: "jnz")
  def step(cpu, 3, oper), do: %{cpu | pc: oper}

  def step(cpu, 4, _oper),
    do: %{cpu | reg_b: Bitwise.bxor(cpu.reg_b, cpu.reg_c), pc: cpu.pc + 2}

  # |> IO.inspect(label: "bxc")

  def step(cpu, 5, oper),
    do: %{cpu | out: cpu.out ++ [rem(combo(cpu, oper), 8)], pc: cpu.pc + 2}

  # |> IO.inspect(label: "out")

  def step(cpu, 6, oper),
    do: %{cpu | reg_b: trunc(cpu.reg_a / :math.pow(2, combo(cpu, oper))), pc: cpu.pc + 2}

  # |> IO.inspect(label: "bdv")

  def step(cpu, 7, oper),
    do: %{cpu | reg_c: trunc(cpu.reg_a / :math.pow(2, combo(cpu, oper))), pc: cpu.pc + 2}

  # |> IO.inspect(label: "bdv")

  def execute(data) do
    cpu = data |> Cpu.parse() |> IO.inspect() |> step
    cpu.out |> Enum.join(",")
  end

  def sample, do: sample_data() |> execute
end
