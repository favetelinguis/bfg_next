defmodule Nordnetex.JsonKeys do
  @moduledoc false

  def account do
    %{
      account_number: "accno",
      type: "type",
      default: "default",
      alias: "alias",
      is_blocket: "is_blocked",
      blocked_reason: "blocked_reason"
    }
  end

  def account_info do
    %{
      account_currency: "account_currency",
      account_credit: "account_credit",
      account_sum: "account_sum",
      collateral: "collateral",
      credit_account_sum: "credit_account_sum",
      forward_sum: "forward_sum",
      future_sum: "future_sum",
      unrealized_future_profit_loss: "unrealized_future_profit_loss",
      full_marketvalue: "full_marketvalue",
      interest: "interest",
      intraday_credit: "intraday_credit",
      loan_limit: "loan_limit",
      own_capital: "own_capital",
      own_capital_morning: "own_capital_morning",
      pawn_value: "pawn_value",
      trading_power: "trading_power"
    }
  end

  def amount do
    %{
      value: "value",
      currency: "currency"
    }
  end
end
