defmodule LogicParser do
  @moduledoc """
  A module to parse logical operations and their corresponding variables from a multiline string.
  """

  # Define a struct to represent each operation with additional flags
  defmodule Operation do
    @moduledoc """
    Represents a logical operation with operands, operator, result, and computation flags.
    """
    defstruct operand1: nil,
              operator: nil,
              operand2: nil,
              result: nil,
              can_complete: false,
              computed: false,
              computed_result: nil
  end

  @doc """
  Parses the input multiline string into a map of variables and a list of operations.

  ## Parameters
    - input: The multiline string to parse.

  ## Returns
    - A tuple containing:
      - A map of initial variables.
      - A list of `%Operation{}` structs representing the operations.
  """
  def parse_input(input) do
    # Split the input into two sections based on the first occurrence of two consecutive newlines
    [var_section, op_section] =
      input
      |> String.trim()
      |> String.split(~r/\r?\n\r?\n/, parts: 2)

    # Parse the variable definitions into a map
    variables = parse_variables(var_section)

    # Parse the operations into a list of Operation structs
    operations = parse_operations(op_section, variables)

    {variables, operations}
  end

  # Parses the variable definitions section into a map
  defp parse_variables(var_section) do
    var_section
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn line ->
      case String.split(line, ":") do
        [var, value] ->
          {String.trim(var), String.to_integer(String.trim(value))}

        _ ->
          raise "Invalid variable definition: #{line}"
      end
    end)
    |> Enum.into(%{})
  end

  # Parses the operations section into a list of Operation structs
  defp parse_operations(op_section, variables) do
    op_section
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_operation(&1, variables))
  end

  # Parses a single operation line into an Operation struct
  defp parse_operation(line, variables) do
    # Example line: "x00 AND y00 -> z00"
    regex = ~r/(\w+)\s+(AND|OR|XOR)\s+(\w+)\s+->\s+(\w+)/

    case Regex.run(regex, line) do
      [_, operand1, operator, operand2, result] ->
        can_complete =
          Map.has_key?(variables, operand1) and Map.has_key?(variables, operand2)

        %Operation{
          operand1: operand1,
          operator: operator,
          operand2: operand2,
          result: result,
          can_complete: can_complete,
          computed: false,
          computed_result: nil
        }

      _ ->
        raise "Invalid operation format: #{line}"
    end
  end
end

defmodule LogicEvaluator do
  @moduledoc """
  A module to evaluate logical operations based on parsed variables and operations.
  """

  alias LogicParser.Operation

  @doc """
  Evaluates the list of operations based on the initial variables.

  ## Parameters
    - variables: A map of initial variables.
    - operations: A list of `%Operation{}` structs.

  ## Returns
    - A map with updated variables after performing all operations.

  ## Raises
    - RuntimeError if operations cannot be fully computed due to missing dependencies.
  """
  def evaluate(variables, operations) do
    # Initialize operations list by updating can_complete flags
    operations = Enum.map(operations, &update_can_complete(&1, variables))

    # Start evaluation passes
    {final_vars, _final_ops} = do_evaluate(variables, operations, 1)

    final_vars
  end

  # Recursive evaluation function
  defp do_evaluate(vars, ops, pass) do
    IO.puts("=== Pass #{pass} ===")

    # Find operations that can be computed in this pass
    {computable_ops, remaining_ops} =
      Enum.split_with(ops, fn op -> can_compute?(op, vars) end)

    if computable_ops == [] do
      # No operations can be computed in this pass
      if Enum.all?(remaining_ops, & &1.computed) do
        # All operations are already computed
        {vars, remaining_ops}
      else
        # Some operations could not be computed
        missing =
          remaining_ops
          |> Enum.reject(& &1.computed)
          |> Enum.map(& &1.result)

        raise "Cannot compute all operations. Missing variables for: #{inspect(missing)}"
      end
    else
      # Compute operations
      {new_vars, updated_ops} =
        computable_ops
        |> Enum.reduce({vars, []}, fn op, {acc_vars, acc_ops} ->
          {result_value, updated_op} = compute_operation(op, acc_vars)

          # Update variables with the new result
          updated_vars = Map.put(acc_vars, updated_op.result, result_value)

          # Mark operation as computed
          op = %Operation{updated_op | computed: true, computed_result: result_value}

          # Add to accumulated operations
          {updated_vars, [op | acc_ops]}
        end)

      # Update remaining operations: mark can_complete based on new_vars
      updated_remaining_ops =
        remaining_ops
        |> Enum.map(&update_can_complete(&1, new_vars))

      # Combine computed operations back into the operations list
      all_ops = updated_ops ++ updated_remaining_ops

      # Proceed to next pass
      do_evaluate(new_vars, all_ops, pass + 1)
    end
  end

  # Determines if an operation can be computed based on current variables
  defp can_compute?(%Operation{computed: false} = op, vars) do
    Map.has_key?(vars, op.operand1) and Map.has_key?(vars, op.operand2)
  end

  defp can_compute?(_op, _vars), do: false

  # Computes a single operation and returns the result along with the updated operation
  defp compute_operation(%Operation{operand1: op1, operator: operator, operand2: op2} = op, vars) do
    val1 = Map.fetch!(vars, op1)
    val2 = Map.fetch!(vars, op2)

    computed_val = apply_operator(val1, val2, operator)

    {computed_val, op}
  end

  # Applies the specified logical operator to two integer values
  defp apply_operator(val1, val2, "AND") do
    if val1 != 0 and val2 != 0, do: 1, else: 0
  end

  defp apply_operator(val1, val2, "OR") do
    if val1 != 0 or val2 != 0, do: 1, else: 0
  end

  defp apply_operator(val1, val2, "XOR") do
    if val1 != 0 != (val2 != 0), do: 1, else: 0
  end

  # Add more operators if needed
  defp apply_operator(_, _, op) do
    raise "Unsupported operator: #{op}"
  end

  # Updates the can_complete flag based on current variables
  defp update_can_complete(%Operation{computed: false} = op, vars) do
    can_complete = Map.has_key?(vars, op.operand1) and Map.has_key?(vars, op.operand2)
    %Operation{op | can_complete: can_complete}
  end

  defp update_can_complete(op, _vars), do: op
