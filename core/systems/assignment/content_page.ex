defmodule Systems.Assignment.ContentPage do
  use CoreWeb, :live_view_fabric
  use Fabric.LiveView, CoreWeb.Layouts
  use Systems.Content.Page

  alias Systems.{
    Assignment,
    Crew
  }

  @impl true
  def get_authorization_context(%{"id" => id}, _session, _socket) do
    Assignment.Public.get!(String.to_integer(id))
  end

  @impl true
  def mount(%{"id" => id} = params, session, socket) do
    initial_tab = Map.get(params, "tab")
    model = Assignment.Public.get!(String.to_integer(id), Assignment.Model.preload_graph(:down))
    tabbar_id = "assignment_content/#{id}"

    {
      :ok,
      socket
      |> initialize(session, id, model, tabbar_id, initial_tab)
      |> ensure_tester_role()
    }
  end

  defp ensure_tester_role(%{assigns: %{current_user: user, model: %{crew: crew}}} = socket) do
    if Crew.Public.get_member(crew, user) == nil do
      Crew.Public.apply_member_with_role(crew, user, :tester)
    end

    socket
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.content_page
      title={@vm.title}
      show_errors={@vm.show_errors}
      tabs={@vm.tabs}
      menus={@menus}
      actions={@actions}
      more_actions={@more_actions}
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
