defmodule TogglBillapp.CLI do
  @moduledoc """
  CLI interface of the app.
  """

  def main(args) do
    get_last_month_toggl()
    |> extract_project_hours
  end

  def get_last_month_toggl do
    toggl_api_key = Application.get_env(:toggl_billapp, :toggl_api_key)
    toggl_workspace_id = Application.get_env(:toggl_billapp, :toggl_workspace_id)
    toggl_user_id = Application.get_env(:toggl_billapp, :toggl_user_id)

    Togglex.Client.new(%{access_token: toggl_api_key}, :reports)
    |> Togglex.Reports.summary(
      %{
        grouping: "projects",
        since: "2017-07-01",
        subgrouping: "time_entries",
        until: "2017-07-31",
        user_ids: toggl_user_id,
        workspace_id: toggl_workspace_id
      })
  end

  @doc """
  Extracts time spent on projects from toggl data

  ## Parameters
    - data: Data received from toggl
  """
  def extract_project_hours(data) do
    data.data
    |> Enum.reduce [], fn record, acc ->
        acc ++ [%{ project: record.title.project, hours: Float.round(record.time / 1_000 / 60, 2)  }] 
      end 
  end
end
