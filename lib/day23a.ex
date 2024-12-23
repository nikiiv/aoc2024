# defmodule BiDirectionalConnections do
#   @moduledoc """
#   Manages bi-directional connections between nodes using a Map of MapSets.
#   """

#   defstruct connections: %{}

#   @type t :: %__MODULE__{
#           connections: %{String.t() => MapSet.t(String.t())}
#         }

#   @doc """
#   Initializes an empty connections structure.
#   """
#   def new do
#     %BiDirectionalConnections{}
#   end

#   @doc """
#   Adds a bi-directional connection between `node1` and `node2`.
#   """
#   def add_connection(%BiDirectionalConnections{connections: conns} = state, node1, node2)
#       when is_binary(node1) and is_binary(node2) and node1 != node2 do
#     conns =
#       conns
#       |> Map.update(node1, MapSet.new([node2]), &MapSet.put(&1, node2))
#       |> Map.update(node2, MapSet.new([node1]), &MapSet.put(&1, node1))

#     %{state | connections: conns}
#   end

#   @doc """
#   Retrieves all connections for a given `node`.
#   """
#   def get_connections(%BiDirectionalConnections{connections: conns}, node) when is_binary(node) do
#     Map.get(conns, node, MapSet.new())
#   end

#   @doc """
#   Checks if a connection exists between `node1` and `node2`.
#   """
#   def connection_exists?(%BiDirectionalConnections{connections: conns}, node1, node2)
#       when is_binary(node1) and is_binary(node2) do
#     Map.get(conns, node1, MapSet.new()) |> MapSet.member?(node2)
#   end

#   @doc """
#   Removes a bi-directional connection between `node1` and `node2`.
#   """
#   def remove_connection(%BiDirectionalConnections{connections: conns} = state, node1, node2)
#       when is_binary(node1) and is_binary(node2) do
#     conns =
#       conns
#       |> update_in([node1], &MapSet.delete(&1 || MapSet.new(), node2))
#       |> update_in([node2], &MapSet.delete(&1 || MapSet.new(), node1))

#     %{state | connections: conns}
#   end
# end

# defmodule ConnectionBuilder do
#   alias BiDirectionalConnections

#   @doc """
#   Parses a list of connection strings and builds the connections map.
#   """
#   def build_connections(connections_input) do
#     connections_input
#     |> Enum.reduce(BiDirectionalConnections.new(), fn connection_str, acc ->
#       [node1, node2] = String.split(connection_str, "-")
#       BiDirectionalConnections.add_connection(acc, node1, node2)
#     end)
#   end
# end

# defmodule TripletFinder do
#   alias BiDirectionalConnections

#   @doc """
#   Finds all triplets where each node is connected to the other two,
#   and at least one node starts with 't'.
#   """
#   def find_triplets(%BiDirectionalConnections{connections: conns}) do
#     nodes = Map.keys(conns)

#     # Generate all combinations of 3 nodes
#     nodes
#     |> Enum.sort()
#     |> combinations(3)
#     |> Enum.filter(&valid_triplet?(&1, conns))
#     |> Enum.filter(&has_node_starting_with_t?/1)
#   end

#   # Helper function to generate combinations
#   defp combinations(list, n) do
#     do_combinations(list, n, [])
#   end

#   defp do_combinations(_, 0, acc), do: [Enum.reverse(acc)]

#   defp do_combinations([], _n, _acc), do: []

#   defp do_combinations([head | tail], n, acc) do
#     do_combinations(tail, n - 1, [head | acc]) ++ do_combinations(tail, n, acc)
#   end

#   # Check if all pairs in the triplet are connected
#   defp valid_triplet?([a, b, c], conns) do
#     BiDirectionalConnections.connection_exists?(
#       %BiDirectionalConnections{connections: conns},
#       a,
#       b
#     ) and
#       BiDirectionalConnections.connection_exists?(
#         %BiDirectionalConnections{connections: conns},
#         a,
#         c
#       ) and
#       BiDirectionalConnections.connection_exists?(
#         %BiDirectionalConnections{connections: conns},
#         b,
#         c
#       )
#   end

#   # Check if at least one node starts with 't'
#   defp has_node_starting_with_t?([a, b, c]) do
#     String.starts_with?(a, "t") or String.starts_with?(b, "t") or String.starts_with?(c, "t")
#   end
# end

# defmodule TripletApp do
#   alias ConnectionBuilder
#   alias TripletFinder

#   def run do
#     _connections_input_sample = [
#       "kh-tc",
#       "qp-kh",
#       "de-cg",
#       "ka-co",
#       "yn-aq",
#       "qp-ub",
#       "cg-tb",
#       "vc-aq",
#       "tb-ka",
#       "wh-tc",
#       "yn-cg",
#       "kh-ub",
#       "ta-co",
#       "de-co",
#       "tc-td",
#       "tb-wq",
#       "wh-td",
#       "ta-ka",
#       "td-qp",
#       "aq-cg",
#       "wq-ub",
#       "ub-vc",
#       "de-ta",
#       "wq-aq",
#       "wq-vc",
#       "wh-yn",
#       "ka-de",
#       "kh-ta",
#       "co-tc",
#       "wh-qp",
#       "tb-vc",
#       "td-yn"
#     ]

#     connections_input =
#       File.read!("/Users/niki/aoc2024/input/day23.txt")
#       |> String.split("\n", trim: true)

#     connections = ConnectionBuilder.build_connections(connections_input)

#     triplets = TripletFinder.find_triplets(connections)

#     IO.puts("Valid Triplets (A ↔ B ↔ C ↔ A) with at least one node starting with 't':")

#     Enum.each(triplets, fn [a, b, c] ->
#       IO.puts("#{a} ↔ #{b} ↔ #{c} ↔ #{a}")
#     end)

#     Enum.count(triplets) |> IO.inspect(label: "Total count")
#   end
# end

# # TripletApp.run()
