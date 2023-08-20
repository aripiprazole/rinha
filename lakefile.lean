import Lake
open System Lake DSL

package rinha {
  -- add package configuration options here
}

lean_lib Rinha {
  -- add library configuration options here
}

lean_exe rinha {
  root := `Main
}

target ffi.o pkg : FilePath := do
  let oFile := pkg.buildDir / "pgsql" / "ffi.o"
  let srcJob ← inputFile <| pkg.dir / "pgsql" / "ffi.cpp"
  let flags := #["-I", (← getLeanIncludeDir).toString, "-fPIC"]
  buildO "pgsql.cpp" oFile srcJob flags "c++"

extern_lib libleanpgsql pkg := do
  let name := nameToStaticLib "leanffi"
  let ffiO ← fetch <| pkg.target ``ffi.o
  buildStaticLib (pkg.nativeLibDir / name) #[ffiO]
