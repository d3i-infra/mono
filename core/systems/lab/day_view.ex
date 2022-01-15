defmodule Systems.Lab.DayView do
  use CoreWeb.UI.LiveComponent

  require Logger

  alias CoreWeb.UI.Timestamp

  alias Frameworks.Pixel.Button.DynamicButton
  alias Frameworks.Pixel.Form.{Form, TextInput, NumberInput, DateInput}
  alias Frameworks.Pixel.Text.SubHead
  alias Frameworks.Pixel.Spacing
  alias Frameworks.Pixel.Line

  alias Systems.{
    Lab
  }

  import CoreWeb.Gettext

  prop(day_model, :map, default: nil)
  prop(target, :any, required: true)

  data(date, :date)
  data(title, :string)
  data(byline, :string)
  data(entity, :map)
  data(changeset, :map)
  data(focus, :string, default: "")

  def update(%{id: id, day_model: day_model, target: target}, socket) do
    changeset =
      day_model
      |> Lab.DayModel.changeset(:init, %{})

    {
      :ok,
      socket
      |> assign(
        id: id,
        target: target,
        day_model: day_model,
        changeset: changeset
      )
      |> update_ui()
    }
  end

  def update(
        %{active_item_id: active_item_id, selector_id: selector_id},
        %{assigns: %{day_model: %{entries: entries} = day_model}} = socket
      ) do
    start_time = selector_id |> Atom.to_string() |> String.to_integer()
    enabled? = active_item_id != nil

    entries =
      entries
      |> update_changed_entry(start_time, enabled?)

    {
      :ok,
      socket
      |> assign(day_model: %{day_model | entries: entries})
      |> update_entries()
    }
  end

  defp update_changed_entry(entries, start_time, enabled?) when is_list(entries) do
    case entries |> Enum.find_index(&has_start_time(&1, start_time)) do
      nil ->
        entries

      index ->
        entry = Enum.at(entries, index)

        entries
        |> List.replace_at(
          index,
          %{entry | enabled?: enabled?}
        )
    end
  end

  defp update_entries(
         %{
           assigns: %{
             id: id,
             day_model: %{number_of_seats: number_of_seats, entries: entries} = day_model
           }
         } = socket
       )
       when is_list(entries) do
    enabled_timeslots = Enum.filter(entries, &(&1.type == :time_slot and &1.enabled?))

    entries =
      entries
      |> Enum.map(&update_entry(:timeslot_bullet, &1, enabled_timeslots))
      |> Enum.map(&update_entry(:timeslot_number_of_seats, &1, number_of_seats))
      |> Enum.map(&update_entry(:timeslot_target, &1, id))

    socket
    |> assign(day_model: %{day_model | entries: entries})
  end

  defp find_index(timeslot, timeslots) do
    timeslots
    |> Enum.find_index(&(&1.start_time == timeslot.start_time))
  end

  defp has_start_time(%{start_time: og_start_time}, start_time), do: og_start_time == start_time
  defp has_start_time(_entry, _start_time), do: false

  defp update_ui(socket) do
    socket
    |> update_title()
    |> update_entries()
    |> update_byline()
  end

  defp update_title(%{assigns: %{day_model: %{date: date}}} = socket) do
    assign(socket, title: Timestamp.humanize_date(date))
  end

  defp update_entry(:timeslot_bullet, %{type: :time_slot} = timeslot, enabled_timeslots) do
    bullet =
      if timeslot.enabled? do
        index = find_index(timeslot, enabled_timeslots)
        "#{index + 1}."
      else
        "-"
      end

    Map.put(timeslot, :bullet, bullet)
  end

  defp update_entry(
         :timeslot_number_of_seats,
         %{type: :time_slot, number_of_reservations: number_of_reservations} = timeslot,
         number_of_seats
       ) do
    if number_of_seats >= number_of_reservations do
      Map.put(timeslot, :number_of_seats, number_of_seats)
    else
      Map.put(timeslot, :number_of_seats, number_of_reservations)
    end
  end

  defp update_entry(:timeslot_target, %{type: :time_slot} = timeslot, id) do
    Map.put(timeslot, :target, %{type: __MODULE__, id: id})
  end

  defp update_entry(_, entry, _timeslots), do: entry

  defp update_byline(socket) do
    time_slots =
      dngettext("link-lab", "1 time slot", "%{count} time slots", number_of_time_slots(socket))

    seats = dngettext("link-lab", "1 seat", "%{count} seats", number_of_seats(socket))

    byline = dgettext("link-lab", "day.schedule.byline", time_slots: time_slots, seats: seats)
    assign(socket, byline: byline)
  end

  defp enabled_time_slots(%{assigns: %{day_model: %{entries: entries}}}) do
    entries |> Enum.filter(&(&1.type == :time_slot and &1.enabled?))
  end

  defp number_of_time_slots(socket) do
    socket
    |> enabled_time_slots()
    |> Enum.count()
  end

  defp number_of_seats(socket) do
    socket
    |> enabled_time_slots()
    |> Enum.reduce(0, &(&2 + &1.number_of_seats))
  end

  @impl true
  def handle_event(
        "update",
        %{"day_model" => new_day_model},
        %{assigns: %{day_model: day_model}} = socket
      ) do
    changeset = Lab.DayModel.changeset(day_model, :submit, new_day_model)

    socket =
      case Ecto.Changeset.apply_action(changeset, :update) do
        {:ok, new_day_model} ->
          changeset = Lab.DayModel.changeset(new_day_model, :submit, %{})
          socket |> assign(changeset: changeset, day_model: new_day_model)

        {:error, %Ecto.Changeset{} = changeset} ->
          socket |> assign(changeset: changeset, focus: "")
      end

    {:noreply, socket |> update_ui()}
  end

  @impl true
  def handle_event("submit", _, %{assigns: %{day_model: day_model, target: target}} = socket) do
    update_target(target, %{day_view: :submit, day_model: day_model})
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, %{assigns: %{target: target}} = socket) do
    update_target(target, %{day_view: :hide})
    {:noreply, socket}
  end

  @impl true
  def handle_event("focus", %{"field" => field}, socket) do
    {:noreply, socket |> assign(focus: field)}
  end

  @impl true
  def handle_event("reset_focus", _, socket) do
    {:noreply, socket |> assign(focus: "")}
  end

  defp buttons(%{myself: myself}) do
    [
      %{
        action: %{type: :submit},
        face: %{type: :primary, label: dgettext("link-lab", "day.schedule.submit.button")}
      },
      %{
        action: %{type: :send, event: "cancel", target: myself},
        face: %{type: :label, label: dgettext("eyra-ui", "cancel.button")}
      }
    ]
  end

  @impl true
  def render(assigns) do
    ~F"""
      <div class="p-8 w-popup-md bg-white shadow-2xl rounded" phx-click="reset_focus" phx-target={@myself}>
        <div>
          <div class="text-title5 font-title5 sm:text-title3 sm:font-title3">
            {@title}
          </div>
          <Spacing value="XS" />

          <Form id="reject_form" changeset={@changeset} change_event="update" submit="submit" target={@myself} focus={@focus} >
            <Wrap>
              <DateInput :if={@day_model.date_editable?} field={:date} label_text={dgettext("link-lab", "day.schedule.date.label")} />
            </Wrap>
            <div class="flex flex-row gap-8">
              <div class="flex-grow">
                <TextInput field={:location} label_text={dgettext("link-lab", "day.schedule.location.label")} debounce="0"/>
              </div>
              <div class="w-24">
                <NumberInput field={:number_of_seats} label_text={dgettext("link-lab", "day.schedule.seats.label")} debounce="0"/>
              </div>
            </div>
            <SubHead color="text-grey2">
              {{@byline}}
            </SubHead>
            <Spacing value="M" />
            <Line />
            <div class="h-lab-day-popup-list overflow-y-scroll overscroll-contain">
              <div class="h-2"></div>
              <div class="w-full">
              <div :for={entry <- @day_model.entries} >
                <Lab.DayEntryListItem {...entry} />
                </div>
              </div>
            </div>
            <Line />
            <Spacing value="M" />
            <div class="flex flex-row gap-4">
              <DynamicButton :for={button <- buttons(assigns)} vm={button} />
            </div>
          </Form>
        </div>
      </div>
    """
  end
