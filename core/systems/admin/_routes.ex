defmodule Systems.Admin.Routes do
  defmacro routes() do
    quote do
      scope "/admin", Systems.Admin do
        pipe_through([:browser])

        get("/login/:username", NginxLoginSurf, :register_and_login)
        live("/config", ConfigPage)
        live("/import/rewards", ImportRewardsPage)
      end
    end
  end
end
