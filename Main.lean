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
    | some person => conn.created person
    | none        => conn.unprocessableEntity "Invalid JSON"

  get "/pessoas/:id" $ λ conn => do
    match conn.bindings.find? "id" with
    | some query => conn.ok s!"hi {query}" 
    | none       => conn.badRequest "Bad Request"

  get "/pessoas" $ λ conn => do
    match conn.query.find? "t" with
    | some query => conn.ok s!"ok bro {query}" 
    | none       => conn.badRequest "Bad Request"
  
  get "/contagem-pessoas" $ λ conn => do
    match (← Pgsql.exec db "SELECT * FROM h;" #[]) with
    | Except.error _   => conn.badRequest "Oh no!"
    | Except.ok    set => conn.ok s!"{set.size}"

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
    IO.println s!"INFO: Server running on {env.host}{env.port}"
