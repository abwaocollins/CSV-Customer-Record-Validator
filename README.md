# CustomerCsvUpload

This application allows users to upload CSV files, validate the data, and generate a JSON response indicating successful records and any errors encountered during the validation process.

## Technologies Used

- Phoenix Framework version 1.6.12
- Elixir version 1.12
- External Dependency: NimbleCSV version 1.1

## Assumptions

1. Telephone numbers in the csv file are from Nigeria, Kenya and Sierra leone.
2. If multiple errors occur on a single line, they are returned as a list of errors.
3. The application returns JSON data after the validation process.

## Getting Started

To start the Phoenix server, follow these steps:

1. Install dependencies by running `mix deps.get`.
2. Create and migrate the database with `mix ecto.setup`.
3. Start the Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Uploading and Processing Files

1. Open the application in your browser after starting the server.
2. On the loaded page, you can drag and drop a CSV file or use the file input to choose a file for upload. Download Sample.csv for testing.
3. Click the "Upload" button to initiate the processing of the uploaded file.
4. If the processing completes successfully without any errors, you will be able to download the JSON response.
   - The JSON response contains a list of records with their corresponding fields and any encountered errors.
   - The errors are associated with the line numbers in the CSV file.
  
## JSON Response Example

The following is an example of the JSON response returned after processing the uploaded CSV file:

```json
[
    {
        "CountryID": 1,
        "DoB": "1963-08-15",
        "Name": "Simon Kamau",
        "NationalID": "13424422",
        "Phone": "254705611231",
        "SiteCode": 235
    },
    {
        "error": ["siteCode 657 does not exist in Sierra Leone"],
        "line": 2
    },
    {
        "CountryID": 1,
        "DoB": "1976-02-08",
        "Name": "Barry Collins",
        "NationalID": null,
        "Phone": "254757127350",
        "SiteCode": 235
    },
    {
        "error": ["dob is invalid"],
        "line": 4
    }
]

```
## Screenshots
![right file format](/priv/static/correct.png)

![right file format](/priv/static/wrong.png)

## Application Workflow and Structure

- The application is built using Phoenix LiveView, which provides a real-time interactive user interface.
- The `Customers` context handles the logic for file upload, parsing, and validation.
- The `Customer` schemaless changeset is used for data validation and error handling.

## Running Tests

To ensure the reliability and correctness of the code, tests are available. You can run the tests using the following command:

mix test test/customer_csv_upload/customers_test.exs


Executing this command will run the test suite specifically designed for the `Customers` module. Running tests is essential for validating the functionality and behavior of the code.

Feel free to explore and run the tests to gain confidence in the reliability of the application. If you encounter any unexpected behavior or errors during the testing process, please don't hesitate to reach out for assistance.

## Additional Resources

- Official Phoenix Framework website: [https://www.phoenixframework.org/](https://www.phoenixframework.org/)
- Phoenix Framework Guides: [https://hexdocs.pm/phoenix/overview.html](https://hexdocs.pm/phoenix/overview.html)
- Phoenix Framework Documentation: [https://hexdocs.pm/phoenix](https://hexdocs.pm/phoenix)
- Phoenix Framework Forum: [https://elixirforum.com/c/phoenix-forum](https://elixirforum.com/c/phoenix-forum)
- Source Code: [https://github.com/phoenixframework/phoenix](https://github.com/phoenixframework/phoenix)

---



