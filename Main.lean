import Rinha
import Ash

open Ash.App

def app : Ash.App Unit := do
  get "/" $ fun conn => do
    conn.ok "Hello, world"

def main : IO Unit :=
  app.run "0.0.0.0" "8000" do
    IO.println "Server running on port 8000"
