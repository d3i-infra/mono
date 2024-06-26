defmodule Systems.Graphite.LeaderboardContentPage do
  use CoreWeb, :live_view_fabric
  use Fabric.LiveView, CoreWeb.Layouts
  use Systems.Content.Page

  alias Systems.{
    Graphite
  }

  @impl true
  def get_authorization_context(%{"id" => id}, _session, _socket) do
    Graphite.Public.get_leaderboard!(id)
  end

  @impl true
  def mount(%{"id" => id}, session, socket) do
    leaderboard =
      Graphite.Public.get_leaderboard!(id, Graphite.LeaderboardModel.preload_graph(:down))

    {:ok,
     socket |> initialize(session, id, leaderboard, "leaderboard_content/#{id}", "settings_form")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.content_page
      actions={@actions}
      title={dgettext("eyra-graphite", "title.benchmark_leaderboard")}
      show_errors={@vm.show_errors}
      tabs={@vm.tabs}
      menus={@menus}
      initial_tab={@initial_tab}
      tabbar_id={@tabbar_id}
      tabbar_size={@tabbar_size}
      breakpoint={@breakpoint}
      popup={@popup}
      dialog={@dialog}
    />
    """
  end
end
