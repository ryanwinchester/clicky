defmodule ClickyWeb.ClickyLive do
  use ClickyWeb, :live_view

  require Logger

  @bg_colors ~w[bg-red-500 bg-orange-500 bg-yellow-500 bg-green-500 bg-blue-500 bg-indigo-500 bg-purple-500]

  @impl true
  def mount(_, _, socket) do
    if connected?(socket) do
      Clicky.subscribe("grid:colors")
    end

    socket =
      socket
      |> assign(:grid, Clicky.Grid.get_grid())
      |> assign(:grid_size, Clicky.Grid.get_size())
      |> assign(:color, nil)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="w-full grid grid-cols-[repeat(48,minmax(0,_1fr))] aspect-square">
        <%= for x <- 1..@grid_size do %>
          <div
            :for={y <- 1..@grid_size}
            class={["aspect-square", Map.get(@grid, {x, y})]}
            phx-click="colorize-block"
            phx-value-x={x}
            phx-value-y={y}
          >
          </div>
        <% end %>
      </div>
    </div>
    <div class="relative w-full">
      <div class="fixed bottom-10 left-10 flex space-x-4 p-4 bg-slate-800 bg-opacity-75 rounded-lg">
        <.link
          :for={color <- bg_colors()}
          patch={~p"/?color=#{color}"}
          class={[
            "aspect-square h-12 rounded-lg",
            color,
            if(color == @color, do: "border-4 border-slate-950")
          ]}
        >
        </.link>
      </div>
    </div>
    """
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, :color, params["color"])}
  end

  @impl true
  def handle_event("colorize-block", _params, %{assigns: %{color: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_event("colorize-block", %{"x" => x, "y" => y}, socket) do
    bgcolor = socket.assigns.color
    x = String.to_integer(x)
    y = String.to_integer(y)
    Clicky.Grid.set_color({x, y}, bgcolor)
    {:noreply, update(socket, :grid, &Map.put(&1, {x, y}, bgcolor))}
  end

  @impl true
  def handle_info({:color, {_x, _y} = cell, bgcolor}, socket) do
    {:noreply, update(socket, :grid, &Map.put(&1, cell, bgcolor))}
  end

  defp bg_colors, do: @bg_colors
end
