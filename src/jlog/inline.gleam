import gleam/string
import jlog.{type Logger}

/// Emits a log of Debug log level, and returns the input message
pub fn debug(msg, logger: Logger) {
  jlog.debug(logger, msg |> string.inspect)
  msg
}

/// Emits a log of Info log level, and returns the input message
pub fn info(msg, logger: Logger) {
  jlog.info(logger, msg |> string.inspect)
  msg
}

/// Emits a log of Warn log level, and returns the input message
pub fn warn(msg, logger: Logger) {
  jlog.warn(logger, msg |> string.inspect)
  msg
}

/// Emits a log of Fatal log level, and returns the input message
pub fn fatal(msg, logger: Logger) {
  jlog.fatal(logger, msg |> string.inspect)
  msg
}
