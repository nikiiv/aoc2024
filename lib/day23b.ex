defmodule Graph do
  @moduledoc """
  Represents a graph using an adjacency list implemented as a map of MapSets.
  """

  defstruct adjacency: %{}

  @type t :: %__MODULE__{
          adjacency: %{String.t() => MapSet.t(String.t())}
        }

  @doc """
  Initializes an empty graph.
  """
  def new do
    %Graph{}
  end

  @doc """
  Adds a bi-directional edge between `node1` and `node2`.
  """
  def add_edge(%Graph{adjacency: adj} = graph, node1, node2)
      when is_binary(node1) and is_binary(node2) and node1 != node2 do
    adj =
      adj
      |> Map.update(node1, MapSet.new([node2]), &MapSet.put(&1, node2))
      |> Map.update(node2, MapSet.new([node1]), &MapSet.put(&1, node1))

    %{graph | adjacency: adj}
  end
end

defmodule GraphBuilder do
  doc("""
  Builds a graph from a list of connection strings.
  """)

  alias Graph

  def build_graph(connections) when is_list(connections) do
    Enum.reduce(connections, Graph.new(), fn connection, graph ->
      [node1, node2] = String.split(connection, "-")
      Graph.add_edge(graph, node1, node2)
    end)
  end
end

defmodule BronKerbosch do
  @moduledoc """
  Implements the Bron–Kerbosch algorithm to find all maximal cliques in a graph.
  """

  alias Graph

  @doc """
  Finds all maximal cliques in the given graph using the Bron–Kerbosch algorithm with pivot selection.

  ## Parameters

    - graph: A `%Graph{}` struct representing the adjacency list.

  ## Returns

    - A list of `MapSet`s, each representing a maximal clique.
  """
  def find_maximal_cliques(%Graph{adjacency: adj} = _graph) do
    nodes = Map.keys(adj)
    p = MapSet.new(nodes)
    r = MapSet.new()
    x = MapSet.new()

    bron_kerbosch(adj, r, p, x, [])
  end

  defp bron_kerbosch(adj, r, p, x, cliques) do
    if MapSet.size(p) == 0 and MapSet.size(x) == 0 do
      [r | cliques]
    else
      pivot = choose_pivot(adj, p, x)
      pivot_neighbors = Map.get(adj, pivot, MapSet.new())

      p_without_pivot_neighbors = MapSet.difference(p, pivot_neighbors)

      Enum.reduce(p_without_pivot_neighbors, cliques, fn node, acc ->
        neighbors = Map.get(adj, node, MapSet.new())

        new_r = MapSet.put(r, node)
        new_p = MapSet.intersection(p, neighbors)
        new_x = MapSet.intersection(x, neighbors)

        acc = bron_kerbosch(adj, new_r, new_p, new_x, acc)

        # Move node from P to X by adding to X
        # In Elixir, since variables are immutable, we manage X implicitly by not reusing nodes
        # Therefore, we don't need to explicitly handle X here

        acc
      end)
    end
  end

  defp choose_pivot(adj, p, x) do
    # Choose a pivot with the maximum degree in P ∪ X
    union = MapSet.union(p, x)

    Enum.max_by(
      union,
      fn node ->
        MapSet.size(Map.get(adj, node, MapSet.new()))
      end,
      fn -> nil end
    )
  end
end

defmodule MaximumCliqueFinder do
  @moduledoc """
  Finds the maximum clique in a graph using the Bron–Kerbosch algorithm.
  """

  alias BronKerbosch

  @doc """
  Finds the maximum clique in the graph.

  ## Parameters

    - graph: A `%Graph{}` struct representing the adjacency list.

  ## Returns

    - The largest `MapSet` representing the maximum clique.
  """
  def find_maximum_clique(%Graph{} = graph) do
    BronKerbosch.find_maximal_cliques(graph)
    |> Enum.max_by(&MapSet.size/1, fn -> MapSet.new() end)
  end
end

defmodule MaximumCliqueApp do
  @moduledoc """
  Application to find the maximum clique in a given set of connections.
  """

  alias GraphBuilder
  alias MaximumCliqueFinder

  @doc """
  Runs the application.
  """
  def run do
    _connections_input_sample = [
      "kh-tc",
      "qp-kh",
      "de-cg",
      "ka-co",
      "yn-aq",
      "qp-ub",
      "cg-tb",
      "vc-aq",
      "tb-ka",
      "wh-tc",
      "yn-cg",
      "kh-ub",
      "ta-co",
      "de-co",
      "tc-td",
      "tb-wq",
      "wh-td",
      "ta-ka",
      "td-qp",
      "aq-cg",
      "wq-ub",
      "ub-vc",
      "de-ta",
      "wq-aq",
      "wq-vc",
      "wh-yn",
      "ka-de",
      "kh-ta",
      "co-tc",
      "wh-qp",
      "tb-vc",
      "td-yn"
    ]

    connections_input =
      File.read!("/Users/niki/aoc2024/input/day23.txt")
      |> String.split("\n", trim: true)

    graph = GraphBuilder.build_graph(connections_input)

    # Find all maximal cliques
    maximal_cliques = BronKerbosch.find_maximal_cliques(graph)

    # Find the maximum clique
    maximum_clique = MaximumCliqueFinder.find_maximum_clique(graph)

    # Display all maximal cliques
    IO.puts("All Maximal Cliques:")

    Enum.each(maximal_cliques, fn clique ->
      IO.puts("- #{MapSet.to_list(clique) |> Enum.join(", ")}")
    end)

    # Display the maximum clique
    IO.puts("\nMaximum Clique:")
    IO.puts("- #{MapSet.to_list(maximum_clique) |> Enum.join(",")}")
  end
end

# Run the application
# MaximumCliqueApp.run()
