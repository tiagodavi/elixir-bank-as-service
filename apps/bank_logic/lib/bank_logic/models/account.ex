defmodule BankLogic.Models.Account do
  @moduledoc """
  Account Model to handle business rules
  """

  import Ecto.Query, warn: false
  alias BankLogic.Repo
  alias BankLogic.Schemas.Account

  def create_account(attrs) do
    %Account{}
    |> Account.create_account_changeset(attrs)
    |> Repo.insert()
  end

  # def get_by(conditions) do
  #   Repo.get_by(TelephoneCall, conditions)
  # end

  # def info(phone_number, period \\ nil) do
  #   query =
  #     from(
  #       t0 in TelephoneCall,
  #       join: t1 in TelephoneCall,
  #       on: t0.call_id == t1.call_id,
  #       select: %{
  #         destination: t0.destination,
  #         call_start: t0.timestamp,
  #         rule_id: t0.rule_id,
  #         call_end: t1.timestamp
  #       },
  #       where: t0.source == ^phone_number,
  #       where: t0.type == "start",
  #       where: t1.type == "end"
  #     )
  #
  #   if period do
  #     [month, year] = String.split(period, "/")
  #     month = String.to_integer(month)
  #     year = String.to_integer(year)
  #
  #     q =
  #       from(
  #         [_, t1] in query,
  #         where: fragment("EXTRACT(MONTH FROM ?)", t1.timestamp) == ^month,
  #         where: fragment("EXTRACT(YEAR FROM ?)", t1.timestamp) == ^year
  #       )
  #
  #     Repo.all(q)
  #   else
  #     previous =
  #       NaiveDateTime.utc_now()
  #       |> NaiveDateTime.add(-2_592_000)
  #
  #     q =
  #       from(
  #         [_, t1] in query,
  #         where: fragment("EXTRACT(MONTH FROM ?)", t1.timestamp) == ^previous.month,
  #         where: fragment("EXTRACT(YEAR FROM ?)", t1.timestamp) == ^previous.year
  #       )
  #
  #     Repo.all(q)
  #   end
  # end
end
