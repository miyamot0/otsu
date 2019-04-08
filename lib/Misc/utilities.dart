  bool inDebugMode = true;

void printDebug(String msg) {
  if (inDebugMode) {
    print(msg);
  }
}
