defmodule BankLogic do
  @moduledoc """
  Public interface to access Bank Logic
  """

  alias BankLogic.Account

  def all do
    Account.all()
  end

  def open do
    Account.create()
  end

  def balance(attrs) do
    Account.balance(attrs)
  end

  def report(attrs) do
    Account.report(attrs)
  end

  def transfer(attrs) do
    Account.transfer(attrs)
  end

  def cash_out(attrs) do
    Account.cash_out(attrs)
  end
end
