import Pgsql
import Pgsql.Interface

open Pgsql

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

end Rinha