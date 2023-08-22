import Pgsql
import Pgsql.Interface
import Ash.JSON

open Pgsql
open Ash

def getNat? (json : JSON) (key : String) : Option Nat := do
  match json with
  | Ash.JSON.obj s => 
    let filter := s.filterMap $ λ x => match x with
    | (k, Ash.JSON.num s) => if k = key then some s else none
    | (_, _) => none
    filter.head?
  | _ => none

def getArray? (json : JSON) (key : String) : Option (List JSON) := do
  match json with
  | Ash.JSON.obj s => 
    let filter := s.filterMap $ λ x => match x with
    | (k, Ash.JSON.arr s) => if k = key then some s else none
    | (_, _) => none
    filter.head?
  | _ => none

def getString? (json : JSON) (key : String) : Option String := do
  match json with
  | Ash.JSON.obj s => 
    let filter := s.filterMap $ λ x => match x with
    | (k, Ash.JSON.str s) => if k = key then some s else none
    | (_, _) => none
    filter.head?
  | _ => none

namespace Rinha

/--
The username of a person. It contains the username of the person and it can
be only 32 characters long.

It have to be unique.
-/
structure Username where
  data : String
  -- not_empty : (data.length > 0) = True
  -- less_than : (data.length <= 32) = True

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

instance : Ash.ToJSON Stack where
  toJSON stack :=  Ash.JSON.str stack.data

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

instance : Ash.ToJSON Person where
  toJSON person := 
    let stack := Ash.ToJSON.toJSON (person.stack.getD [])
    Ash.ToJSON.toJSON
      [ "username" +: person.username.data
      , "name"     +: person.name.data
      , "age"      +: person.age
      , "birthday" +: person.birthdate
      , "stack"    +: stack
      ]

instance : ToString Person where
  toString p :=
    "Person {username: " ++ p.username.data ++
      ", name: " ++ p.name.data ++
      ", age: " ++ toString p.age ++
      ", birthdate: " ++ (toString p.birthdate)

def String.toStack? (s : String) : Option Stack :=
  if s.length > 32 then none else some {data := s}


/--
Parses a list of stacks from a string. The string must be in the format
`stack1,stack2,stack3,...,stackN`.
-/
def String.parseStack (stack : String) : List Stack :=
  List.filterMap String.toStack? (stack.splitOn ",") 

/--
Transforms a `Pgsql.ResultSet` into a `Person` if it's possible.

It's possible to fail if the `ResultSet` doesn't have the correct
columns. The columns that are needed are:
- username
- name
- age
- birthdate
- stack
-/
def ResultSet.toPerson? (rs : Pgsql.ResultSet) : Option Person := do
  let username  ← rs.getText "username" >>= String.toUsername?
  let name      ← rs.getText "name" >>= String.toName?
  let age       ← rs.getText "age" >>= String.toNat?
  let birthdate ← rs.getText "birthdate"
  let stack     ← Option.map String.parseStack $ rs.getText "stack"
  return {username := username, name := name, age := age, birthdate := birthdate, stack := stack}

def personFromJson? (json : JSON) : Option Person := do
  let username  ← getString? json "username" >>= String.toUsername?
  let name      ← getString? json "name" >>= String.toName?
  let age       ← getNat? json "age"
  let birthdate ← getString? json "birthdate"
  let stack     ← getArray? json "stack" >>= λ x => some $ x.filterMap $ λ x => match x with
  | Ash.JSON.str s => String.toStack? s
  | _ => none
  return {username := username, name := name, age := age, birthdate := birthdate, stack := stack}

/--
Inserts a person into the database. It returns the id of the person
-/
def Person.create! (person : Person) (conn : Connection) : IO (Option Person) := do
  let stack := person.stack.getD []
  let stack := stack.foldl (λ acc x => acc ++ "," ++ x.data) ""

  -- Make the query
  let result ← exec conn "INSERT INTO person (username, name, age, birthdate, stack) VALUES ($1, $2, $3, $4, $5)" #[
    person.username.data,
    person.name.data,
    toString person.age,
    person.birthdate,
    stack
  ]

  match result with
  | Except.error _ => return none
  | Except.ok _ => return some person

end Rinha