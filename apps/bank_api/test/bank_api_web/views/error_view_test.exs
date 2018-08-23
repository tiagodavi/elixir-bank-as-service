defmodule BankApiWeb.ErrorViewTest do
  use BankApiWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(BankApiWeb.ErrorView, "404.json", []) == %{errors: "Endpoint not found!"}
  end

  test "renders 500.json" do
    assert render(BankApiWeb.ErrorView, "500.json", []) == %{errors: "Internal Server Error!"}
  end
end
