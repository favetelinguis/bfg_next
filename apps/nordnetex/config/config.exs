# This file is responsible for configuring your application
use Mix.Config

config :nordnetex,
  service_id: "NEXTAPI",
  api_version: "2",
  public_key_filename: "NEXTAPI_TEST_public.pem",
  nordnet_user: System.get_env("NORDNET_USERNAME"),
  nordnet_password: System.get_env("NORDNET_PASSWORD"),
  stream_connector: Nordnetex.Stream.StreamConnectorProviderService

import_config "#{Mix.env()}.exs"
