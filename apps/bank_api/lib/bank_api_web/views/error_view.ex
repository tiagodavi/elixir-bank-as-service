defmodule BankApiWeb.ErrorView do
  use BankApiWeb, :view

  def render("404.json", assigns) do
    handle_assign_error("Endpoint not found!", assigns)
  end

  def render("500.json", assigns) do
    handle_assign_error("Internal Server Error!", assigns)
  end

  defp handle_assign_error(message, assigns) do
    case has_assign_error_key?(assigns) do
      {:ok, errors} ->
        %{errors: %{message: errors}}

      _ ->
        %{errors: %{message: message}}
    end
  end

  defp has_assign_error_key?(assigns) do
    if Map.has_key?(assigns, :errors) do
      {:ok, assigns.errors}
    else
      nil
    end
  end

  # In case no render clause matches or no
  # template is found, let's render it as 404
  def template_not_found(_template, assigns) do
    render("404.json", assigns)
  end
end
