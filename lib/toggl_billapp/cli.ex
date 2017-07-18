defmodule TogglBillapp.CLI do
  def main(args) do
    togglApiKey = Application.get_env(:toggl_billapp, :togglApiKey)
    client = Togglex.Client.new(%{access_token: togglApiKey}, :api)
  end
end
