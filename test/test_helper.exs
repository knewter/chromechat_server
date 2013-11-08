Dynamo.under_test(ChromechatServer.Dynamo)

ExUnit.start

defmodule ChromechatServer.TestCase do
  use ExUnit.CaseTemplate

  # Enable code reloading on test cases
  setup do
    Dynamo.Loader.enable
    :ok
  end
end
