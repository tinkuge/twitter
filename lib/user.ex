defmodule User do

  use GenServer

  def start_link(args) do
    {:ok, pid} = GenServer.start_link(__MODULE__, args)
    pid
  end

  def init({num_msg, unum}) do
    #state = {nummsg, uniqueid}
    #tweet_feed = :ets.new(:tweet_feed, [:duplicate_bag, :protected])
    #tweet_feed = []
    #subscriberids holds the pids of users subscribed to current user tweets
    subscriberids = []
    #subscriptionids holds the user ids the current user is subscribed to
    subscriptionids = []
    #sub_tweets hold the tweets from users the current user subscribed to
    sub_tweets = []
    mention_tweets = []
    {:ok, {num_msg, unum,subscriberids, subscriptionids, sub_tweets, mention_tweets}}
  end

  def handle_call(msg,_,{num_msg, unum,subscriberids, subscriptionids, sub_tweets, mention_tweets}) do
    unimap = elem(msg, 0)
    parid = elem(msg, 1)
    selfid = elem(msg, 2)

    newstate = {num_msg, unum, subscriberids, subscriptionids, sub_tweets, mention_tweets,unimap, parid, selfid}

    {:reply, :ok, newstate}
  end

  def handle_cast({:publish, tweet},
    {num_msg, uid, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do
    tw_list = String.split(tweet, " ")

    #optimize this so that it only traverses through the list once
    mentions = Enum.filter(tw_list, fn(x) -> String.starts_with?(x, "@") end)

    IO.inspect(tweet, label: "#{uid}")

    #push the tweet to mentions
    if length(mentions) > 0 do
      Enum.each(mentions, fn(x) ->
        destpid = Map.get(unimap, x)
        GenServer.cast(destpid, {:mention, tweet, uid})
      end)
    end

    #push the tweet to subscribers
    if length(subscriberids) > 0 do

      Enum.each(subscriberids, fn(x) ->
        destpid = Map.get(unimap, x)
        GenServer.cast(destpid, {:sub_tweet, tweet, uid})
      end)
    end

    num_msg = num_msg - 1

    {:noreply, {num_msg, uid, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}


  end

  def handle_cast({:mention, tweet, from},
  {num_msg, uid, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do

    IO.inspect("#{from} mentioned #{uid}", label: "#{uid}")
    mention_tweets = [tweet|mention_tweets]

    {:noreply, {num_msg, uid, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
  end

  #Adds an id to the subscriber list
  def handle_cast({:add_subscriber, subid},
  {num_msg, uid, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}
  ) do
    subscriberids = [subid|subscriberids]
    {:noreply, {num_msg, uid, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
  end

  #receive tweet from subcription
  def handle_cast({:sub_tweet, tweet, from},
  {num_msg, uid, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do

    IO.inspect("Received subcribed tweet from #{from}", label: "#{uid}")
    sub_tweets = [tweet|sub_tweets]

    {:noreply, {num_msg, uid, subscriberids, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}

  end


end
