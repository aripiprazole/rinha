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
  username : Username
  name : Name
  age : Nat
  birthdate : String
  stack : Option (List Stack)
  deriving Repr

instance : Ash.ToJSON Person where
  toJSON person := 
     `{ "username" +: person.username.data
      , "name"     +: person.name.data
      , "age"      +: person.age
      , "birthday" +: person.birthdate
      , "stack"    +: person.stack.getD []
      }

instance : FromJSON Person where
  fromJSON json := do
    let username  ← json.find? "username" >>= String.toUsername?
    let name      ← json.find? "name"     >>= String.toName?
    let age       ← json.find? "age"
    let birthdate ← json.find? "birthdate"
    let stack     ← json.find? "stack"
    return {username, name, age, birthdate, stack }

instance : FromResult Person where
  fromResult rs := do
    let username  ← rs.get "username" >>= String.toUsername?
    let name      ← rs.get "name"     >>= String.toName?
    let age       ← rs.get "age"
    let birthdate ← rs.get "birthdate"
    let stack     ← Option.map String.parseStack $ rs.get "stack"
    return {username, name, age, birthdate, stack}

/--
Inserts a person into the database. It returns the id of the person
-/
def create (person : Person) (conn : Connection) : IO (Option Person) := do
  let stack := person.stack.getD []
  let stack := stack.foldl (λ acc x => acc ++ "," ++ x.data) ""

  -- Make the query
  let query := "INSERT INTO person (username, name, age, birthdate, stack) VALUES ($1, $2, $3, $4, $5);" 

  let result ← exec conn query
    #[ person.username.data
    ,  person.name.data
    ,  toString person.age
    ,  person.birthdate
    ,  stack
    ]

  match result with
  | Except.error _ => return none
  | Except.ok _ => return some person

end Rinha.Entities