try
  cd(ENV["PWD"])
catch
  println("Could not load PWD")
end
try
  using OhMyREPL
catch
  import Pkg; Pkg.add("OhMyREPL")
  using OhMyREPL
end
OhMyREPL.enable_autocomplete_brackets(false)
try
  using Revise
catch
  import Pkg; Pkg.add("Revise")
  using Revise
end
