defmodule CustomerCsvUpload.Customers do
  alias CustomerCsvUpload.Customers.Customer

  def change_customer(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

  def upload_data(file_path) do
    file_path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream()
    |> map_csv_rows()
    |> validate_csv_entries(%Customer{})
    |> change_to_required_format()
  end

  defp map_csv_rows(data) do
    Enum.map(data, fn [name, dob, phone, nationalID, countryID, siteCode] ->
      %{
        name: name,
        dob: dob,
        phone: phone,
        nationalID: nationalID,
        countryID: countryID,
        siteCode: siteCode
      }
    end)
  end

  defp validate_csv_entries(entries, customer) do
    Enum.map(entries, fn entry ->
      customer
      |> change_customer(entry)
    end)
  end

  defp change_to_required_format(changesets) do
    Enum.reduce(changesets, {[], 0}, fn changeset, {acc, line_number} ->
      case changeset do
        %Ecto.Changeset{
          valid?: true,
          changes: %{
            name: name,
            dob: dob,
            phone: phone,
            countryID: country_id,
            siteCode: site_code
          },
          errors: _errors
        } ->
          new_entry = %{
            Name: name,
            DoB: dob,
            Phone: phone,
            NationalID: get_national_id(changeset),
            CountryID: country_id,
            SiteCode: site_code
          }

          {[new_entry | acc], line_number + 1}

        %Ecto.Changeset{
          errors: changeset_errors
        } ->
          error_entries =
            Enum.map(changeset_errors, fn {key, {error_message, _}} ->
              to_string(key) <> " " <> error_message
            end)

          error_entry =
            if Enum.empty?(error_entries) do
              nil
            else
              %{
                error: error_entries,
                line: line_number + 1
              }
            end

          {[error_entry | acc], line_number + 1}

        _ ->
          {acc, line_number + 1}
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  defp get_national_id(changeset) do
    case Ecto.Changeset.get_change(changeset, :nationalID) do
      nil -> nil
      value -> to_string(value)
    end
  end
end