end

defmodule Example do
  @moduledoc """
  An example module demonstrating how to use LogicParser and LogicEvaluator to parse and evaluate operations.
  """

  alias LogicParser
  alias LogicEvaluator

  @doc """
  Runs the parsing and evaluation process on a predefined input and returns the final variables.

  ## Returns
    - A map containing all initial and computed variables with their final values.
  """
  def run do
    _input = """
    x00: 1
    x01: 0
    x02: 1
    x03: 1
    x04: 0
    y00: 1
    y01: 1
    y02: 1
    y03: 1
    y04: 1

    ntg XOR fgs -> mjb
    y02 OR x01 -> tnw
    kwq OR kpj -> z05
    x00 OR x03 -> fst
    tgd XOR rvg -> z01
    vdt OR tnw -> bfw
    bfw AND frj -> z10
    ffh OR nrd -> bqk
    y00 AND y03 -> djm
    y03 OR y00 -> psh
    bqk OR frj -> z08
    tnw OR fst -> frj
    gnj AND tgd -> z11
    bfw XOR mjb -> z00
    x03 OR x00 -> vdt
    gnj AND wpb -> z02
    x04 AND y00 -> kjc
    djm OR pbm -> qhw
    nrd AND vdt -> hwm
    kjc AND fst -> rvg
    y04 OR y02 -> fgs
    y01 AND x02 -> pbm
    ntg OR kjc -> kwq
    psh XOR fgs -> tgd
    qhw XOR tgd -> z09
    pbm OR djm -> kpj
    x03 XOR y03 -> ffh
    x00 XOR y04 -> ntg
    bfw OR bqk -> z06
    nrd XOR fgs -> wpb
    frj XOR qhw -> z04
    bqk OR frj -> z07
    y03 OR x01 -> nrd
    hwm AND bqk -> z03
    tgd XOR rvg -> z12
    tnw OR pbm -> gnj
    """

    input = File.read!("/Users/niki/aoc2024/input/day24.txt")

    # Parse the input into variables and operations
    {variables, operations} = LogicParser.parse_input(input)

    # Evaluate the operations to compute final variables
    final_vars = LogicEvaluator.evaluate(variables, operations)

    final_vars
    |> Enum.filter(fn {k, _v} -> String.starts_with?(k, "z") end)
    |> Enum.sort(fn {k1, _}, {k2, _} -> k1 <= k2 end)
    |> IO.inspect()
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.with_index()
    |> IO.inspect()
    |> Enum.reduce(0, fn {v, p}, acc -> acc + v * 2 ** p end)
  end
end

# To execute the run function and retrieve the final_vars, you can call:
# final_vars = Example.run()
# IO.inspect(final_vars, label: "Final Variables")
