defmodule CustomerCsvUpload.Customers.Customer do
  defstruct [:name, :dob, :phone, :nationalID, :countryID, :siteCode]

  @types %{
    name: :string,
    dob: :date,
    phone: :string,
    nationalID: :string,
    countryID: :integer,
    siteCode: :integer
  }

  alias CustomerCsvUpload.Customers.Customer

  import Ecto.Changeset

  def changeset(%Customer{} = customer, attrs) do
    {customer, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:name, :dob, :phone, :countryID, :siteCode])
    |> validate_name_is_non_empty_string()
    |> validate_inclusion(:countryID, 1..3,
      message: "is invalid, it should be an integer of 1: Kenya, 2: Sierra Leone, 3: Nigeria"
    )
    |> validate_phone_format()
    |> validate_country_site()
  end

  defp validate_name_is_non_empty_string(changeset) do
    name = get_field(changeset, :name)

    if is_binary(name) && String.trim(name) == "" do
      changeset |> add_error(:name, " must not be an empty string")
    else
      changeset
    end
  end

  defp validate_phone_format(changeset) do
    validate_format(changeset, :phone, ~r/^\+?\d{12}$/,
      message: " number must be in the format 254759635432"
    )
  end

  defp validate_country_site(changeset) do
    country_id = get_field(changeset, :countryID)
    site_code = get_field(changeset, :siteCode)

    valid_site_codes =
      case country_id do
        # Kenya
        1 -> [235, 657, 887]
        # Sierra Leone
        2 -> [772, 855]
        # Nigeria
        3 -> [465, 811, 980]
        _ -> []
      end

    countries =
      case country_id do
        1 -> "Kenya"
        2 -> "Sierra Leone"
        3 -> "Nigeria"
        _ -> "Kenya, Sierra Leone and Nigeria"
      end

    if site_code in valid_site_codes do
      changeset
    else
      changeset
      |> add_error(:siteCode, " #{site_code} does not exist in #{countries}")
    end
  end
end
