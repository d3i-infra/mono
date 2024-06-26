defmodule Frameworks.GreenLight.Live do
  require Logger

  @moduledoc """
  The Live module enables automatic authorization checks for LiveViews.
  """
  @callback get_authorization_context(
              Phoenix.LiveView.unsigned_params() | :not_mounted_at_router,
              session :: map,
              socket :: Phoenix.Socket.t()
            ) :: integer | struct
  @optional_callbacks get_authorization_context: 3

  defmacro __using__(auth_module) do
    quote do
      @greenlight_authmodule unquote(auth_module)
      @behaviour Frameworks.GreenLight.Live
      @before_compile Frameworks.GreenLight.Live
      import Phoenix.LiveView.Helpers

      def render(%{authorization_failed: true}) do
        raise Frameworks.GreenLight.AccessDeniedError, "Authorization failed for #{__MODULE__}"
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      if Module.defines?(__MODULE__, {:get_authorization_context, 3}) do
        defp access_allowed?(params, session, socket) do
          user = Map.get(socket.assigns, :current_user)

          can_access? =
            @greenlight_authmodule.can_access?(
              socket,
              get_authorization_context(params, session, socket)
              |> Core.Authorization.print_roles(),
              __MODULE__
            )

          Logger.notice("User #{user.id} can_access? #{__MODULE__}: #{can_access?}")
          can_access?
        end
      else
        defp access_allowed?(_params, session, socket) do
          @greenlight_authmodule.can_access?(socket, __MODULE__)
        end
      end

      defoverridable mount: 3

      def mount(params, session, socket) do
        if access_allowed?(params, session, socket) do
          super(params, session, socket)
        else
          {:ok, assign(socket, authorization_failed: true)}
        end
      end
    end
  end
end
