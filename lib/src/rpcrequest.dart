part of dartrpcminer;

/**
 * The RPCRequest.
 */
class RPCRequest implements BCRequest {
  
  HttpClient client;
  
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
  void request(Completer completer, Uri uri, String message) {
    
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
  }
}