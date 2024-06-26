defmodule Systems.Feldspar.ContentPage do
  use CoreWeb, :live_view
  use Systems.Content.Page

  alias Systems.{
    Feldspar
  }

  @impl true
  def get_authorization_context(%{"id" => id}, _session, _socket) do
    Feldspar.Public.get_tool!(id)
  end

  @impl true
  def mount(%{"id" => id} = params, session, socket) do
    initial_tab = Map.get(params, "tab")

    model =
      Feldspar.Public.get_tool!(String.to_integer(id), Feldspar.ToolModel.preload_graph(:down))

    tabbar_id = "feldspar_content/#{id}"

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
