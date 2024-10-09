import birl
import gleam/float
import gleam/int
import gleam/io
import gleam/string
import gleam/string_builder
import jlog/log_level.{type LogLevel, Debug, Fatal, Info, Silent, Warn}

fn should_log(
  logger logger_level: LogLevel,
  function function_level: LogLevel,
) -> Bool {
  case logger_level, function_level {
    Silent, _ -> False
    _, Silent -> False
    _, _ -> {
      { function_level |> log_level.to_int }
      >= { logger_level |> log_level.to_int }
    }
  }
}

fn with_attribute(logger: Logger, key: String, value: String) -> Logger {
  logger.prefix
  |> string_builder.append(", \"" <> key <> "\": " <> value <> "")
  |> fn(prefix) { Logger(..logger, prefix:) }
}

pub opaque type Logger {
  Logger(
    prefix: string_builder.StringBuilder,
    log_level: LogLevel,
    transport: fn(String) -> Nil,
  )
}

/// Creates and returns a new logger with a log level of Info and transport function of io.println
pub fn new() {
  Logger("{ \"v\": 0" |> string_builder.from_string, Info, io.println)
}

/// Returns a logger with its transport function set to the provided transport function
pub fn set_transport(logger: Logger, transport: fn(String) -> Nil) {
  Logger(..logger, transport:)
}

/// Returns a logger with its log level set to the provided log level
pub fn set_log_level(logger: Logger, log_level: LogLevel) -> Logger {
  Logger(..logger, log_level:)
}

/// Returns a logger a string attribute added to each log produced by it
pub fn with_string(logger: Logger, key: String, value: String) -> Logger {
  logger
  |> with_attribute(key, "\"" <> value <> "\"")
}

/// Returns a logger an int attribute added to each log produced by it
pub fn with_int(logger: Logger, key: String, value: Int) -> Logger {
  logger
  |> with_attribute(key, value |> int.to_string)
}

/// Returns a logger a float attribute added to each log produced by it
pub fn with_float(logger: Logger, key: String, value: Float) -> Logger {
  logger
  |> with_attribute(key, value |> float.to_string)
}

/// Returns a logger a bool attribute added to each log produced by it
pub fn with_bool(logger: Logger, key: String, value: Bool) -> Logger {
  logger
  |> with_attribute(key, {
    case value {
      True -> "true"
      False -> "false"
    }
  })
}

fn do_log(logger: Logger, msg: String) {
  logger
  |> with_string("level", logger.log_level |> log_level.to_string)
  |> with_string("timestamp", birl.now() |> birl.to_iso8601)
  |> with_string("message", msg |> string.replace(each: "\"", with: "\\\""))
  |> fn(logger) { logger.prefix }
  |> string_builder.append(" }")
  |> string_builder.to_string
  |> logger.transport
}

/// Emits a log of Debug log level, and returns the input message
pub fn debug(logger: Logger, msg: String) -> Logger {
  case should_log(logger.log_level, Debug) {
    False -> logger
    True -> {
      do_log(logger, msg)
      logger
    }
  }
}

/// Emits a log of Info log level
pub fn info(logger: Logger, msg: String) -> Logger {
  case should_log(logger.log_level, Info) {
    False -> logger
    True -> {
      do_log(logger, msg)
      logger
    }
  }
}

/// Emits a log of Warn log level
pub fn warn(logger: Logger, msg: String) -> Logger {
  case should_log(logger.log_level, Warn) {
    False -> logger
    True -> {
      do_log(logger, msg)
      logger
    }
  }
}

/// Emits a log of Fatal log level
pub fn fatal(logger: Logger, msg: String) -> Logger {
  case should_log(logger.log_level, Fatal) {
    False -> logger
    True -> {
      do_log(logger, msg)
      logger
    }
  }
}
