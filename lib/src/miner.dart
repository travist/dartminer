part of dartminer;

class Miner {
  
  // The work for the miner.
  Work work;
  
  /**
   * Constructor.
   * 
   * @param Map work
   *   The JSON map of the work.
   */
  Miner(Map<String, String> work) {
    this.work = new Work(work);
  }
  
  /**
   * Mine for the nonce.
   */
  List<int> mine([done]) {
    
    // Perform a hash check every 1M cycles.
    int hashCheck = 1000000;
    
    // Record the last time.
    int lastTime = (new DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    
    // Check the nonce value.
    while(!work.checkNonce()) {
      
      // Print an update...
      if ((work.nonce % hashCheck) == 0) {
        int thisTime = (new DateTime.now()).millisecondsSinceEpoch ~/ 1000;
        int hashRate = hashCheck ~/ (thisTime - lastTime);
        print('HashRate: ' + hashRate.toString() + ' H/s  Nonce: ' + work.nonce.toString());
        lastTime = thisTime;
      }
    }
    
    // Return the work response.
    return work.response();
  }
}