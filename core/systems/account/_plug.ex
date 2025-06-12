defmodule Systems.Account.Plug do
  @behaviour Plug

  require Logger

  import Plug.Conn
  alias Systems.Account

  @valid_participant_path ~r"^\/((assignment\/(callback\/)?\d.*)|(a\/.{6,}))$"

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    case current_user(conn) do
      {:ok, %{} = user} ->
        external? = Account.Public.external?(user)
        affiliate? = Account.Public.affiliate?(user)

        Logger.info(
          "external? = #{external?}, affiliate? = #{affiliate?}, user = #{inspect(user)}"
        )

        signof_if_needed(conn, external? or affiliate?)

      _ ->
        conn
    end
  end

  defp current_user(conn) do
    if user_token = get_session(conn, :user_token) do
      {:ok, Account.Public.get_user_by_session_token(user_token)}
    else
      {:error, :no_user_token}
    end
  end

  defp signof_if_needed(%{request_path: request_path} = conn, true = _not_internal?) do
    if Regex.match?(@valid_participant_path, request_path) do
      conn
    else
      Logger.info("signing off, no regex match: request_path = #{request_path}")
      Account.UserAuth.forget_user(conn)
    end
  end

  defp signof_if_needed(conn, _), do: conn
end
