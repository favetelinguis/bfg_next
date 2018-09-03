defmodule BfgCore.Instrument.InstrumentService do
    # TODO I could use a gen service here and in intit read a config of all the instruments I want to trade
    # and then in init get all the instrument and store internal from the @instrument_provider
    # This should also be the place where I setup subscription on market stream for the instruments i hold in cache
    # should have a fn like update with where I setup the subset of instrument i want here
    # @instrument_provider Application.get_env(:bfg_core, :instrument_provider)

    @doc """
    Used to place orders or stops for example to place a order 30 ticks below current price
    current price - 30 * get_pip_for_instrument(122)
    """
    def get_pip_for_instrument(_id) do
        1
    end
     
    def get_instruments() do
        [2]
    end

    def get_all_instruments_for_currency(currency) do
        [33]
    end
end