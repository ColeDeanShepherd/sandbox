import Lake
open Lake DSL

package pong {
  -- add package configuration options here
}

@[default_target]
lean_exe pong {
  root := `Main
}
