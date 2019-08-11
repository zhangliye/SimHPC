using Documenter
using ResumableFunctions
using SimHPC

makedocs(
  format   = :html,
  sitename = "SimHPC",
  authors = "Zhang Liye",
  pages    = [
    "Home" => "index.md"
  ]
)

deploydocs(
  repo = "github.com/zhangliye/SimHPC.jl.git",
  julia  = "1.0",
  osname = "linux",
  target = "build",
  deps = nothing,
  make = nothing,
)
