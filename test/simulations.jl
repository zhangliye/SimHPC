using SimHPC

@resumable function charge(env::Environment, duration::Number)
  @yield timeout(env, duration)  # will continue t later 
end

@resumable function driver(env::Environment, car_process::Process)
  @yield timeout(env, 3)
  @yield interrupt(car_process)
end

@resumable function car(env::Environment, id::Int)
  while true
    println("Car$(id) Start parking at ", now(env))
    parking_duration = convert(Int, round(rand()*10) )
    @yield timeout(env, parking_duration)

    println("Car$(id) start charging at ", now(env))
    charge_duration = convert(Int, round(rand()*10) )
    charge_process = @process charge(sim, charge_duration)   # Process is a event 
    #@yield charge_process  #schedule the behavior here 
    try
      @yield charge_process
    catch
      println("Was interrupted. Hopefully, the battery is full enough ...")
    end

    println("Car$(id) Start driving at ", now(env))
    trip_duration = convert(Int, round(rand()*10) )
    @yield timeout(env, trip_duration)  # drive 2 mins
  end
end

rand(1,10)

sim = Simulation()

for i in 1:100
  @process car(sim, i)   # Process is scheduled here  
end

@time run(sim, 1000)        # start the processes 
println("Finished SimHPC")