end

defmodule Systems.Lab.DayView.Example do
  use Surface.Catalogue.Example,
    subject: Systems.Lab.DayView,
    catalogue: Frameworks.Pixel.Catalogue,
    title: "Lab day view",
    height: "1740px",
    direction: "vertical",
    container: {:div, class: ""}

  data(day_model, :map,
    default: %Systems.Lab.DayModel{
      date: ~D[2022-12-13],
      date_editable?: true,
      location: "Lab 007, Unit 4.02",
      number_of_seats: 10,
      entries: [
        %{type: :time_slot, enabled?: true, start_time: 900, number_of_reservations: 6},
        %{type: :time_slot, enabled?: true, start_time: 930, number_of_reservations: 2},
        %{type: :time_slot, enabled?: true, start_time: 1000, number_of_reservations: 0},
        %{type: :time_slot, enabled?: false, start_time: 1030, number_of_reservations: 0},
        %{type: :break},
        %{type: :time_slot, enabled?: true, start_time: 1100, number_of_reservations: 0},
        %{type: :time_slot, enabled?: true, start_time: 1130, number_of_reservations: 0},
        %{type: :time_slot, enabled?: true, start_time: 1200, number_of_reservations: 0},
        %{type: :time_slot, enabled?: true, start_time: 1230, number_of_reservations: 0},
        %{type: :break},
        %{type: :time_slot, enabled?: false, start_time: 1300, number_of_reservations: 0},
        %{type: :time_slot, enabled?: true, start_time: 1330, number_of_reservations: 0},
        %{type: :time_slot, enabled?: true, start_time: 1400, number_of_reservations: 0},
        %{type: :time_slot, enabled?: true, start_time: 1430, number_of_reservations: 0},
        %{type: :break},
        %{type: :time_slot, enabled?: false, start_time: 1500, number_of_reservations: 0},
        %{type: :time_slot, enabled?: true, start_time: 1530, number_of_reservations: 0},
        %{type: :time_slot, enabled?: true, start_time: 1600, number_of_reservations: 0},
        %{type: :time_slot, enabled?: true, start_time: 1630, number_of_reservations: 0},
        %{type: :time_slot, enabled?: true, start_time: 1700, number_of_reservations: 0},
        %{type: :break},
        %{type: :time_slot, enabled?: false, start_time: 1730, number_of_reservations: 0},
        %{type: :time_slot, enabled?: false, start_time: 1800, number_of_reservations: 0},
        %{type: :time_slot, enabled?: false, start_time: 1830, number_of_reservations: 0},
        %{type: :time_slot, enabled?: false, start_time: 1900, number_of_reservations: 0},
        %{type: :time_slot, enabled?: false, start_time: 1930, number_of_reservations: 0}
      ]
    }
  )

  def render(assigns) do
    ~F"""
      <DayView id={:day_view_example} day_model={@day_model} target={self()}/>
    """
  end

  def handle_info(%{day_view: :submit, day_model: day_model}, socket) do
    IO.puts("submit: day_model=#{day_model.date}")
    {:noreply, socket}
  end

  def handle_info(%{day_view: :hide}, socket) do
    IO.puts("cancel")
    {:noreply, socket}
  end
end