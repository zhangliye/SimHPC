testpath(f) = joinpath(dirname(@__FILE__), f)

for test_file in [
  "simulations.jl"
  ]
  include(testpath(test_file))
end
