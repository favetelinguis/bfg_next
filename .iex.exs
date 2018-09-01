# Load another ".iex.exs" file
# import_file "~/.iex.exs"

# Import some module from lib that may not yet have been defined
# import_if_available MyApp.Mod

# Print something before the shell starts
# IO.puts "hello world"

alias Nordnetex.Rest.SessionManager

usr = Application.get_env(:bfg_engine, :betfair_user)
pwd = Application.get_env(:bfg_engine, :betfair_password)
key = Application.get_env(:bfg_engine, :betfair_app_key)

login = fn -> SessionManager.start_link(usr, pwd, key) end
#bfsup = fn -> BfgEngine.Betfairex.BetfairexSupervisor.start_link(nil) end
#invalidate = fn -> BfgEngine.Betfairex.Session.SessionManager.invalidate_session() end
# {:ok, pid} = Connection.start_link(usr, pwd, "aa")
