import Rinha
import Ash

open Ash.App
open Ash
open Rinha

def app : Ash.App Unit := do
  get "/" $ λ conn => do
    conn.ok "Hello, world"
  
  post "/pessoas" $ λ conn => do
    let str := conn.melp.data.body
    let person := Ash.JSON.parse str >>= personFromJson?
    match person with
    | some person => do
      conn.created $ ToJSON.toJSON person
    | none => do
      conn.unprocessableEntity "Invalid JSON"


def main : IO Unit :=
  app.run "0.0.0.0" "8000" do
    IO.println "Server running on port 8000"
