part of dartminer;

class Bitcoin {
  
  HttpClient client;
  String id;
  Uri uri;
  
  /**
   * Create the Bitcoin client.
   */
  Bitcoin(Map<String, String> config) {
    
    // Create the id.
    id = (new DateTime.now()).millisecondsSinceEpoch.toString();
    
    // Create the client.
    client = new HttpClient();
    
    // Create a new uri from the configuration.
    uri = new Uri(
      scheme: config["scheme"],
      host: config["host"],
      port: config["port"],
      userInfo: (config["user"] + ':' + config["pass"])
    );
  }
  
  // The bitcoind api's.
  Future<dynamic> getinfo({params: const[]}) => call('getinfo', params: params);
  Future<dynamic> getwork({params: const[]}) => call('getwork', params: params);
  Future<dynamic> getblockhash({params: const[]}) => call('getblockhash', params: params);
  Future<dynamic> getblock({params: const []}) => call('getblock', params: params);
  Future<dynamic> getblocktemplate({params: const []}) => call("getblocktemplate", params: params);
  
  /**
   * Make a json-rpc call to our bitcoin daemon.
   */
  Future<dynamic> call(String method, {params: const []}) {
    // Create a new completer.
    final Completer completer = new Completer();
    
    // Set the message.
    String message = JSON.encode({
      'jsonrpc': '1.0',
      "id": id,
      "method": method,
      "params": params
    });
    
    // Make sure we are connected.
    client.postUrl(uri).then((HttpClientRequest req) {
      
      // Set the request headers and send the message.
      req.headers.add(HttpHeaders.CONTENT_TYPE, 'application/json');
      req.contentLength = message.length;
      req.write(message);
      return req.close();
    }).then((HttpClientResponse res) {
      
      // Listen to the response.
      res.listen((data) {
        
        // Parse the response.
        dynamic result = JSON.decode(UTF.codepointsToString(data));
        
        // If the result is set, then complete the future.
        if (result["result"] != null) {
          completer.complete(result["result"]);
        } else if (result['error'] != null) {
          completer.completeError(result['error']);
        }
      }, onError: (e) {
        completer.completeError(e);
      });
    });
    
    // Return the future.
    return completer.future;
  }
}