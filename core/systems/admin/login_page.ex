defmodule Systems.Admin.LoginPage do
  use CoreWeb, :live_view

  on_mount({CoreWeb.Live.Hook.Base, __MODULE__})
  on_mount({CoreWeb.Live.Hook.User, __MODULE__})
  on_mount({CoreWeb.Live.Hook.Uri, __MODULE__})
  on_mount({Frameworks.GreenLight.LiveHook, __MODULE__})
  on_mount({Frameworks.Fabric.LiveHook, __MODULE__})

  import CoreWeb.Layouts.Stripped.Html
  import CoreWeb.Layouts.Stripped.Composer
  import CoreWeb.Menus

  import Ecto.Query
  alias Core.Repo
  alias Systems.Account.User

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(users: list_users(), active_menu_item: :admin)
      |> update_menus()
    }
  end

  def update_menus(%{assigns: %{current_user: user, uri: uri}} = socket) do
    menus = build_menus(stripped_menus_config(), user, uri)
    assign(socket, menus: menus)
  end

  # FIXME: Move this to Accounts
  defp list_users do
    from(u in User, order_by: {:asc, :email})
    |> Repo.all()
  end

  # data(users, :any)
  @impl true
  def render(assigns) do
    ~H"""
    <.stripped menus={@menus}>
      <Area.content>
        <Margin.y id={:page_top} />
        <Area.form>
          <div class="text-title5 font-title5 sm:text-title3 sm:font-title3 lg:text-title2 lg:font-title2 mb-7 lg:mb-9">
            Log in
          </div>
          <div class="mb-6" />
          <a href="/google-sign-in?creator=true">
            <div class="pt-2px pb-2px active:pt-3px active:pb-1px active:shadow-top4px bg-grey1 rounded pl-4 pr-4">
              <div class="flex w-full justify-center items-center">
                <div>
                  <img class="mr-3 -mt-1" src={~p"/images/google.svg"} alt="">
                </div>
                <div class="h-11 focus:outline-none">
                  <div class="flex flex-col justify-center h-full items-center rounded">
                    <div class="text-white text-button font-button">
                      Sign in with Google account
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </a>
        </Area.form>
      </Area.content>
    </.stripped>
    """
  end
end
