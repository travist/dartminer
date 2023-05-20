part of dartrpcminer;

/**
 * The RPCRequest.
 */
class RPCRequest implements BCRequest {
  late HttpClient client;

  /**
   * Initialize.
   */
  RPCRequest() {
    // Create the client.
    client = new HttpClient();
  }

  /**
   * Make a request.
   */
  Future<dynamic> request(Uri uri, String message) async {
    final client = Dio();

    Map<String, String> headers = {
      'User-Agent': 'miner/1.0',
      'Authorization': 'Basic ' + base64Encode(utf8.encode(uri.authority.split('@')[0])),
    };

    try {
      final httpResponse = await client.post(uri.origin, data: message, options: Options(headers: headers));
      if (httpResponse.statusCode != 200) {
        return 'HTTP code is ${httpResponse.statusCode}';
      }
      return httpResponse.data;
    } catch (e) {
      return 'CURL error: $e';
    } finally {
      client.close();
    }
  }
}
