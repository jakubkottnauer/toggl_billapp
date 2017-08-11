defmodule TogglBillapp.CLI do
  @moduledoc """
  CLI interface of the app.
  """

  alias TogglBillapp.Billapp, as: Billapp
  alias TogglBillapp.Cheddar, as: Cheddar

  def main(args) do
    dictionary = %{
      "Self-study" => ["Konzultace", "Školení", "Textace", "Opravy IDK"]
    }

    department_projects = %{
      "blueberryapps" => ["Self-study", "_Other", "Open-Source", "Human resources", "Bonuses"]
    }

    defaultDepartment = "DevTeam"

    get_last_month_toggl()
    |> extract_project_hours
    #|> split_into_departments
    |> translate_project_names(dictionary)
    |> Billapp.send_invoice
    |> Map.get(:id)
    |> Billapp.download_invoice_pdf
    |> Cheddar.send_invoice
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

  def split_into_departments(data) do
    data
    |> Enum.group_by(fn x -> 
      
    end)
  end

  @doc """
  Extracts time spent on projects from toggl data

  ## Parameters
    - data: Data received from toggl
  """
  def extract_project_hours(data) do
    data.data
    |> Enum.reduce([], fn record, acc ->
        acc ++ [%{ project: record.title.project, hours: Float.round(record.time / 1_000 / 60 / 60, 2)  }] 
      end)
  end

  defp get_project_translation(translations) when is_list(translations) do
    translations |> Enum.random
  end

  defp get_project_translation(translation) do
    translation
  end

  @doc """
  Translates project names using a dictionary.
  Useful for renaming projects like "Self-study" to "HR consulting" or whatever.
  If a list of translations is specified for a key, a random one is chosen :-)

  ## Parameters
    - data: Array of projects and time spent on them
    - dictionary: Map with project names translations
  """
  def translate_project_names(data, dictionary) do
    data
    |> Enum.map(fn entry 
      ->
        project = Map.get(dictionary, entry.project, entry.project)
        Map.put(entry, :project, get_project_translation(project))
    end)
  end
end
