final class RequestSequence {
  int _latest = 0;

  int next() => ++_latest;

  bool isCurrent(int token) => token == _latest;
}
