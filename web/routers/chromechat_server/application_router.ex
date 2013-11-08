defmodule ChromechatServer.ApplicationRouter do
  use Dynamo.Router

  prepare do
    # Pick which parts of the request you want to fetch
    # You can comment the line below if you don't need
    # any of them or move them to a forwarded router
    conn = conn.fetch([:cookies, :params])
    conn = conn.assign(:title, "Welcome to Dwitter!")
  end

  get "/" do
    conn.resp_body("foo")
  end
end
