defmodule TwitterTest do
  use ExUnit.Case
  doctest Twitter

  test "greets the world" do
    #tweet may contain mentions and hashtags

    lines = [["publish", "1", "I am 1 @2 #covfefe"],
    ["publish", "2", "Hello #covfefe #hamberder @1"],
    ["search", "#covfefe"],
    ["search", "#hamberder"],
    ["publish", "3", "I am 3"],
    ["subscribe", "2", "1"],
    ["publish", "2", "I am a #hamberder"],
    ["delete", "1"],
    ["subscribe", "0", "2"],
    ["publish", "0", "Hello world"],
    ["retweet", "2", "3"],
    ["mention_tweets", "2"],
    ["subtweets", "2"],
    ["publish", "4", "I am Brad Pitt"],
    ["publish", "5", "No, I am Brad pitt @4 #imposter"],
    ["publish", "6", "One of you @4 @5 is the #imposter"],
    ["publish", "7", "Who is the #imposter #covfefe"],
    ["publish", "8", "I am the #imposter"],
    ["publish", "9", "The plot thickens"],
    ["search", "#imposter"],
    ["mention_tweets", "4"],
    ["mention_tweets", "5"],
    ["publish", "2", "Another tweet from 2"]
    ]
    #retweets latest tweet from another user
    #{"retweet", "originalid", "currid"}}
    args = []
    assert Twitter.main(["10", "2", lines]) == :ok
  end
end
