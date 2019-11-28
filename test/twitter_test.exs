defmodule TwitterTest do
  use ExUnit.Case
  doctest Twitter

  test "greets the world" do
    #tweet may contain mentions and hashtags

    lines = [["publish", "1", "I am 1"],
    ["publish", "2", "Hello"],
    ["publish", "3", "I am 3"]]
    #retweets latest tweet from another user
    #{"retweet", "originalid", "currid"}}
    args = []
    assert Twitter.main(["10", "10", lines]) == :ok
  end
end
