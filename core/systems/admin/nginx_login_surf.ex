defmodule Systems.Admin.NginxLoginSurf do
  @moduledoc """
  Module for logging in on the Surf Research Cloud variant

  This module assumes that it cannot be reached
  It uses the GoogleLogin module to fake and register a google user
  """

  use CoreWeb, {:controller, [formats: [:html, :json], layouts: [html: CoreWeb.Layouts], namespace: CoreWeb]}
  import Plug.Conn


  def register_and_login(conn, %{"username" => username}) do
    google_user = create_user(username)
    user =
      if user = GoogleSignIn.get_user_by_sub(google_user["sub"]) do
        user
      else
        {:ok, user} = register_user(google_user, true)
        user
      end

    Systems.Account.UserAuth.log_in_user_without_redirect(conn, user) |>
    redirect(to: "/desktop")

  end

  defp register_user(google_user, creator?) do
    GoogleSignIn.register_user(google_user, creator?)
  end

  defp create_user(username) do
    %{
      "email" => username,
      "email_verified" => true,
      "family_name" => username,
      "given_name" => username,
      "locale" => "en-GB",
      "name" => username,
      "picture" => "",
      "sub" => username 
    }
  end

  defp get_domain() do
    Application.get_env(:core, CoreWeb.Endpoint)[:url][:host]
  end

end
