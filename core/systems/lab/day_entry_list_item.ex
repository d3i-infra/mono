defmodule Systems.Lab.DayEntryListItem do
  use CoreWeb.UI.Component

  alias Systems.Lab.{DayEntryBreakItem, DayEntryTimeSlotItem}

  prop(type, :atom, required: true)
  prop(props, :map, default: %{})

  defp module(:time_slot), do: DayEntryTimeSlotItem
  defp module(:break), do: DayEntryBreakItem

  def render(assigns) do
    ~F"""
      <Surface.Components.Dynamic.Component module={module(@type)} {...@props} />
    """
  end
end

defmodule Systems.Lab.DayEntryListItem.Example do
  use Surface.Catalogue.Example,
    subject: Systems.Lab.DayEntryListItem,
    catalogue: Frameworks.Pixel.Catalogue,
    title: "Day entry list item",
    height: "812px",
    direction: "vertical",
    container: {:div, class: ""}

  def handle_info(%{active_item_id: nil, selector_id: selector_id}, socket) do
    IO.puts("Disabled #{selector_id}")
    {:noreply, socket}
  end

  def handle_info(%{active_item_id: _active_item_id, selector_id: selector_id}, socket) do
    IO.puts("Enabled #{selector_id}")
    {:noreply, socket}
  end

  def render(assigns) do
    ~F"""
    <div class="flex flex-col">
      <DayEntryListItem type={:time_slot} props={%{start_time: 900, enabled: true, target: self()} }  />
      <DayEntryListItem type={:break} />
      <DayEntryListItem type={:time_slot} props={%{start_time: 1000, enabled: true, target: self()} } />
    </div>
    """
  end
end