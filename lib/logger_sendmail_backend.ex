defmodule LoggerSendmailBackend do
  use GenEvent

  @aggregate_time 5000 # default
  @msg_limit 20 # default

  def init(__MODULE__) do
    {:ok, configure([])}
  end

  def handle_call({:configure, opts}, _state) do
    {:ok, :ok, configure(opts)}
  end


  def handle_event({level, gl, event}, state) when node(gl) != node() do {:ok, state} end

  def handle_event({level, _gl, {Logger, message, {{y, m, d}, {h, mi, s, _}}, meta}}, state) do
    if meet_level?(level, state.level) do
      message = "
        time: #{d}.#{m}.#{y} #{h}:#{mi}:#{s}, pid: #{inspect meta[:pid]}, level: #{level}
        module: #{inspect meta[:module]}, function: #{inspect meta[:function]}, line: #{inspect meta[:line]}
        message: #{message}
      "
      state = %{state | messages: [message | state.messages]}
    end
    {:ok, state}
  end



  def handle_info({:flush_aggregated, iuid}, %{uid: uid, messages: messages} = state) when iuid == uid and messages != [] do
    install_new_timer(uid)
    count_messages = length(messages)
    prefix = case count_messages > @msg_limit do
      true -> "#{@msg_limit} of total #{count_messages} messages\n"
      false -> "total #{count_messages} messages\n"
    end
    body = prefix <> (messages |> Enum.reverse |> Enum.take(@msg_limit) |> Enum.join(""))
    send_email(body, state)
    {:ok, %{state | messages: []}}
  end

  def handle_info({:flush_aggregated, _iuid}, state) do
    install_new_timer(state.uid)
    {:ok, state}
  end


  # from port. not sure if its needed
  def handle_info({:'EXIT', _port, _reason}, state) do
    {:ok, state}
  end




  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  defp configure(opts) do
    config =
      Application.get_env(:logger, __MODULE__, [])
      |> Keyword.merge(opts)
    Application.put_env(:logger, __MODULE__, config)

    uid = :os.timestamp()
    install_new_timer(uid)

    to = Keyword.get(config, :to)
    if !is_list(to) || to == [] do
      throw "error init #{__MODULE__}. param :to is empty. set it in config!"
    end

    %{level: Keyword.get(config, :level, :error),
      metadata: Keyword.get(config, :metadata, []),
      messages: [],
      sendmail_command: Keyword.get(config, :sendmail_command, "/usr/sbin/sendmail -t"),
      subject: Keyword.get(config, :subject, "errors in exilir application"),
      from: Keyword.get(config, :from, "#{__MODULE__}"),
      to: Keyword.get(config, :to),
      uid: uid,
      aggregate_time: Keyword.get(config, :aggregate_time, @aggregate_time),
      msg_limit: Keyword.get(config, :msg_limit, @msg_limit)}
  end

  defp install_new_timer(uid) do :erlang.send_after(@aggregate_time, self(), {:flush_aggregated, uid}) end



  defp send_email(body, state) do
    letter = Enum.join [
      "To: ", Enum.join(state.to, " "), "\r\n",
      "MIME-Version: 1.0\r\n",
      "Content-type: text/plain; charset=utf-8\r\n",
      "Content-transfer-encoding: binary\r\n",
      "From: ", state.from, "\r\n",
      "Subject: =?utf-8?B?", :base64.encode(state.subject), "?=\r\n",
      "\r\n",
      body,
      "\r\n.\r\n"
    ]
    port = :erlang.open_port({:spawn, state.sendmail_command}, [:binary])
    :erlang.send(port, {self(), {:command, letter}})
    :erlang.port_close(port)
  end
end
