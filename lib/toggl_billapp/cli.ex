defmodule TogglBillapp.CLI do
  def main(args) do
    togglApiKey = Application.get_env(:toggl_billapp, :togglApiKey)
    togglWorkspaceId = Application.get_env(:toggl_billapp, :togglWorkspaceId)
    togglUserId = Application.get_env(:toggl_billapp, :togglUserId)
    client = Togglex.Client.new(%{access_token: togglApiKey}, :reports)
    x = Togglex.Reports.summary(client, %{workspace_id: togglWorkspaceId, user_ids: togglUserId, grouping: "projects", subgrouping: "time_entries", since: "2017-07-01", until: "2017-07-31"})
    IO.inspect x
  end
end
