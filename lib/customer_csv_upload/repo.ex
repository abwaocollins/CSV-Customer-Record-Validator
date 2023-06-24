defmodule CustomerCsvUpload.Repo do
  use Ecto.Repo,
    otp_app: :customer_csv_upload,
    adapter: Ecto.Adapters.Postgres
end
