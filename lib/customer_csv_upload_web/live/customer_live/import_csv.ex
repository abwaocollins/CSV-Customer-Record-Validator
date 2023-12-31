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
    [csv_validated_data | _tail] =
      consume_uploaded_entries(socket, :csv, fn %{path: path_to_file}, _entry ->
        copy_and_generate_static_path(path_to_file, socket)
        filtered_data = Customers.upload_data(path_to_file) |> IO.inspect(label: "++++")
        {:ok, filtered_data}
      end)

    Enum.each(csv_validated_data, &send(self(), {:show_row_info, &1}))
    send(self(), :create_json_download)
    send(self(), :complete_processing)

    row_count = length(csv_validated_data)

    {:noreply,
     socket
     |> assign(loading: true)
     |> assign(loading_message: "Processing in progress...")
     |> assign(records: csv_validated_data)
     |> assign(loading_message: "Processing #{row_count} rows ...")}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({:show_row_info, _csv_validated_data}, socket) do
    Process.sleep(1000)

    {:noreply,
     socket
     |> assign(loading_message: "Processing data ")}
  end

  def handle_info(:create_json_download, %{assigns: %{records: records}} = socket) do
    json_data = prepare_json_data(records)

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

  def error_to_string(:too_many_files), do: "You have selected too many files"
  def error_to_string(:too_large), do: "FIle is too large"

  def error_to_string(:not_accepted),
    do: "You have selected an unacceptable file type, required: csv file"

  defp copy_and_generate_static_path(path_to_file, socket) do
    file_name = Path.basename(path_to_file)
    dest = Path.join("priv/static/uploads", "#{Path.basename(file_name, ".csv")}.csv")
    File.cp!(path_to_file, dest)
    Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")
  end

  defp prepare_json_data(json_data) do
    Jason.encode!(json_data)
  end

  defp save_json(json_data) do
    file_path = "priv/static/uploads/uploaded_data.json"
    File.write!(file_path, json_data)
  end
end
