defmodule Systems.Graphite.LeaderboardSettingsView do
  use CoreWeb, :live_component_fabric
  use Fabric.LiveComponent

  alias Systems.{
    Graphite
  }

  @impl true
  def update(
        %{
          id: id,
          entity: leaderboard,
          uri_origin: uri_origin,
          viewport: viewport,
          breakpoint: breakpoint
        },
        socket
      ) do
    {
      :ok,
      socket
      |> assign(
        id: id,
        entity: leaderboard,
        uri_origin: uri_origin,
        viewport: viewport,
        breakpoint: breakpoint
      )
      |> compose_child(:settings)
    }
  end

  @impl true
  def compose(:settings, %{entity: leaderboard}) do
    %{
      module: Graphite.LeaderboardSettingsForm,
      params: %{
        leaderboard: leaderboard,
        page_key: :settings,
        opt_in?: false,
        on_text: "settings on text",
        off_text: "settings off text"
      }
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Area.content>
        <.child name={:settings} fabric={@fabric} >
          <:header>
          </:header>
          <:footer>
          </:footer>
        </.child>
      </Area.content>
    </div>
    """
  end
end
