defmodule Systems.Alliance.ContentPage do
  use CoreWeb, :live_view
  use Systems.Content.Page

  alias Systems.{
    Alliance
  }

  @impl true
  def get_authorization_context(%{"id" => id}, _session, _socket) do
    Alliance.Public.get_tool!(id)
  end

  @impl true
  def mount(%{"id" => id} = params, session, socket) do
    initial_tab = Map.get(params, "tab")
    model = Alliance.Public.get_tool!(String.to_integer(id))
    tabbar_id = "alliance_content/#{id}"

    {
      :ok,
      socket |> initialize(session, id, model, tabbar_id, initial_tab)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.content_page
      title={@vm.title}
      menus={@menus}
      tabs={@vm.tabs}
      actions={@actions}
      more_actions={@more_actions}
      initial_tab={@initial_tab}
      tabbar_id={@tabbar_id}
      tabbar_size={@tabbar_size}
      breakpoint={@breakpoint}
      popup={@popup}
      dialog={@dialog}
      show_errors={@show_errors}
     />
    """
  end
end
