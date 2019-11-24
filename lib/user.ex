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
    #subscriptions holds the pids of users subscribed to current user tweets
    subcriptions = []
    #sub_tweets hold the tweets from users the current user subscribed to
    sub_tweets = []
    #sub_tweets = []
    mention_tweets = []
    {:ok, {num_msg, unum, subcriptions, sub_tweets, mention_tweets}}
  end

  def handle_call(msg,_, state) do
    unimap = elem(msg, 0)
    parid = elem(msg, 1)
    selfid = elem(msg, 2)


    num_msg = elem(state, 0)
    unid = elem(state, 1)
    subscriptions = elem(state, 2)
    sub_tweets = elem(state, 3)
    mention_tweets = elem(state, 4)

    newstate = {num_msg, unid, subscriptions, sub_tweets, mention_tweets,unimap, parid, selfid}

    {:reply, :ok, newstate}
  end

  def handle_cast({:publish, tweet}, _,
    {num_msg, uid, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do
    tw_list = String.split(tweet, " ")

    #optimize this so that it only traverses through the list once
    mentions = Enum.filter(tw_list, fn(x) -> String.starts_with?(x, "@") end)

    IO.inspect(tweet, label: "#{uid}")

    if length(mentions) > 0 do
      Enum.each(mentions, fn(x) ->
        destpid = Map.get(unimap, x)
        GenServer.cast(destpid, {:mention, tweet})
      end)
    end

    num_msg = num_msg - 1

    {:noreply, {num_msg, uid, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}


  end

  def handle_cast({:mention, tweet}, from,
  {num_msg, uid, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}) do

    IO.inspect("#{from} mentioned #{uid}", label: "#{uid}")
    mention_tweets = [tweet|mention_tweets]

    {:noreply, {num_msg, uid, subcriptions, sub_tweets,mention_tweets, unimap, parid, selfid}}
  end





end
