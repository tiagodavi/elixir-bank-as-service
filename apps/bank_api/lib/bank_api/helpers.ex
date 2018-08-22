defmodule BankApi.Helpers do
  @moduledoc """
    This module is automatically imported for all controllers to provide
    a custom way to send errors to the client
  """

  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [render: 3, put_view: 2]

  def send_error(conn, code, message) when is_binary(message) do
    conn |> prepare_send_error(code) |> render("#{code}.json", %{errors: message})
  end

  def send_error(conn, code, changeset) do
    errors = extract_changeset_errors(changeset)
    conn |> prepare_send_error(code) |> render("#{code}.json", %{errors: errors})
  end

  defp extract_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp prepare_send_error(conn, code) do
    conn
    |> put_status(code)
    |> put_view(BankApiWeb.ErrorView)
  end
end
