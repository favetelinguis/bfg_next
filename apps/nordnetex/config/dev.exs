use Mix.Config

config :nordnetex,
  base_url: "https://api.test.nordnet.se/next/",
  service_id: "NEXTAPI",
  api_version: "2",
  public_key_filename: "NEXTAPI_TEST_public.pem",
  nordnet_user: System.get_env("NORDNET_USERNAME"),
  nordnet_password: System.get_env("NORDNET_PASSWORD")

config :logger,
  level: :info
