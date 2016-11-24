defmodule Fw.Worker do
  use GenServer

  ## GenServer Implementación
  ####

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    {:ok, pin1} = Gpio.start_link(12, :output)
    {:ok, pin2} = Gpio.start_link(13, :output)
    {:ok, pin3} = Gpio.start_link(14, :output)
    {:ok, pin4} = Gpio.start_link(15, :output)
    Gpio.write(pin1, 1)
    {:ok, %{angulo: 0, pin1: pin1, pin2: pin2, pin3: pin3, pin4: pin4, paso: 1}}
  end

  def handle_call({:incrementar_angulo, delta}, _from,  %{angulo: angulo} = estado) do
    nuevo_paso = incrementar_pasos(estado, delta/3.75)
    nuevo_angulo = conversion_de_angulo(angulo+delta)
    { :reply, nuevo_angulo, %{estado | angulo: nuevo_angulo, paso: nuevo_paso}}
  end

  def handle_call({:disminuir_angulo, delta}, _from, %{angulo: angulo} = estado) do
    nuevo_paso = disminuir_pasos(estado, delta/3.75)
    nuevo_angulo = conversion_de_angulo(angulo-delta)
    { :reply, nuevo_angulo, %{estado | angulo: nuevo_angulo, paso: nuevo_paso}}
  end

  def handle_call(:angulo, _from, %{angulo: angulo} = estado) do
    { :reply, angulo, estado}
  end

  def handle_call({:absoluto, absoluto}, _from, %{angulo: angulo} = estado) do
    {nuevo_paso, nuevo_angulo} = do_absoluto(conversion_de_angulo(absoluto), angulo, estado)
    { :reply, nuevo_angulo, %{estado | angulo: nuevo_angulo, paso: nuevo_paso}}
  end

  ## Helper Functions
  ####

  defp do_absoluto(absoluto, angulo, estado) when absoluto>angulo do
    {incrementar_pasos(estado, (absoluto-angulo)/3.75), absoluto}
  end

  defp do_absoluto(absoluto, angulo, estado) when absoluto<angulo do
    {disminuir_pasos(estado, (angulo-absoluto)/3.75), absoluto}
  end

  defp do_absoluto(_absoluto, angulo, %{paso: paso}) do
    {paso, angulo}
  end

  defp conversion_de_angulo(angulo) when angulo>=360 do
    conversion_de_angulo(angulo-360)
  end

  defp conversion_de_angulo(angulo) when angulo<0 do
    conversion_de_angulo(angulo+360)
  end

  defp conversion_de_angulo(angulo) do
    angulo
  end

  defp incrementar_pasos(%{paso: paso}, 0.0) do
    paso
  end

  defp incrementar_pasos(%{paso: 1, pin2: pin2} = estado, n) do
    Gpio.write(pin2, 1)
    :timer.sleep(20) #Estado 2
    incrementar_pasos(%{estado | paso: 2}, n-1)
  end

  defp incrementar_pasos(%{paso: 2, pin1: pin1} = estado, n) do
    Gpio.write(pin1, 0)
    :timer.sleep(20) #Estado 3
    incrementar_pasos(%{estado | paso: 3}, n-1)
  end

  defp incrementar_pasos(%{paso: 3, pin3: pin3} = estado, n) do
    Gpio.write(pin3, 1)
    :timer.sleep(20) #Estado 4
    incrementar_pasos(%{estado | paso: 4}, n-1)
  end

  defp incrementar_pasos(%{paso: 4, pin2: pin2} = estado, n) do
    Gpio.write(pin2, 0)
    :timer.sleep(20) #Estado 5
    incrementar_pasos(%{estado | paso: 5}, n-1)
  end

  defp incrementar_pasos(%{paso: 5, pin4: pin4} = estado, n) do
    Gpio.write(pin4, 1)
    :timer.sleep(20) #Estado 6
    incrementar_pasos(%{estado | paso: 6}, n-1)
  end

  defp incrementar_pasos(%{paso: 6, pin3: pin3} = estado, n) do
    Gpio.write(pin3, 0)
    :timer.sleep(20) #Estado 7
    incrementar_pasos(%{estado | paso: 7}, n-1)
  end

  defp incrementar_pasos(%{paso: 7, pin1: pin1} = estado, n) do
    Gpio.write(pin1, 1)
    :timer.sleep(20) #Estado 8
    incrementar_pasos(%{estado | paso: 8}, n-1)
  end

  defp incrementar_pasos(%{paso: 8, pin4: pin4} = estado, n) do
    Gpio.write(pin4, 0)
    :timer.sleep(20) #Estado 1
    incrementar_pasos(%{estado | paso: 1}, n-1)
  end

  defp disminuir_pasos(%{paso: paso}, 0.0) do
    paso
  end

  defp disminuir_pasos(%{paso: 8, pin1: pin1} = estado, n) do
    Gpio.write(pin1, 0)
    :timer.sleep(20) #Estado 7
    disminuir_pasos(%{estado | paso: 7}, n-1)
  end

  defp disminuir_pasos(%{paso: 7, pin3: pin3} = estado, n) do
    Gpio.write(pin3, 1)
    :timer.sleep(20) #Estado 6
    disminuir_pasos(%{estado | paso: 6}, n-1)
  end

  defp disminuir_pasos(%{paso: 6, pin4: pin4} = estado, n) do
    Gpio.write(pin4, 0)
    :timer.sleep(20) #Estado 5
    disminuir_pasos(%{estado | paso: 5}, n-1)
  end

  defp disminuir_pasos(%{paso: 5, pin2: pin2} = estado, n) do
    Gpio.write(pin2, 1)
    :timer.sleep(20) #Estado 4
    disminuir_pasos(%{estado | paso: 4}, n-1)
  end

  defp disminuir_pasos(%{paso: 4, pin3: pin3} = estado, n) do
    Gpio.write(pin3, 0)
    :timer.sleep(20) #Estado 3
    disminuir_pasos(%{estado | paso: 3}, n-1)
  end

  defp disminuir_pasos(%{paso: 3, pin1: pin1} = estado, n) do
    Gpio.write(pin1, 1)
    :timer.sleep(20) #Estado 2
    disminuir_pasos(%{estado | paso: 2}, n-1)
  end

  defp disminuir_pasos(%{paso: 2, pin2: pin2} = estado, n) do
    Gpio.write(pin2, 0)
    :timer.sleep(20) #Estado 1
    disminuir_pasos(%{estado | paso: 1}, n-1)
  end

  defp disminuir_pasos(%{paso: 1, pin4: pin4} = estado, n) do
    Gpio.write(pin4, 1)
    :timer.sleep(20) #Estado 8
    disminuir_pasos(%{estado | paso: 8}, n-1)
  end
end
