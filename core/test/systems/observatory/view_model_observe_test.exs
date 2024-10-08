defmodule Systems.Observatory.ViewModelObserveTest do
  use CoreWeb.ConnCase
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import Core.AuthTestHelpers

  alias Systems.Test

  describe "View model roundtrip" do
    setup [:login_as_member]

    test "View model initialize", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/test/page/1")

      assert html =~ "John Doe"
      assert html =~ "Age: 56 - Works at: The Basement"
      assert html =~ "view_model_updated: 0"
    end

    test "View model update", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/test/page/1")

      model = Test.Public.get(1)
      Test.Public.update(model, %{age: 57})

      html = render(view)

      assert html =~ "Age: 57 - Works at: The Basement"
      assert html =~ "view_model_updated: 1"
    end
  end
end
