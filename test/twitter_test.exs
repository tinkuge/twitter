defmodule TwitterTest do
  use ExUnit.Case
  doctest Twitter

  test "greets the world" do
    #tweet may contain mentions and hashtags

    lines = {{"publish", "uid", "tweet"},
    {"subscribe", "parid", "destid"},
    #retweets latest tweet from another user
    {"retweet", "originalid", "currid"}}
    args = []
    usepidmap = Twitter.main(args)
    # assert Twitter.
    assert Twitter.hello() == :world
  end
end
