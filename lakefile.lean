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
}

require lina from git "git@github.com:algebraic-sofia/lina.git"
require soda from git "git@github.com:algebraic-sofia/soda.git"
require melp from git "git@github.com:algebraic-sofia/melp.git"
require pgsql from git "git@github.com:aripiprazole/pgsql.git"
