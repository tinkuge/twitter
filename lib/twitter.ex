defmodule Twitter do
  #@unimap
  use GenServer
  def main(args) do
    IO.inspect(args)



    numuser = Enum.at(args, 0) |> String.to_integer()
    nummsg = Enum.at(args, 1) |> String.to_integer()
    lines = Enum.at(args, 2)

    if(numuser <= 0 || !is_integer(numuser)) do
      IO.puts("Wrong numusers! Please choose a integer value greater than 0.")
      System.halt(1)
    end

    if(nummsg <= 0 || !is_integer(nummsg)) do
      IO.puts("Wrong nummsgs! Please choose a integer value greater than 0.")
      System.halt(1)
    end

    tuplist = []

    tuplist = for i <- 0..numuser - 1 do
      #unique id for each node to be referred to is the index i
      lpid = User.start_link({nummsg, i})
      lmap = {i, lpid}
      IO.puts("User #{i} registerd!")
      [lmap|tuplist]
    end

    tuplist = List.flatten(tuplist)

    #key is integer, value is pid
    unimap = Map.new(tuplist)

    pidlist = Map.values(unimap)
    curpid = self()

    #Update the states of each node

    for i <- pidlist do
      #infinite timeout to aid with debugging
      GenServer.call(i, {unimap, curpid, i}, :infinity)
    end

    #initiate master
    mastup = Master.start_link(unimap)

    mastpid = elem(mastup, 1)

    IO.puts("\nFeed: \n")

    for i <- lines do
      command = Enum.at(i, 0)

      case command do
        "publish" ->
          #Master.publish(mastpid, {:publish, i})
          GenServer.cast(mastpid, {:publish, i})

        "subscribe" ->
          GenServer.cast(mastpid, {:subscribe, i})
      end
    end

    #read_from_console(unimap)

    currid = self()

    IO.puts("All tweets printed")



    :ok

  end

  # def read_from_console() do
  #   :ok
  # end

  # def read_from_console(unimap) do
  #   res = IO.gets("Enter command: \n")

  #   if(res == "halt") do
  #     read_from_console()

  #   else
  #     #IO.puts(res)
  #     #Implement various scenarios
  #     #publish, subscribe
  #     #retweet tweets the last tweet the user received

  #     split_res = String.split(res, " ")

  #     for i <- split_res do

  #     end

  #     #command structure:
  #     # publish, id, tweet
  #     #subscribe, selfid, destid



  #     read_from_console(unimap)
  #   end
  # end

  #maintain a map

  def rcv_tweet_args(args, unimap) do
    #Assuming you receive a list of lists
    #[[publish, .. , ], [subscribe, ....]]
    #less interactive version

    for i <- args do
      command = elem(i, 0)
      case command do
        "publish" ->
          publish(i, unimap)
      end
    end

  end

  @spec publish(Tuple, Map) :: [any]
  def publish(line, unimap) do
    #tup = List.to_tuple(tup)
    pubid = elem(line, 1)
    tweet = elem(line, 2)
    IO.puts(tweet)
    #tw_list is a list of strings
    tw_list = String.split(tweet, " ")

    #optimize this so that it only traverses through the list once
    mentions = Enum.filter(tw_list, fn(x) -> String.starts_with?(x, "@") end)
    hashtags = Enum.filter(tw_list, fn(x) -> String.starts_with?(x, "#") end)


  end
end
