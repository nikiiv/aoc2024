defmodule MemoizationServer do
  use GenServer

  # Client API

  @doc """
  Starts the MemoizationServer.
  """
  def start_link(opts \\ []) do
    IO.inspect(opts, label: "Server name")
    GenServer.start_link(__MODULE__, %{}, Keyword.put_new(opts, :name, __MODULE__))
  end

  def inc_and_get(key), do: GenServer.call(__MODULE__, {:inc_and_get, key})

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def put(key, value) do
    GenServer.call(__MODULE__, {:put, key, value})
  end

  def clear_data(), do: GenServer.call(__MODULE__, {:clear_data})

  def print(), do: GenServer.call(__MODULE__, {:print})

  def hello do
    IO.inspect(__MODULE__)
  end

  # Server (GenServer) Callbacks

  @impl true
  def init(state) do
    # state is an empty map initially
    {:ok, state}
  end

  @impl true
  def handle_call({:clear_data}, _from, _state), do: {:reply, :ok, %{}}

  @impl true
  def handle_call({:print}, _from, state), do: {:reply, :ok, state} |> IO.inspect()

  @impl true
  def handle_call({:inc_and_get, key}, _from, state) do
    new_val =
      case Map.get(state, key, nil) do
        nil -> 1
        x -> x + 1
      end

    IO.inspect(new_val, label: "new_val")
    {:reply, new_val, Map.put(state, key, new_val)}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    value = Map.get(state, key, nil)
    {:reply, value, state}
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    new_state = Map.put(state, key, value)
    # IO.inspect(new_state, label: "Memo")
    {:reply, :ok, new_state}
  end
end
