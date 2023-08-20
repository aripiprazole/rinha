import Lake
open Lake DSL

package rinha {
  -- add package configuration options here
}

lean_lib Rinha {
  -- add library configuration options here
}

@[defaultTarget]
lean_exe rinha {
  root := `Main
}
