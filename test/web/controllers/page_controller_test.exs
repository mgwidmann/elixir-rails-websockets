defmodule ElixirRailsWebsockets.PageControllerTest do
  use ExUnit.Case, async: true
  alias ElixirRailsWebsockets.PageController
  import Mock

  # Sometimes outputs a "Error in process" badarg error. Needs investigation
  test "renders index" do
    with_mock Phoenix.Controller, [render: fn(_, _)-> end] do
      PageController.index(%{}, %{})
      assert called Phoenix.Controller.render(%{}, "index.html")
    end
  end

end
