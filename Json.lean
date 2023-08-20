/--
**The base JSON** data type which contains all the JSON values. It can be
constructed using the following constructors:

- `Json.array` constructs a JSON array from a list of JSON values.
- `Json.number` constructs a JSON number from an integer.
- `Json.string` constructs a JSON string from a string.
- `Json.object` constructs a JSON object from a list of key-value pairs.
-/
inductive Json : Type where
  | array  : List Json → Json
  | number : Int → Json
  | string : String → Json
  | object : List (String × Json) → Json
  deriving Inhabited

namespace Json

end Json
