defmodule CustomerCsvUploadWeb.PageController do
  use CustomerCsvUploadWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
