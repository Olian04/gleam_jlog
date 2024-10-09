pub type LogLevel {
  Debug
  Info
  Warn
  Fatal
  Silent
}

pub fn to_int(level: LogLevel) {
  case level {
    Debug -> 1
    Info -> 2
    Warn -> 3
    Fatal -> 4
    Silent -> 5
  }
}

pub fn to_string(level: LogLevel) {
  case level {
    Debug -> "Debug"
    Info -> "Info"
    Warn -> "Warn"
    Fatal -> "Fatal"
    Silent -> "Silent"
  }
}
