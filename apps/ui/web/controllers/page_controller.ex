defmodule Ui.PageController do
  use Ui.Web, :controller

  def index(conn, _params) do
    angulo = angulo_pap
    render conn, "index.html", angulo: angulo
  end

  def post_relativo(conn, %{"angulo" => %{"delta" => angulo}}) do
    {delta, _} = Float.parse(angulo)
    abs_delta = abs(delta)
    float = delta/3.75
    case gira_o_error(float, round(float)) do
      true ->
        angulo = diferencial_de_angulo(delta, abs_delta)
        conn
        |> put_flash(:success, "El motor paso a paso debe rotar")
        |> render("index.html", angulo: angulo)
      false ->
        angulo = angulo_pap
        conn
        |> put_flash(:error, "El angulo debe ser multiplo de 3.75")
        |> render("index.html", angulo: angulo)
    end
  end

  def post_absoluto(conn, %{"angulo" => %{"absoluto" => angulo}}) do
    {absoluto, _} = Float.parse(angulo)
    float = absoluto/3.75
    case gira_o_error(float, round(float)) do
      true ->
        angulo = angulo_absoluto(absoluto)
        conn
        |> put_flash(:success, "El motor paso a paso debe rotar")
        |> render("index.html", angulo: angulo)
      false ->
        angulo = angulo_pap
        conn
        |> put_flash(:error, "El angulo debe ser multiplo de 3.75")
        |> render("index.html", angulo: angulo)
    end
  end

  defp gira_o_error(float, integer) when float==integer do
    true
  end

  defp gira_o_error(_float, _integer) do
    false
  end

  def diferencial_de_angulo(delta, abs_deltan) when delta == abs_deltan do
    GenServer.call Fw.Worker, {:incrementar_angulo, delta}
  end

  def diferencial_de_angulo(_delta, abs_deltan) do
    GenServer.call Fw.Worker, {:disminuir_angulo, abs_deltan}
  end

  def angulo_pap() do
    GenServer.call Fw.Worker, :angulo
  end

  def angulo_absoluto(absoluto) do
    GenServer.call Fw.Worker, {:absoluto, absoluto}
  end
end
