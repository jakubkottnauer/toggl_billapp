defmodule TogglBillapp.Billapp do
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
      account_id: last_invoice["account_id"],
      client_id: last_invoice["client_id"],
      number: last_invoice["number"]
    }
  end

  def send_invoice(json) do
    post_billapp("invoices", json)
  end
end
