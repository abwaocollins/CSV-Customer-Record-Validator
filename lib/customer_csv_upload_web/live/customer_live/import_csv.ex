defmodule CustomerCsvUploadWeb.CustomerLive.ImportCsv do
  use CustomerCsvUploadWeb, :live_view
  alias CustomerCsvUpload.Customers

  require Jason

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(records: [])
     |> assign(:uploaded_files, [])
     |> assign(:loading, false)
     |> assign(:loading_message, "")
     |> assign(:complete, false)
     |> allow_upload(:csv, accept: ~w(.csv), max_entries: 1)}
  end

  @impl Phoenix.LiveView
  def handle_event("upload", _params, socket) do
    send(self(), :parse_csv)

    {:noreply,
     socket
     |> assign(loading: true)
     |> assign(loading_message: "Processing in progress...")}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info(:parse_csv, socket) do
    [csv_validated_data | _tail] =
      consume_uploaded_entries(socket, :csv, fn %{path: path_to_file}, _entry ->
        filtered_data = Customers.upload_data(path_to_file)
        {:ok, filtered_data}
      end)

    Enum.each(csv_validated_data, &send(self(), {:show_row_info, &1}))
    send(self(), :create_json_download)
    send(self(), :complete_processing)

    row_count = length(csv_validated_data)

    {:noreply,
     socket
     |> assign(records: csv_validated_data)
     |> assign(loading_message: "Processing #{row_count} rows ...")}
  end

  @impl Phoenix.LiveView
  def handle_info({:show_row_info, _csv_validated_data}, socket) do
    Process.sleep(1000)

    {:noreply,
     socket
     |> assign(loading_message: "Processing data ")}
  end

  def handle_info(:create_json_download, %{assigns: %{records: records}} = socket) do
    # Call a function to prepare the JSON data
    json_data = prepare_json_data(records)

    # Call the save_json function to save the JSON data to a file
    save_json(json_data)

    file_path = Routes.static_path(socket, "/uploads/uploaded_data.json")

    {:noreply,
     socket
     |> assign(loading_message: "Creating JSON file...")
     |> assign(uploaded_files: [file_path])}
  end

  @impl Phoenix.LiveView
  def handle_info(:complete_processing, socket) do
    Process.sleep(1000)

    {:noreply,
     socket
     |> assign(loading_message: "")
     |> assign(loading: false)
     |> assign(complete: true)}
  end

  defp prepare_json_data(json_data) do
    Jason.encode!(json_data)
  end

  defp save_json(json_data) do
    file_path = "priv/static/uploads/uploaded_data.json"
    File.write!(file_path, json_data)
  end
end
