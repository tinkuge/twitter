defmodule Master do
  use GenServer

  def start_link(args) do
    {:ok,pid} = GenServer.start_link(__MODULE__, args)
  end

  def init(unimap) do
    tagmap = Map.new()
    {:ok, {unimap, tagmap}}
  end

  def handle_cast({:publish, line}, _, state) do
    srcid = elem(line, 1)
    tweet = elem(line, 2)

    tw_list = String.split(tweet, " ")

    hashtags = Enum.filter(tw_list, fn(x) -> String.starts_with?(x, "#") end)


    u2pmap = elem(state, 0)
    tagmap = elem(state, 1)

    if Map.has_key?(u2pmap, srcid) do
      #get the corresponding pid
      corrid = Map.get(u2pmap, srcid)
      GenServer.cast(corrid, tweet)
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

    {:noreply, {u2pmap, tagmap}}
  end
end
