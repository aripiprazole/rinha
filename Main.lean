import Rinha
import Ash

open Ash.App
open Ash
open Rinha

open Rinha.Entities
open Rinha.Environment

/--
Rinha de backend basic application monad
-/
def app (db: Pgsql.Connection) : Ash.App Unit := do
  post "/pessoas" $ λ conn => do
    let person : Option Person := conn.json
    match person with
    | none        => conn.unprocessableEntity "Invalid JSON"
    | some person =>
      let res ← person.create! db
      match res with
      | some person => do
          let location := s!"/pessoas/{person.id}"
          conn.created person location
      | none        => conn.unprocessableEntity "Already exists."

  get "/pessoas/:id" $ λ conn => do
    match conn.bindings.find? "id" with
    | none       => conn.badRequest "Bad Request"
    | some query => 
      match (← findById query db) with
      | some person => conn.ok person
      | none        => conn.notFound "" 

  get "/pessoas" $ λ conn => do
    match conn.query.find? "t" with
    | none       => conn.badRequest "Bad Request"
    | some query => conn.ok (← findLike query db)
  
  get "/contagem-pessoas" $ λ conn => do
    let count ← countPeople db
    conn.ok s!"{count}"

/--
Rinha de backend entrypoint
-/
def main : IO Unit := do
  -- Read the environment from environment variables,
  -- but if they are not set, use the default values.
  let env <- readEnvironment

  -- Connects to the database using the environment variables.
  let conn ← Pgsql.connect $ env.postgres.toConnectionString
  let app := app conn
  IO.println s!"INFO: Database connection set up"

  -- Run the application with the environment variables host and port.
  app.run env.host env.port do
    IO.println s!"INFO: Server running on {env.host}:{env.port}"
