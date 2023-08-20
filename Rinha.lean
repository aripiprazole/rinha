def hello := "world"

namespace Rinha
/--
The *basic* type of a person. It contains it's name and other info
about the person.
-/
structure Person where
  username : String
  name : Name
  age : Nat
  birthdate : String
  stack : Option (List Stack) := none

instance : ToString Person where
  toString p :=
    "Person {username: " ++ p.username ++
      ", name: " ++ p.name ++
      ", age: " ++ toString p.age ++
      ", birthdate: " ++ (toString p.birthdate)

/--
The username of a person. It contains the username of the person and it can
be only 32 characters long.

It have to be unique.
-/
structure Username where
  data : String
  not_empty : (data.length > 0) = True
  less_than : (data.length <= 32) = True

/--
The name of a person. It contains the name of the person and it can
be only 100 characters long.
-/
structure Name where
  data : String
  not_empty : (data.length > 0) = True
  less_than : (data.length <= 100) = True

/--
The stack of a person. It contains the name of the stack and it can
be only 32 characters long.
-/
structure Stack where
  data : String
  not_empty : (data.length > 0) = True
  less_than : (data.length <= 32) = True

end Rinha