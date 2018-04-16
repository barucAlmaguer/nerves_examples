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
    spawn(fn -> blink_list_forever(led_list) end)
    spawn(fn -> logger("loggeando, conteo", 150) end)
    spawn(fn -> logger("loggeando, conteo", 300) end)
    {:ok, self()}
  end

  # call blink_led on each led in the list sequence, repeating forever
  defp blink_list_forever(led_list) do
    Enum.each(led_list, &blink(&1))
    blink_list_forever(led_list)
  end

  defp logger(msg, count) do
    IO.puts("#{msg} = #{count}")
    :timer.sleep(650)
    case count do
      200 ->
        IO.puts("Done logging ERRORRR")
        IO.puts({})
      0 ->
        IO.puts("Done logging... byebye")
      _ ->
        logger(msg, count - 1)
    end
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
