import gleam/erlang/process
import gleam/otp/actor

type Message(a) {
  Push(a)
  GetAll(reply_with: process.Subject(List(a)))
  Clear
  Stop
}

fn handle_message(
  message: Message(a),
  mem: List(a),
) -> actor.Next(Message(a), List(a)) {
  case message {
    Push(value) -> actor.continue([value, ..mem])
    GetAll(client) -> {
      process.send(client, mem)
      actor.continue(mem)
    }
    Clear -> actor.continue([])
    Stop -> actor.Stop(process.Normal)
  }
}

pub type Collector {
  Collector(
    push: fn(String) -> Nil,
    get: fn() -> List(String),
    clear: fn() -> Nil,
  )
}

pub fn new(cb: fn(Collector) -> a) -> a {
  let assert Ok(collector) = actor.start([], handle_message)
  let ret =
    cb(
      Collector(
        push: fn(str) { process.send(collector, Push(str)) },
        get: fn() { process.call(collector, GetAll, 100) },
        clear: fn() { process.send(collector, Clear) },
      ),
    )
  process.send(collector, Stop)
  ret
}
