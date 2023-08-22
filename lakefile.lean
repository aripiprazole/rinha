import Lake
open Lake DSL

package rinha {
  -- add package configuration options here
}

lean_lib Rinha {
  -- add library configuration options here
}

lean_exe rinha {
  root := `Main
  buildType := .release
  moreLinkArgs := #["-lpq", "-lstdc++"]
}

require lina from git "https://github.com/algebraic-sofia/lina.git"
require soda from git "https://github.com/algebraic-sofia/soda.git"
require melp from git "https://github.com/algebraic-sofia/melp.git"
require ash from git "https://github.com/algebraic-sofia/ash.git"
require pgsql from git "https://github.com/aripiprazole/pgsql.git"
