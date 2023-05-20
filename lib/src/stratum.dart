part of dartminer;

/**
 * Create the stratum client.
 */
class Stratum extends Bitcoin {
  /**
   * Constructor for the Stratum server.
   */
  Stratum(Map<String, String> config) : super(config, RPCRequest());

  /**
   * Subscribe to a stratum server.
   */
  Future<dynamic> subscribe() => call('mining.subscribe');

  /**
   * Authorize a new miner.
   * 
   * @param String miner
   *   The name of the miner you wish to authorize.
   *   
   * @param String password
   *   The name of the password for the miner.
   */
  Future<dynamic> authorize(String miner, String password) => call('mining.authorize', params: [miner, password]);

  /**
   * Submit the results.
   */
  Future<dynamic> submit() => call('mining.submit');
}
