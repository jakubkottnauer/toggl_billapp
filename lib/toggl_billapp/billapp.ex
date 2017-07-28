defmodule TogglBillapp.Billapp do
  @moduledoc """
  Module for billapp communication
  """

  def get_last_invoice do
    billapp_url = Application.get_env(:toggl_billapp, :billapp_url)
    billapp_email = Application.get_env(:toggl_billapp, :billapp_email)
    billapp_password = Application.get_env(:toggl_billapp, :billapp_password)
    options = [hackney: [basic_auth: {billapp_email, billapp_password}], ssl: [{:versions, [:'tlsv1.2']}]]
    headers = [{"Content-Type", "application/json"}, {"Accept", "application/json"}]
    HTTPoison.get(billapp_url, headers, options)
  end
end
