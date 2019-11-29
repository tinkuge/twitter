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
    #curpid = self()

    #initiate master
    mastup = Master.start_link(unimap)

    mastpid = elem(mastup, 1)

    #Update the states of each node

    for i <- pidlist do
      #infinite timeout to aid with debugging
      GenServer.call(i, {unimap, mastpid, i}, :infinity)
    end


    begintime = Time.utc_now()

    IO.puts("\nFeed: \n")


    for i <- lines do
      command = Enum.at(i, 0)

      case command do
        "publish" ->
          #Master.publish(mastpid, {:publish, i})
          GenServer.cast(mastpid, {:publish, i})

        "subscribe" ->
          GenServer.cast(mastpid, {:subscribe, i})

        "search" ->
          GenServer.cast(mastpid, {:search, i})

        "retweet" ->
          GenServer.cast(mastpid, {:retweet, i})

        "delete" ->
          GenServer.cast(mastpid, {:delete, i})

        "mention_tweets" ->
          GenServer.cast(mastpid, {:mtweets, i})

        "subtweets" ->
          GenServer.cast(mastpid, {:subtweets, i})
      end
    end

    Process.sleep(500)

    #read_from_console(unimap)

    currid = self()

    IO.puts("All tweets printed")

    endtime = Time.utc_now()

    totaltime = Time.diff(endtime, begintime, :millisecond)

    totaltime = totaltime - 500

    IO.puts("Total time to completion: #{totaltime} ms")



    :ok

  end
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
