defmodule Systems.DataDonation.FlowPage do
  defmodule StoreResultsError do
    @moduledoc false
    defexception [:message]
  end

  import Phoenix.LiveView

  use Surface.LiveView, layout: {CoreWeb.LayoutView, "live.html"}
  use CoreWeb.LiveUri
  use CoreWeb.LiveLocale
  use CoreWeb.LiveAssignHelper
  use CoreWeb.Layouts.Stripped.Component, :data_donation

  import CoreWeb.Gettext
  alias CoreWeb.Router.Helpers, as: Routes
  alias CoreWeb.Layouts.Stripped.Component, as: Stripped
  alias CoreWeb.UI.Navigation.{ActionBar, Tabbar, TabbarContent, TabbarFooter, TabbarArea}

  alias Systems.DataDonation.{
    WelcomeSheet,
    ExecuteSheet,
    SubmitDataSheet
  }

  alias Systems.{
    DataDonation
  }

  data(result, :any)
  data(tool, :any)
  data(user, :any)
  data(loading, :boolean, default: true)
  data(step2, :css_class, default: "hidden")
  data(step3, :css_class, default: "hidden")
  data(step4, :css_class, default: "hidden")
  data(summary, :any, default: "")
  data(extracted, :any, default: "")
  data(tabs, :any)
  data(locale, :any)

  @impl true
  def mount(
        %{"id" => id, "session" => session} = _params,
        %{"locale" => locale} = _session,
        socket
      ) do
    vm = DataDonation.Context.get(id)
    tabs = create_tabs(vm, session)

    {:ok,
     assign(socket, id: id, vm: vm, session: session, tabs: tabs, locale: locale)
     |> update_menus()}
  end

  defp create_tabs(%{platform: platform} = vm, session) do
    script_content = read_script(vm)

    [
      %{
        id: :welcome,
        action: nil,
        title: dgettext("eyra-data-donation", "tabbar.item.welcome"),
        forward_title: dgettext("eyra-data-donation", "tabbar.item.welcome.forward"),
        component: WelcomeSheet,
        props: vm,
        type: :sheet,
        align: :left
      },
      %{
        id: :execute,
        action: nil,
        title: dgettext("eyra-data-donation", "tabbar.item.file_selection"),
        forward_title: dgettext("eyra-data-donation", "tabbar.item.file_selection.forward"),
        component: ExecuteSheet,
        props: %{script: script_content, platform: platform},
        type: :sheet
      },
      %{
        id: :submit_data,
        action: nil,
        title: dgettext("eyra-data-donation", "tabbar.item.submit_data"),
        forward_title: dgettext("eyra-data-donation", "tabbar.item.submit_data.forward"),
        component: SubmitDataSheet,
        props: Map.put(vm, :session, session),
        type: :sheet
      }
    ]
  end

  @impl true
  def handle_event(
        "donate",
        %{"data" => data},
        socket
      ) do
    store_results(socket, data)
    {:noreply, socket |> next_action()}
  end

  @impl true
  def handle_event(
        "decline",
        %{"data" => data},
        socket
      ) do
    store_results(socket, data)
    {:noreply, socket |> next_action()}
  end

  defp next_action(
         %{
           assigns: %{
             id: id,
             session: %{"participant" => participant},
             vm: %{redirect_to: redirect_to}
           }
         } = socket
       ) do
    thanks_page = thanks_page(redirect_to)
    push_redirect(socket, to: Routes.live_path(socket, thanks_page, id, participant))
  end

  defp next_action(socket) do
    IO.puts("NO PUSH")
    socket
  end

  defp thanks_page(:thanks), do: DataDonation.ThanksPage
  defp thanks_page(:thanks_whatsapp_chat), do: DataDonation.ThanksWhatsappChatPage
  defp thanks_page(:thanks_whatsapp_account), do: DataDonation.ThanksWhatsappAccountPage

  @impl true
  def render(assigns) do
    ~F"""
    <Stripped user={@current_user} menus={@menus}>
      <div
        id="data-donation"
        phx-hook="DataDonationHook"
        data-after-completion-tab="submit_data"
        data-locale={@locale}
      >
        <TabbarArea tabs={@tabs}>
          <ActionBar>
            <Tabbar vm={%{initial_tab: :welcome}} />
          </ActionBar>
          <TabbarContent />
          <TabbarFooter>
          </TabbarFooter>
        </TabbarArea>
      </div>
    </Stripped>
    """
  end

  def store_results(
        %{assigns: %{session: session, vm: %{storage: storage_key} = vm}} = _socket,
        data
      )
      when is_binary(data) do
    storage = storage(storage_key)
    storage.store(session, vm, data)
  end

  defp storage(storage_key) do
    config = config()

    case Keyword.get(config, storage_key) do
      nil ->
        raise StoreResultsError, "Could not store the results, invalid config for #{storage_key}"

      value ->
        value
    end
  end

  defp config() do
    Application.fetch_env!(:core, :data_donation_storage_backend)
  end

  defp read_script(%{script: script}) do
    Application.app_dir(:core, "priv/repo")
    |> Path.join(script)
    |> File.read!()
  end
end

defimpl Plug.Exception, for: Systems.DataDonation.FlowPage.StoreResultsError do
  def status(_exception), do: 500
  def actions(_), do: []
end