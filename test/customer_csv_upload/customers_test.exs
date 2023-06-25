defmodule CustomerCsvUpload.CustomersTest do
  use ExUnit.Case

  alias CustomerCsvUpload.Customers
  alias CustomerCsvUpload.Customers.Customer

  @invalid_attrs %{
    name: nil,
    dob: "01-01-1990",
    phone: "1234567",
    countryID: 5,
    siteCode: 200
  }

  test "change_customer/2 returns the changeset with updated attributes" do
    customer = %Customer{
      name: "John",
      dob: "1990-01-01",
      phone: "1234567890",
      countryID: 1,
      siteCode: 235
    }

    attrs = %{name: "Jane"}

    changeset = Customers.change_customer(customer, attrs)

    assert %{name: "Jane"} == changeset.changes
    assert customer == changeset.data
  end

  test "change_customer/2 with invalid data returns error changeset" do
    changeset = Customers.change_customer(%Customer{}, @invalid_attrs)
    assert changeset.valid? == false
  end

  test "change_customer/2 returns a valid changeset without nationalID" do
    customer = %{
      name: "John",
      dob: "1990-01-01",
      phone: "254757127350",
      countryID: 1,
      siteCode: 235
    }

    changeset = Customers.change_customer(%Customer{}, customer)
    assert changeset.valid? == true
  end

  test "change_customer/2 returns a false changeset with an empty string name" do
    customer = %{
      name: "",
      dob: "1990-01-01",
      phone: "254757127350",
      countryID: 1,
      siteCode: 235
    }

    changeset = Customers.change_customer(%Customer{}, customer)
    assert changeset.valid? == false
  end

  test "change_customer/2 returns a false changeset with a date not an ISO 8601 date string" do
    customer = %{
      name: "Mat",
      dob: "01-01-1990",
      phone: "254757127350",
      countryID: 1,
      siteCode: 235
    }

    changeset = Customers.change_customer(%Customer{}, customer) |> IO.inspect()
    assert changeset.valid? == false
  end

  test "change_customer/2 returns a false changeset with a phone number that is not 12 digit" do
    customer = %{
      name: "Mat",
      dob: "1990-01-01",
      phone: "2547571273",
      countryID: 1,
      siteCode: 235
    }

    changeset = Customers.change_customer(%Customer{}, customer) |> IO.inspect()
    assert changeset.valid? == false
  end

  test "change_customer/2 returns a false changeset when countryID is greater than 3" do
    customer = %{
      name: "Mat",
      dob: "1990-01-01",
      phone: "2547571273",
      countryID: 5,
      siteCode: 235
    }

    changeset = Customers.change_customer(%Customer{}, customer) |> IO.inspect()
    assert changeset.valid? == false
  end

  test "change_customer/2 returns a false changeset when countryID is less than 1" do
    customer = %{
      name: "Mat",
      dob: "1990-01-01",
      phone: "2547571273",
      countryID: 0,
      siteCode: 235
    }

    changeset = Customers.change_customer(%Customer{}, customer) |> IO.inspect()
    assert changeset.valid? == false
  end

  test "change_customer/2 returns a false changeset when site code not in a particular country" do
    customer = %{
      name: "Mat",
      dob: "1990-01-01",
      phone: "2547571273",
      countryID: 1,
      siteCode: 811
    }

    changeset = Customers.change_customer(%Customer{}, customer) |> IO.inspect()
    assert changeset.valid? == false
  end

  test "upload_data/1 returns the required format for valid CSV entries" do
    file_path = "priv/static/uploads/Sample.csv"

    expected_data = [
      %{
        CountryID: 1,
        DoB: ~D[1963-08-15],
        Name: "Simon Kamau",
        NationalID: "13424422",
        Phone: "254705611231",
        SiteCode: 235
      },
      %{
        error: [
          "siteCode  657 does not exist in Sierra Leone",
          "phone  number must be in the format 254759635432"
        ],
        line: 2
      },
      %{
        CountryID: 1,
        DoB: ~D[1976-02-08],
        Name: "Barry Collins",
        NationalID: nil,
        Phone: "254757127350",
        SiteCode: 235
      },
      %{error: ["dob is invalid"], line: 4}
    ]

    assert expected_data == Customers.upload_data(file_path)
  end
end
