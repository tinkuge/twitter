defmodule User do

  use GenServer

  def start_link(args) do
    {:ok, pid} = GenServer.start_link(__MODULE__, args)
    pid
  end

  def init({num_msg, unum}) do
    #state = {nummsg, uniqueid}
    #tweet_feed = :ets.new(:tweet_feed, [:duplicate_bag, :protected])
    self_tweet_feed = []
    #subscriberids holds the pids of users subscribed to current user tweets
    subscriberids = []
    #subscriptionids holds the user ids the current user is subscribed to
    subscriptionids = []
    #sub_tweets hold the tweets from users the current user subscribed to
    sub_tweets = []
    mention_tweets = []
    {:ok, {num_msg, unum, self_tweet_feed,subscriberids, subscriptionids, sub_tweets, mention_tweets}}
  end

  def handle_call({unimap, parid, selfid},_,{num_msg, unum, self_tweet_feed,subscriberids, subscriptionids, sub_tweets, mention_tweets}) do

    newstate = {num_msg, unum,self_tweet_feed,subscriberids, subscriptionids, sub_tweets, mention_tweets,unimap, parid, selfid}

    {:reply, :ok, newstate}
  end

  def handle_call({:update_state, updmap, delid}, _, {num_msg, uid, self_tweet_feed,subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do
    subscriberids = List.delete(subscriberids, delid)
    subcriptions = List.delete(subcriptions, delid)

    {:reply, :ok, {num_msg, uid, self_tweet_feed,subscriberids, subcriptions, sub_tweets,mention_tweets, updmap, parid, selfid}}
  end

  def handle_cast({:publish, tweet},
    {num_msg, uid, self_tweet_feed,subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do


    if num_msg != 0 do
      tw_list = String.split(tweet, " ")

      #optimize this so that it only traverses through the list once
      mentions = Enum.filter(tw_list, fn(x) -> String.starts_with?(x, "@") end)

      #IO.puts("Inside publish of #{uid}")
      self_tweet_feed = [tweet|self_tweet_feed]
      IO.inspect(tweet, label: "#{uid}")

      #push the tweet to mentions
      if length(mentions) > 0 do
        Enum.each(mentions, fn(x) ->
          #get the id in appropriate format
          splitlist = String.split(x, "@")
          int_uid = Enum.at(splitlist, 1) |> String.to_integer()
          destpid = Map.get(unimap, int_uid)
          GenServer.cast(destpid, {:mention, tweet, uid})
        end)
      end

      #push the tweet to subscribers
      if length(subscriberids) > 0 do

        Enum.each(subscriberids, fn(x) ->
          #get the id in appropriate format
          destpid = Map.get(unimap, x)
          GenServer.cast(destpid, {:sub_tweet, tweet, uid})
        end)
      end

      num_msg = num_msg - 1
      {:noreply, {num_msg, uid, self_tweet_feed,subscriberids,subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}

    else
      IO.inspect("Sorry, the user has reached max number of messages", label: "#{uid}")
      {:noreply, {num_msg, uid, self_tweet_feed,subscriberids,subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
    end

  end

  def handle_cast({:mention, tweet, from},
  {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do

    IO.inspect("#{from} mentioned #{uid}", label: "#{uid}")
    mention_tweets = [tweet|mention_tweets]

    {:noreply, {num_msg, uid, self_tweet_feed,subscriberids,subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
  end

  #Adds an id to the subscriber list
  def handle_cast({:add_subscriber, subid},
  {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}
  ) do
    IO.inspect("Received a subscriber: User #{subid}",label: "#{uid}")
    subscriberids = [subid|subscriberids]
    {:noreply, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
  end

  #Add the userid to which current user is subscribed to
  def handle_cast({:subscription, superid}, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do
    subcriptions = [superid|subcriptions]

    {:noreply, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
  end

  #receive tweet from subcription
  def handle_cast({:sub_tweet, tweet, from},
  {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do

    IO.inspect("Received subcribed tweet from #{from}", label: "#{uid}")
    IO.inspect("Subscribed tweet: #{tweet}", label: "#{uid}")
    sub_tweets = [tweet|sub_tweets]

    {:noreply, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}

  end

  def handle_cast({:last_tweet, reid}, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do

    if length(self_tweet_feed) > 0 do
      last_tweet = List.first(self_tweet_feed)
      if Map.has_key?(unimap, reid) do
        corrpid = Map.get(unimap, reid)
        GenServer.cast(corrpid, {:retweet, uid,last_tweet})

      else
        IO.inspect("The user #{reid} does not exist in the system", label: "Master")
      end

    else
      IO.inspect("The user #{uid} has no tweets of its own", label: "#{uid}")
    end



    {:noreply, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
  end

  def handle_cast({:retweet, srcid, tweet}, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do
    IO.inspect("retweeted #{srcid}: #{tweet}", label: "#{uid}")

    {:noreply, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
  end

  # def handle_cast({:get_feed, feed}, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do
  #   IO.inspect(feed)

  #   {:noreply, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
  # end

  def handle_cast(:get_mention_tweets, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do



    if length(mention_tweets) > 0 do
      IO.puts("Tweets in which #{uid} is mentioned:")
      for i <- mention_tweets do
        IO.puts(i)
      end

    else
      IO.inspect("User #{uid} has no tweets mentioning them", label: "#{uid}")
    end



    {:noreply, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
  end

  def handle_cast(:get_subtweets, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do

    if length(sub_tweets) > 0 do
      IO.puts("Subscribed tweets of #{uid}:")
      for i <- sub_tweets do
        IO.puts(i)
      end

    else
      IO.inspect("User #{uid} has no subscribed tweets", label: "#{uid}")
    end

    {:noreply, {num_msg, uid, self_tweet_feed, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
  end

end
