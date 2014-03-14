part of dartminer;

abstract class BCRequest {
  void request(Completer completer, Uri uri, String data);
}