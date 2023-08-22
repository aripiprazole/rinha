import Pgsql
import Pgsql.Interface
import Ash.JSON

open Pgsql
open Ash

namespace Rinha.Entities

/--
The username of a person. It contains the username of the person and it can
be only 32 characters long.

It have to be unique.
-/
structure Username where
  data : String
  -- not_empty : (data.length > 0) = True
  -- less_than : (data.length <= 32) = True
  deriving Repr
  
def String.toUsername? (s : String) : Option Username :=
  if s.length > 32 then none else some {data := s}

/--
The name of a person. It contains the name of the person and it can
be only 100 characters long.
-/
structure Name where
  data : String
  -- not_empty : (data.length > 0) = True
  -- less_than : (data.length <= 100) = True
  deriving Repr

def String.toName? (s : String) : Option Name :=
  if s.length > 100 then none else some {data := s}

/--
The stack of a person. It contains the name of the stack and it can
be only 32 characters long.
-/
structure Stack where
  data : String
  -- not_empty : (data.length > 0) = True
  -- less_than : (data.length <= 32) = True
  deriving Repr

def String.toStack? (s : String) : Option Stack :=
  if s.length > 32 then none else some {data := s}

/--
Parses a list of stacks from a string. The string must be in the format
`stack1,stack2,stack3,...,stackN`.
-/

def String.parseStack (stack : String) : List Stack :=
  List.filterMap String.toStack? (stack.splitOn ",") 

instance : Ash.FromJSON Stack where
  fromJSON stack := Stack.mk <$> (FromJSON.fromJSON stack)

instance : Ash.ToJSON Stack where
  toJSON stack := Ash.JSON.str stack.data


/--
The *basic* type of a person. It contains it's name and other info
about the person.
-/
structure Person where
  id: String
  username : Username
  name : Name
  birthdate : String
  stack : Option (List Stack)
  deriving Repr

instance : Ash.ToJSON Person where
  toJSON person := 
     `{ "id"         +: person.id
      , "apelido"    +: person.username.data
      , "nome"       +: person.name.data
      , "nascimento" +: person.birthdate
      , "stack"      +: person.stack.getD []
      }

instance : FromJSON Person where
  fromJSON json := do
    let username  ← json.find? "apelido" >>= String.toUsername?
    let name      ← json.find? "nome"    >>= String.toName?
    let birthdate ← json.find? "nascimento"
    let stack     ← json.find? "stack"
    return {id := "", username, name, birthdate, stack }

--//////////////////////////////////////////////////////////////////////////////
--//// SECTION: Queries Repository /////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////

instance : FromResult Person where
  fromResult rs := do
    let id        ← rs.get "id"
    let username  ← rs.get "username"  >>= String.toUsername?
    let name      ← rs.get "name"      >>= String.toName?
    let birthdate ← rs.get "birth_date"
    let stack     ← Option.map String.parseStack $ rs.get "stack"
    return {id, username, name, birthdate, stack}

/-- Finds a list person by it's stack -/
def findLike (queryStr : String) (conn : Connection) : IO (List Person) := do
  let query := "SELECT * FROM users WHERE stack LIKE $1 OR username LIKE $1 OR name LIKE $1 LIMIT 50;"
  let result ← exec conn query #[s!"%{queryStr}%"]
  match result with
  | Except.error _ => return []
  | Except.ok rs => return rs.toList.filterMap FromResult.fromResult

/-- Finds a person by it's id -/
def findById (id : String) (conn : Connection) : IO (Option Person) := do
  let query := "SELECT * FROM users WHERE id = $1;"
  let result ← exec conn query #[id]
  match result with
  | Except.error _ => return none
  | Except.ok rs => return rs.get? 0 >>= FromResult.fromResult

/-- Count all people -/
def countPeople (conn : Connection) : IO Nat := do
  let result ← exec conn "SELECT COUNT(column_name) FROM users;" #[]
  match result with
  | Except.error _ => return 0
  | Except.ok rs => 
    match rs.get? 0 with
    | some res => return (res.get "count").get!
    | none     => return 0

/-- Inserts a person into the database. It returns the id of the person -/
def Person.create! (person : Person) (conn : Connection) : IO (Option Person) := do
  let stack := person.stack.getD []
  let stack := String.intercalate "," (Stack.data <$> stack) 

  -- Make the query
  let query := "INSERT INTO users (username, name, birth_date, stack) VALUES ($1, $2, $3, $4) RETURNING id, username, name, birth_date, stack;" 

  let result ← exec conn query
    #[ person.username.data
    ,  person.name.data
    ,  person.birthdate
    ,  stack
    ]

  match result with
  | Except.error _ => return none
  | Except.ok rs   => return rs.get? 0 >>= FromResult.fromResult

end Rinha.Entities