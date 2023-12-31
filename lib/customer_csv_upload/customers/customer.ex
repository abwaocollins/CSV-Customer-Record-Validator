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
    |> validate_phone_number()
    |> validate_country_site()
    |> validate_phone_number()
  end

  defp validate_name_is_non_empty_string(changeset) do
    name = get_field(changeset, :name)

    if is_binary(name) && String.trim(name) == "" do
      changeset |> add_error(:name, " must not be an empty string")
    else
      changeset
    end
  end

  defp validate_phone_number(changeset) do
    country_id = get_field(changeset, :countryID)
    phone_number = get_field(changeset, :phone)

    case country_id do
      1 -> validate_kenya_phone_number(phone_number, changeset)
      2 -> validate_sierra_leone_phone_number(phone_number, changeset)
      3 -> validate_nigeria_phone_number(phone_number, changeset)
      _ -> changeset
    end
  end

  defp validate_kenya_phone_number(phone, changeset) do
    valid_regex = ~r/^254\d{9}$/

    if Regex.match?(valid_regex, phone) do
      changeset
    else
      changeset
      |> add_error(:phone, "#{phone} is not a valid Kenya phone number")
    end
  end

  defp validate_sierra_leone_phone_number(phone, changeset) do
    valid_regex = ~r/^232\d{8}$/

    if Regex.match?(valid_regex, phone) do
      changeset
    else
      changeset
      |> add_error(:phone, "#{phone} is not a valid Sierra Leone phone number")
    end
  end

  defp validate_nigeria_phone_number(phone, changeset) do
    valid_regex = ~r/^234\d{10}$/

    if Regex.match?(valid_regex, phone) do
      changeset
    else
      changeset
      |> add_error(:phone, "#{phone} is not a valid Nigeria phone number")
    end
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
