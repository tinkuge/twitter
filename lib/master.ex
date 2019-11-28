defmodule Master do
  use GenServer

  def start_link(args) do
    {:ok,pid} = GenServer.start_link(__MODULE__, args)
  end

  def init(unimap) do
    tagmap = Map.new()
    tweetfeed = []
    {:ok, {unimap, tagmap, tweetfeed}}
  end


  def handle_cast({:publish, line}, state) do
    srcid = Enum.at(line, 1) |> String.to_integer()
    tweet = Enum.at(line, 2)
    tw_list = String.split(tweet, " ")

    hashtags = Enum.filter(tw_list, fn(x) -> String.starts_with?(x, "#") end)

    #IO.puts("Calling #{srcid}")
    u2pmap = elem(state, 0)
    tagmap = elem(state, 1)
    tweetfeed = elem(state, 2)

    tweetfeed = [tweet|tweetfeed]

    if Map.has_key?(u2pmap, srcid) do
      #get the corresponding pid
      corrid = Map.get(u2pmap, srcid)

      GenServer.cast(corrid, {:publish, tweet})
    else
      IO.puts("User not registered. Enter proper ID")
    end

    #log the tweet to its corresponding hashtag map
    if length(hashtags) > 0 do
      Enum.each(hashtags, fn(x) ->
        #returns an empty list if the map doesn't have the hashtag
        corrlist = Map.get(tagmap, x, [])
        corrlist = [x|corrlist]
        #overwrites the existing value with new value
        #which is a tweet appended to existing list of tweets
        tagmap = Map.put(tagmap, x, corrlist)
      end)
    end

    {:noreply, {u2pmap, tagmap, tweetfeed}}
  end

  def handle_cast({:subscribe, line}, state) do
    u2pmap = elem(state, 0)

    srcid = Enum.at(line, 1) |> String.to_integer()
    subid = Enum.at(line, 2) |> String.to_integer()

    if Map.has_key?(u2pmap, srcid) do
      #get the corresponding pid
      corrid = Map.get(u2pmap, srcid)
      GenServer.cast(corrid, {:add_subscriber, subid})
    else
      IO.puts("User not registered. Enter proper ID")
    end

    {:noreply, state}
  end

  def handle_cast({:search, line}, state) do
    tagmap = elem(state, 1)

    tw_list = String.split(line, " ")
    hashtag = Enum.at(tw_list, 1)
    if Map.has_key?(tagmap, hashtag) do
      hashtweets = Map.get(tagmap, hashtag)
      numtweets = length(hashtweets)
      IO.puts("Number of tweets with #{hashtag}: #{numtweets}")
      for i <- hashtweets do
        IO.puts(i)
      end

    else
      IO.puts("No tweets containing hashtag #{hashtag}")
    end

  end

  def handle_cast({:retweet, line}, state) do

  end


end
