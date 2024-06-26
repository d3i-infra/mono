defmodule Systems.Graphite.LeaderboardContentPageBuilder do
  use CoreWeb, :verified_routes

  import CoreWeb.Gettext

  alias Systems.{
    Graphite
  }

  def view_model(%Graphite.LeaderboardModel{id: id, title: title} = leaderboard, assigns) do
    action_map = action_map(leaderboard, assigns)

    tabs = create_tabs(leaderboard, false, assigns)

    %{
      id: id,
      title: title,
      tabs: tabs,
      actions: actions(leaderboard, action_map),
      show_errors: false
    }
  end

  defp actions(%{status: :concept}, %{preview: preview, publish: publish}) do
    [preview: preview, publish: publish]
  end

  defp actions(%{status: :offline}, %{preview: preview, publish: publish, close: close}),
    do: [preview: preview, publish: publish, close: close]

  defp actions(%{status: :online}, %{preview: preview, retract: retract}),
    do: [preview: preview, retract: retract]

  defp action_map(leaderboard, %{current_user: %{id: _user_id}}) do
    preview_url = Graphite.Private.get_preview_url(leaderboard)

    preview_action = %{type: :http_get, to: preview_url, target: "_blank"}
    publish_action = %{type: :send, event: "action_click", item: :publish}
    retract_action = %{type: :send, event: "action_click", item: :retract}
    close_action = %{type: :send, event: "action_click", item: :close}
    open_action = %{type: :send, event: "action_click", item: :open}

    %{
      preview: %{
        label: %{
          action: preview_action,
          face: %{
            type: :primary,
            label: dgettext("eyra-graphite", "preview.button"),
            bg_color: "bg-primary"
          }
        },
        icon: %{
          action: preview_action,
          face: %{type: :icon, icon: :preview, alt: dgettext("eyra-graphite", "preview.button")}
        }
      },
      publish: %{
        label: %{
          action: publish_action,
          face: %{
            type: :primary,
            label: dgettext("eyra-graphite", "publish.button"),
            bg_color: "bg-success"
          }
        },
        icon: %{
          action: publish_action,
          face: %{type: :icon, icon: :publish, alt: dgettext("eyra-graphite", "preview.button")}
        },
        handle_click: &handle_publish/1
      },
      retract: %{
        label: %{
          action: retract_action,
          face: %{
            type: :secondary,
            label: dgettext("eyra-graphite", "retract.button"),
            text_color: "text-error",
            border_color: "border-error"
          }
        },
        icon: %{
          action: retract_action,
          face: %{
            type: :icon,
            icon: :retract,
            alt: dgettext("eyra-graphite", "retract.button")
          }
        },
        handle_click: &handle_retract/1
      },
      close: %{
        label: %{
          action: close_action,
          face: %{
            type: :primary,
            label: dgettext("eyra-graphite", "close.button")
          }
        },
        icon: %{
          action: close_action,
          face: %{type: :icon, icon: :close, alt: dgettext("eyra-graphite", "close.button")}
        },
        handle_click: &handle_close/1
      },
      open: %{
        label: %{
          action: open_action,
          face: %{
            type: :primary,
            label: dgettext("eyra-graphite", "open.button")
          }
        },
        icon: %{
          action: open_action,
          face: %{type: :icon, icon: :open, alt: dgettext("eyra-graphite", "open.button")}
        },
        handle_click: &handle_open/1
      }
    }
  end

  defp create_tabs(leaderboard, show_errors, assigns) do
    get_tab_keys()
    |> Enum.map(&create_tab(&1, leaderboard, show_errors, assigns))
  end

  defp get_tab_keys() do
    [:settings, :submissions, :scores]
  end

  defp create_tab(:settings, leaderboard, show_errors, assigns) do
    %{fabric: fabric, uri_origin: uri_origin, viewport: viewport, breakpoint: breakpoint} =
      assigns

    child =
      Fabric.prepare_child(fabric, :settings_form, Graphite.LeaderboardSettingsView, %{
        entity: leaderboard,
        uri_origin: uri_origin,
        viewport: viewport,
        breakpoint: breakpoint
      })

    %{
      id: "settings_form",
      ready: false,
      show_errors: show_errors,
      title: dgettext("eyra-graphite", "tabbar.item.settings.title"),
      forward_title: dgettext("eyra-graphite", "tabbar.item.settings.title"),
      type: :fullpage,
      child: child
    }
  end

  defp create_tab(:submissions, leaderboard, show_errors, assigns) do
    %{fabric: fabric, uri_origin: uri_origin, viewport: viewport, breakpoint: breakpoint} =
      assigns

    child =
      Fabric.prepare_child(fabric, :submissions_form, Graphite.LeaderboardSubmissionsView, %{
        entity: leaderboard,
        submissions: Graphite.Public.list_submissions(leaderboard),
        uri_origin: uri_origin,
        viewport: viewport,
        breakpoint: breakpoint
      })

    %{
      id: "submissions_form",
      ready: false,
      show_errors: show_errors,
      title: dgettext("eyra-graphite", "tabbar.item.submissions.title"),
      forward_title: dgettext("eyra-graphite", "tabbar.item.submissions.forward"),
      type: :fullpage,
      child: child
    }
  end

  defp create_tab(:scores, leaderboard, show_errors, assigns) do
    %{fabric: fabric, uri_origin: uri_origin, viewport: viewport, breakpoint: breakpoint} =
      assigns

    child =
      Fabric.prepare_child(fabric, :scores_form, Graphite.LeaderboardScoresView, %{
        entity: leaderboard,
        uri_origin: uri_origin,
        viewport: viewport,
        breakpoint: breakpoint
      })

    %{
      id: "scores_form",
      ready: false,
      show_errors: show_errors,
      title: dgettext("eyra-graphite", "tabbar.item.scores"),
      forward_title: dgettext("eyra-graphite", "tabbar.item.scores.forward"),
      type: :fullpage,
      child: child
    }
  end

  defp handle_publish(socket) do
    socket |> set_status(:online)
  end

  defp handle_retract(socket) do
    socket |> set_status(:offline)
  end

  defp handle_close(socket) do
    socket |> set_status(:idle)
  end

  defp handle_open(socket) do
    socket |> set_status(:concept)
  end

  defp set_status(%{assigns: %{model: leaderboard}} = socket, status) do
    changeset = Graphite.LeaderboardModel.changeset(leaderboard, %{status: status})
    {:ok, leaderboard} = Core.Persister.save(leaderboard, changeset)
    socket |> Phoenix.Component.assign(leaderboard: leaderboard)
  end
end
