part of dartwebminer;

class WebRequest implements BCRequest {
  /**
   * Make a request.
   */
  void request(Uri uri, String data) {
    // Create a new request.
    HttpRequest request = new HttpRequest();

    // Handle the ready state change.
    request.onReadyStateChange.listen((_) {
      if ((request.readyState == HttpRequest.DONE) && (request.status == 200 || request.status == 0)) {
        // Parse the response.
        dynamic result = jsonDecode(request.responseText!);

        // If the result is set, then complete the future.
        if (result["result"] != null) {
          return result["result"];
        } else if (result['error'] != null) {
          return result['error'];
        }
      }
    });

    // Open the request and send the data.
    request.open("POST", uri.toString(), async: false);
    request.send(data);
  }
}
