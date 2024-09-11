defmodule Systems.Storage.SurfResearchDrive.EndpointForm do
  use Systems.Storage.EndpointForm.Helper, Systems.Storage.SurfResearchDrive.EndpointModel

  import Systems.Storage.Html

  @impl true
  def render(assigns) do
    ~H"""
      <div>
      <.form id={"#{@id}_surfresearchdrive_endpoint_form"} :let={form} for={@changeset} phx-change="change" phx-submit="save" phx-target={@myself}>
        <div class="flex flex-col gap-4">
          <.text_input form={form} field={:user} label_text={dgettext("eyra-storage", "surfresearchdrive.user.label")} debounce="0" reserve_error_space={false} />
          <.password_input form={form} field={:password} label_text={dgettext("eyra-storage", "surfresearchdrive.password.label")} debounce="0" reserve_error_space={false} />
          <.text_input form={form} field={:url} label_text={dgettext("eyra-storage", "surfresearchdrive.url.label")} placeholder="https://{url}/remote.php/webdav/>" debounce="0" reserve_error_space={false} />
          <.text_input form={form} field={:folder} label_text={dgettext("eyra-storage", "surfresearchdrive.folder.label")} debounce="0" reserve_error_space={false} />
          <.text_input form={form} field={:passphrase} label_text={dgettext("eyra-storage", "surfresearchdrive.passphrase.label")} placeholder="Leave blank for no encryption" debounce="0" reserve_error_space={false} />
          <div class="flex flex-row gap-4 items-center mt-2">
            <Button.dynamic_bar buttons={[@submit_button]} />
          </div>
        </div>
      </.form>
      </div>
    """
  end
end
