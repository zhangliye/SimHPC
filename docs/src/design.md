
# Event
abstract type AbstractEvent end

struct Event <: AbstractEvent
  bev :: BaseEvent
  function Event(env::Environment)    
    new(BaseEvent(env))
  end
end
mutable struct BaseEvent    # used to track with EventKey.id
  env :: Environment        #event must be in an environment
  id :: UInt
  callbacks :: Vector{Function}   #will run when the event is invoked
  state :: EVENT_STATE
  value :: Any              # contain data
  function BaseEvent(env::Environment)
    new(env, env.eid+=one(UInt), Vector{Function}(), idle, nothing)
  end
end

Every event is tracked using EventKey in Env,
struct EventKey
  time :: Float64
  priority :: Int
  id :: UInt
end

## set callback and value
function my_callback(ev::AbstractEvent)
  println("Called back from ", ev)
end
ev = Event(sim)
SimJulia.Event 1
@callback my_callback(ev)   # set the call back function, 


# Process                   
Process is a time of Event

abstract type AbstractProcess <: AbstractEvent end
abstract type DiscreteProcess <: AbstractProcess end

mutable struct Process <: DiscreteProcess
  bev :: BaseEvent
  fsmi :: ResumableFunctions.FiniteStateMachineIterator
  target :: AbstractEvent
  resume :: Function
  function Process(func::Function, env::Environment, args::Any...)
    proc = new()
    proc.bev = BaseEvent(env)
    proc.fsmi = func(env, args...)
    proc.target = schedule(Initialize(env))
    proc.resume = @callback execute(proc.target, proc)
    proc
  end
end

# Everonment 
abstract type Environment end

mutable struct Simulation <: Environment
  time :: Float64   #current time 
  heap :: DataStructures.PriorityQueue{BaseEvent, EventKey}
  eid :: UInt
  sid :: UInt
  active_proc :: Union{AbstractProcess, Nothing}
  function Simulation(initial_time::Number=zero(Float64))
    new(initial_time, DataStructures.PriorityQueue{BaseEvent, EventKey}(), zero(UInt), zero(UInt), nothing)
  end
end

## How event runs

function schedule(ev::AbstractEvent, delay::Number=zero(Float64); priority::Int=0, value::Any=nothing)
  state(ev) == processed && throw(EventProcessed(ev))
  env = environment(ev)
  bev = ev.bev
  bev.value = value
  env.heap[bev] = EventKey(now(env) + delay, priority, env.sid+=one(UInt))
  bev.state = scheduled
  ev
end


## Behivior of Agent
The behavior of the Agent is modeled by Processes are described by @resumable functions.

@resumable function agent_move()
    create they create events and @yield them in order to wait for them to be triggered.
end

When a process yields an event, the process gets suspended. SimJulia resumes the process, when the event occurs (we say that the event is triggered). 
Multiple processes can wait for the same event. SimJulia resumes them in the same order in which they yielded that event.

An important event type is the timeout. Events of this type are scheduled after a certain amount of (simulated) time has passed. They allow a process to sleep (or hold its state) for the given time.A timeout and all other events can be created by calling a constructor having the environment as first argument.

Example:
@resumable function car(env::Environment)
    while true
        println("Start parking at ", now(env))
        parking_duration = 5
        @yield timeout(env, parking_duration)     #wait for 5 mins here 
        println("Start driving at ", now(env))
        trip_duration = 2
        @yield timeout(env, trip_duration)    #run 2 mins
    end
end

## 