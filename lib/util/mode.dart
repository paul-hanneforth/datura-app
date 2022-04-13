enum Mode {
  development,
  production
}

extension ModeAsString on Mode {
  String get displayName {
    if(this == Mode.development) return "DEV";
    if(this == Mode.production) return "PROD";

    return "PROD";
  }
}