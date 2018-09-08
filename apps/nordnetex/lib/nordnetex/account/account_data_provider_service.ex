defmodule Nordnetex.Account.AccountDataProviderService do
  @behaviour BfgCore.Account.AccountDataProvider

  require Logger
  import Nordnetex.Session.SessionManager, only: [get: 1]
  alias BfgCore.Account

  @impl true
  def get_latest_account_info do
    {:ok, response} = get("/accounts")

    response
    # remove blocked accounts
    |> Enum.filter(fn account -> !account["is_blocked"] end)
    |> Enum.map(fn account -> get_latest_account_info(account["accno"]) end)
  end

  @impl true
  def get_latest_account_info(account_id) do
    {:ok, response} = get("/accounts/#{account_id}")

    response
    |> map_to_account(account_id)
  end

  defp map_to_account(account_info, account_id) do
    Account.new(
      account_id: account_id,
      total_balance: get_in(account_info, ["account_sum", "value"]),
      avaliable_to_trade: get_in(account_info, ["trading_power", "value"]),
      currency: account_info["account_currency"]
    )
  end
end
