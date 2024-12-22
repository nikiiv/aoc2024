defmodule Day17.Cpu do
  defstruct reg_a: nil, reg_b: nil, reg_c: nil, pc: 0, mem: Arrays.new(), out: []

  def parse(input) do
    %__MODULE__{}
    |> parse_registers(input)
    |> parse_program(input)
  end

  defp parse_registers(%__MODULE__{} = struct, input) do
    # Extracting the registers
    reg_a = parse_register(input, "Register A")
    reg_b = parse_register(input, "Register B")
    reg_c = parse_register(input, "Register C")

    %__MODULE__{struct | reg_a: reg_a, reg_b: reg_b, reg_c: reg_c}
  end

  defp parse_register(input, label) do
    case Regex.run(~r/#{label}: (\d+)/, input) do
      [_, value] -> String.to_integer(value)
      _ -> nil
    end
  end

  defp parse_program(%__MODULE__{} = struct, input) do
    # Extracting the program
    mem =
      case Regex.run(~r/Program: ([\d,]+)/, input) do
        [_, values] -> values |> String.split(",") |> Enum.map(&String.to_integer/1)
        _ -> []
      end

    %__MODULE__{struct | mem: Arrays.new(mem)}
  end
end
