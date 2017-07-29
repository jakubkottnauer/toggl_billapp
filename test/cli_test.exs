defmodule TogglBillapp.CLITest do
  @moduledoc """
  CLI tests
  """

  use ExUnit.Case
  doctest TogglBillapp.CLI
  import TogglBillapp.CLI

  describe "extract_project_hours" do
    test "returns correct data" do
      data = %{
        data: [
          %{id: 1234,
          items: [], time: 60_000,
          title: %{client: "a client", color: "0", hex_color: "#04bb9b",
          project: "amazing project"},
          total_currencies: [%{amount: nil, currency: nil}]},
          %{id: 567,
          items: [], time: 1_711_000,
          title: %{client: "second client", color: "0", hex_color: "#4dc3ff",
          project: "another great project"},
          total_currencies: [%{amount: nil, currency: nil}]}
          ],
          total_billable: 324_603_000, total_currencies: [%{amount: nil, currency: nil}],
          total_grand: 326_404_000
      }

      expected_result = [
        %{ project: "amazing project", hours: 0.02 },
        %{ project: "another great project", hours: 0.48 }
      ]

      assert extract_project_hours(data) == expected_result
    end
  end

  describe "translate_project_names" do
    test "translates project names" do
      dictionary = %{ "amazing project" => "HR consulting"}
      data = [
        %{ project: "amazing project", hours: 1.0 },
        %{ project: "another great project", hours: 28.52 }
      ]

      expected_result = [
        %{ project: "HR consulting", hours: 1.0 },
        %{ project: "another great project", hours: 28.52 }
      ]
    
      assert translate_project_names(data, dictionary) == expected_result
    end

    test "translate_project_names works with empty dictionary and does not modify input" do
      dictionary = %{}
      data = [
        %{ project: "amazing project", hours: 1.0 },
        %{ project: "another great project", hours: 28.52 }
      ]

      assert translate_project_names(data, dictionary) == data
    end
  end
end
