defmodule Clicky.Grid do
  use GenServer

  @default_grid_size 48

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_grid do
    GenServer.call(__MODULE__, :get_grid)
  end

  def get_size do
    GenServer.call(__MODULE__, :get_size)
  end

  def set_color(cell, color) do
    GenServer.cast(__MODULE__, {:set, cell, color})
  end

  @impl GenServer
  def init(opts) do
    grid_size = Keyword.get(opts, :size, @default_grid_size)

    grid =
      for x <- 1..grid_size, y <- 1..grid_size, into: %{} do
        color = if rem(x + y, 2) == 0, do: "bg-gray-600", else: "bg-gray-700"
        {{x, y}, color}
      end

    state = %{grid: grid, size: grid_size}

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:get_grid, _from, state) do
    {:reply, state.grid, state}
  end

  def handle_call(:get_size, _from, state) do
    {:reply, state.size, state}
  end

  @impl GenServer
  def handle_cast({:set, cell, color}, state) do
    Clicky.broadcast("grid:colors", {:color, cell, color})
    {:noreply, %{state | grid: Map.put(state.grid, cell, color)}}
  end
end
