namespace Rinha.Environment

structure PostgreSQLEnvironment where
  host : String
  port : String
  user : String
  password : String
  database : String

/--
Converts to a connection string for the postgresql database.
-/
def PostgreSQLEnvironment.toConnectionString (self : PostgreSQLEnvironment) : String :=
  s!"postgres://{self.user}:{self.password}@{self.host}:{self.port}/{self.database}"

structure Environment where
  host : String
  port : String
  gateway_host : String
  gateway_port : String
  postgres : PostgreSQLEnvironment

def readPostgreSQLEnvironment : IO PostgreSQLEnvironment := do
  let host := Option.getD (← IO.getEnv "POSTGRES_HOST") "localhost"
  let port := Option.getD (← IO.getEnv "POSTGRES_PORT") "5432"
  let user := Option.getD (← IO.getEnv "POSTGRES_USER") "postgres"
  let password := Option.getD (← IO.getEnv "POSTGRES_PASSWORD") "12345"
  let database := Option.getD (← IO.getEnv "POSTGRES_DATABASE") "postgres"
  return {host, port, user, password, database}

/--
Reads the environment variables and returns the environment
data type for easier access.
-/
def readEnvironment : IO Environment := do
  let port := Option.getD (← IO.getEnv "PORT") "8000"
  let host := Option.getD (← IO.getEnv "HOST") "0.0.0.0"
  let gateway_port := Option.getD (← IO.getEnv "GATEWAY_PORT") "8000"
  let gateway_host := Option.getD (← IO.getEnv "GATEWAY_HOST") "0.0.0.0"
  let postgres ← readPostgreSQLEnvironment
  return {host, port, postgres, gateway_host, gateway_port}

end Rinha.Environment