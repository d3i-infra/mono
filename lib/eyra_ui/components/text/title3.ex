defmodule EyraUI.Text.Title3 do
  @moduledoc """
  This title is to be used for ...?
  """
  use Surface.Component

  slot default, required: true

  def render(assigns) do
    ~H"""
    <div class="text-title5 font-title5 sm:text-title4 sm:font-title4 lg:text-title3 lg:font-title3 mt-12 lg:mt-16 mb-7 lg:mb-9">
      <slot />
    </div>
    """
  end
end