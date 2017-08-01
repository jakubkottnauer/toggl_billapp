defmodule TogglBillapp.CLI do
  @moduledoc """
  CLI interface of the app.
  """

  alias TogglBillapp.Billapp, as: Billapp

  def main(args) do
    dictionary = %{
      "Self-study" => ["Konzultace", "Školení"]
    }

    get_last_month_toggl()
    |> extract_project_hours
    |> translate_project_names(dictionary)
    |> compose_billapp_request
    |> Billapp.send_invoice
    |> Map.get(:id)
    |> Billapp.download_invoice_pdf
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

  @doc """
  Returns JSON to be sent to billapp

  ## Parameters
    - data: Array of projects and time spent on them
  """
  def compose_billapp_request(data) do
    last_invoice = Billapp.get_last_invoice_data
    %{
      "invoice": %{
        "number": "2017000255",
        "account_id": last_invoice.account_id,
        "client_id": last_invoice.client_id,
        "issue_date": "2017-07-20",
        "due_date": "2017-07-30",
        "show_logo": false,
        "lines_attributes": Enum.map(data, fn entry
          -> %{
              "description": entry.project,
              "quantity": 10.0,
              "unit_price": 50.0,
              "vat": 0.0
            }
          end
          )
      }
    }
    |> Poison.encode!
  end
end
