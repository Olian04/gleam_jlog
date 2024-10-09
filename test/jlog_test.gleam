import gleam/dict
import gleam/dynamic
import gleam/json
import gleam/list
import gleeunit
import gleeunit/should
import jlog
import jlog/inline
import jlog/log_level
import log_collector

pub fn main() {
  gleeunit.main()
}

pub fn log_structure_test() {
  use collector <- log_collector.new()

  jlog.new()
  |> jlog.set_transport(collector.push)
  |> jlog.info("Hello, world!")

  let obj =
    collector.get()
    |> list.first
    |> should.be_ok
    |> json.decode(dynamic.dict(dynamic.string, dynamic.dynamic))
    |> should.be_ok

  obj
  |> dict.keys
  |> should.equal(["level", "message", "timestamp", "v"])

  obj
  |> dict.get("v")
  |> should.be_ok
  |> dynamic.int
  |> should.be_ok
  |> should.equal(0)

  obj
  |> dict.get("level")
  |> should.be_ok
  |> dynamic.string
  |> should.be_ok
  |> should.equal("Info")

  obj
  |> dict.get("message")
  |> should.be_ok
  |> dynamic.string
  |> should.be_ok
  |> should.equal("Hello, world!")
}

pub fn set_transport_test() {
  use collector <- log_collector.new()

  let logger =
    jlog.new()
    |> jlog.set_transport(collector.push)

  collector.get()
  |> list.length
  |> should.equal(0)

  jlog.info(logger, "Hello, world!")

  collector.get()
  |> list.length
  |> should.equal(1)
}

pub fn set_log_level_test() {
  use collector <- log_collector.new()

  let logger =
    jlog.new()
    |> jlog.set_transport(collector.push)

  logger
  |> jlog.set_log_level(log_level.Debug)
  |> jlog.debug("Hello, world!")
  |> jlog.info("Hello, world!")
  |> jlog.warn("Hello, world!")
  |> jlog.fatal("Hello, world!")

  collector.get()
  |> list.length
  |> should.equal(4)

  collector.clear()

  logger
  |> jlog.set_log_level(log_level.Info)
  |> jlog.debug("Hello, world!")
  |> jlog.info("Hello, world!")
  |> jlog.warn("Hello, world!")
  |> jlog.fatal("Hello, world!")

  collector.get()
  |> list.length
  |> should.equal(3)

  collector.clear()

  logger
  |> jlog.set_log_level(log_level.Warn)
  |> jlog.debug("Hello, world!")
  |> jlog.info("Hello, world!")
  |> jlog.warn("Hello, world!")
  |> jlog.fatal("Hello, world!")

  collector.get()
  |> list.length
  |> should.equal(2)

  collector.clear()

  logger
  |> jlog.set_log_level(log_level.Fatal)
  |> jlog.debug("Hello, world!")
  |> jlog.info("Hello, world!")
  |> jlog.warn("Hello, world!")
  |> jlog.fatal("Hello, world!")

  collector.get()
  |> list.length
  |> should.equal(1)

  collector.clear()

  logger
  |> jlog.set_log_level(log_level.Silent)
  |> jlog.debug("Hello, world!")
  |> jlog.info("Hello, world!")
  |> jlog.warn("Hello, world!")
  |> jlog.fatal("Hello, world!")

  collector.get()
  |> list.length
  |> should.equal(0)
}

pub fn inline_test() {
  use collector <- log_collector.new()

  let logger =
    jlog.new()
    |> jlog.set_transport(collector.push)
    |> jlog.set_log_level(log_level.Debug)

  collector.get()
  |> list.length
  |> should.equal(0)

  "Hello, world!"
  |> inline.debug(logger)
  |> inline.info(logger)
  |> inline.warn(logger)
  |> inline.fatal(logger)
  |> should.equal("Hello, world!")

  collector.get()
  |> list.length
  |> should.equal(4)

  collector.get()
  |> list.first
  |> should.be_ok
  |> json.decode(dynamic.dict(dynamic.string, dynamic.dynamic))
  |> should.be_ok
  |> dict.get("message")
  |> should.be_ok
  |> dynamic.string
  |> should.be_ok
  |> should.equal("\"Hello, world!\"")
}
