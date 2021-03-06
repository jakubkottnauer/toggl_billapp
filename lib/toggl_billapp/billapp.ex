defmodule TogglBillapp.Billapp do
  use Timex

  @moduledoc """
  Module for billapp communication
  """

  defp billapp_url do Application.get_env(:toggl_billapp, :billapp_url) end
  defp request_headers do [{"Content-Type", "application/json"}, {"Accept", "application/json"}] end
  defp request_options do
    billapp_email = Application.get_env(:toggl_billapp, :billapp_email)
    billapp_password = Application.get_env(:toggl_billapp, :billapp_password)
    [hackney: [basic_auth: {billapp_email, billapp_password}], ssl: [{:versions, [:'tlsv1.2']}]]
  end

  defp get_billapp(url) do
    HTTPoison.get!("#{billapp_url}/#{url}", request_headers, request_options).body 
  end

  defp post_billapp(url, json) do
    HTTPoison.post!("#{billapp_url}/#{url}", json, request_headers, request_options)
  end

  def get_last_invoice_data do
    last_invoice = get_billapp("invoices")
      |> Poison.decode!
      |> Enum.at(0)
      |> Map.get("invoice")

    %{
      id: last_invoice["id"],
      account_id: last_invoice["account_id"],
      client_id: last_invoice["client_id"],
      number: last_invoice["number"]
    }
  end

  @doc """
  Returns JSON to be sent to billapp

  ## Parameters
    - data: Array of projects and time spent on them
  """
  defp compose_billapp_request(data) do
    today = Timex.now
    last_invoice = get_last_invoice_data
    %{
      "invoice": %{
        "number": "2017000255",
        "account_id": last_invoice.account_id,
        "client_id": last_invoice.client_id,
        "issue_date": Timex.format!(today, "%F", :strftime),
        "due_date": Timex.format!(Timex.shift(today, days: 15), "%F", :strftime),
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

  @doc """
  Sends JSON to billapp to create a new invoice.

  Returns the newly created invoice

  ## Parameters
    - json: json to send
  """
  def send_invoice(data) do
    json = compose_billapp_request(data)
    post_billapp("invoices", json)
    get_last_invoice_data
  end

  @doc """
  Downloads invoice with the specified ID.

  ## Parameters
    - id: Id of the invoice to download. Invoice is saved to invoice_{id}.pdf
  """
  def download_invoice_pdf(id) do
    body = get_billapp("invoices/#{id}.pdf")
    filename = "tmp/invoice_#{id}.pdf"
    File.write!(filename, body)
    filename
  end
end
