defmodule BfgCore.Account.AccountInfoService do
  # TODO could do this into genserver and poll account data, dont want to call at every order
  # OBS OBS I must do this!!!
  @account_data_provider Application.get_env(:bfg_core, :account_data_provider)
  #  @current_price_info_provider Application.get_env(:bfg_core, :current_price_info_provider)
  #  @provider_helper Application.get_env(:bfg_core, :provider_helper)

  @min_amount_required Application.get_env(:bfg_core, :min_amount_required)

  def get_all_accounts do
    @account_data_provider.get_latest_account_info()
  end

  def get_account_info(account_id) do
    @account_data_provider.get_latest_account_info(account_id)
  end

  def find_accounts_to_trade do
    get_all_accounts()
    |> Enum.filter(&filter_accounts/1)
  end

  defp filter_accounts(account) do
    account.avaliable_to_trade >= @min_amount_required
  end
end
