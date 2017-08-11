defmodule TogglBillapp.Cheddar do
  use Timex

  @moduledoc """
  Module for Cheddar communication
  """

  defp cheddar_url do Application.get_env(:toggl_billapp, :cheddar_url) end
  defp cheddar_api_key do Application.get_env(:toggl_billapp, :cheddar_api_key) end
  defp request_headers do [{"Content-Type", "application/json"}, {"Accept", "application/json"}, {"Authorization", "Token token=\"#{:cheddar_api_key}\""}] end

  defp post(url, json) do
    HTTPoison.post!("#{cheddar_url}/#{url}", json, request_headers, [])
  end


    @doc """
  Returns JSON to be sent to billapp

  ## Parameters
    - data: Array of projects and time spent on them
  """
  defp compose_request() do
    today = Timex.now
    %{
    }
    |> Poison.encode!
  end
  
  @doc """
  Sends JSON to Cheddar to create a new invoice.

  ## Parameters
    - path: path to the PDF file
  """
  def send_invoice(path) do
    json = compose_request()
    post("invoices", json)
  end
end
