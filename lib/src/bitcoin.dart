part of dartminer;

/**
 * The Bitcoin daemon interface class.
 */
class Bitcoin {
  // The bitcoin request object.
  BCRequest request;

  // The id for the connection.
  late String id;

  // The URI for the bitcoind.
  late Uri uri;

  /**
   * Create the Bitcoin client.
   */
  Bitcoin(Map<String, dynamic> config, BCRequest this.request) {
    // Create the id.
    id = (new DateTime.now()).millisecondsSinceEpoch.toString();

    // Create a new uri from the configuration.
    uri = new Uri(scheme: config["scheme"], host: config["host"], port: config["port"], userInfo: (config["user"] + ':' + config["pass"]));
  }

  // The bitcoind api's.
  Future<dynamic> getinfo({params = const []}) => call('getinfo', params: params);
  Future<dynamic> getwork({params = const []}) => call('getwork', params: params);
  Future<dynamic> getblockhash({params = const []}) => call('getblockhash', params: params);
  Future<dynamic> getblock({params = const []}) => call('getblock', params: params);
  Future<dynamic> getblocktemplate() => call("getblocktemplate", params: [
        {
          'rules': ['segwit']
        }
      ]);
  Future<dynamic> submitblock({params = const []}) => call('submitblock', params: params);

  /**
   * Make a json-rpc call to our bitcoin daemon.
   */
  Future<dynamic> call(String method, {params = const []}) async {
    // Make the request.
    final result = request.request(uri, jsonEncode({'jsonrpc': '1.0', "id": id, "method": method, "params": params}));

    // Return the future.
    return result;
  }
}
