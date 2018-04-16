defmodule Blinky do
  @moduledoc """
  Simple example to blink a list of LEDs forever.

  The list of LEDs is platform-dependent, and defined in the config directory
  (see config.exs). See README.md for build instructions.
  """

  # Durations are in milliseconds
  @on_duration 100
  @off_duration 100

  alias Nerves.Leds
  require Logger

  def start(_type, _args) do
    led_list = Application.get_env(:blinky, :led_list)
    Logger.debug("list of leds to blink is #{inspect(led_list)}")
    IO.puts("starting in 5 seconds...")
    :timer.sleep(1000)
    IO.puts("4...")
    :timer.sleep(1000)
    IO.puts("3...")
    :timer.sleep(1000)
    IO.puts("2...")
    :timer.sleep(1000)
    IO.puts("1...")
    :timer.sleep(1000)
    IO.puts("spawneando!")
    pid1 = spawn(fn -> blink_list_forever(led_list) end)
    pid2 = spawn(fn -> logger("loggeando, conteo", 150) end)
    pid3 = spawn(fn -> logger("loggeando, conteo", 300) end)
    IO.puts("registering slaves...")
    send(pid3, {self(), "hola desde el main"})
    listener({pid1, pid2, pid3})
    #{:ok, self()}
  end

  defp listener(pids) do
    IO.puts("listening...")
    receive do
      _ -> IO.puts("Listener received something!")
    end
    :timer.sleep(1250)
    listener(pids)
  end

  # call blink_led on each led in the list sequence, repeating forever
  defp blink_list_forever(led_list) do
    Enum.each(led_list, &blink(&1))
    blink_list_forever(led_list)
  end

  def logger(msg, count) do
    parent =
      receive do
        {from, msg} ->
          IO.puts("Logger received: #{msg} from #{inspect(from)}")
          from
        after
          1_000 -> :error
      end
    case parent do
      :error -> IO.puts("Error registrando parent")
      _ -> IO.puts("Parent registrado correctamente")
    end
    logger(msg, count, parent)
  end

  def logger(msg, count, parent) when parent != :error do
    case count do
      225 ->
        send(parent, {:logger, "ya mero llegamos?"})
        logger(msg, count - 1, parent)
      200 ->
        IO.puts("Done logging ERRORRR")
        IO.puts({})
      0 ->
        IO.puts("Done logging... byebye")
      _ ->
        IO.puts("#{msg} = #{count}")
        :timer.sleep(500)
        logger(msg, count - 1, parent)
    end
  end

  def logger(_, _, :error) do
    IO.puts("Timeout al registrar Parent")
  end

  # given an led key, turn it on for @on_duration then back off
  defp blink(led_key) do
    # Logger.debug "blinking led #{inspect led_key}"
    Leds.set([{led_key, true}])
    :timer.sleep(@on_duration)
    Leds.set([{led_key, false}])
    :timer.sleep(@off_duration)
  end
end
