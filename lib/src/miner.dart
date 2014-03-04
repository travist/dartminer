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
  Miner.fromJSON(Map<String, String> work, [int startNonce = 0]) {
    this.work = new Work.fromJSON(work, startNonce);
  }
  
  /**
   * Create a new miner from the header.
   * 
   * @param Uint32List header
   *   The little-endian Uint32List header.
   *   
   * @param Uint32List target
   *   The target.
   *   
   * @param int startNonce
   *   The nonce to start with.
   */
  Miner.fromHeader(Uint32List header, Uint32List target, [int startNonce = 0]) {
    this.work = new Work.fromHeader(header, target, startNonce);
  }
  
  /**
   * Create a new miner from work.
   */
  Miner.fromWork(Work this.work);
  
  /**
   * Mine for the nonce.
   */
  Map<String, String> mine([done]) {
    
    // Perform a hash check every 1M cycles.
    int hashCheck = 1000000;
    
    // Record the last time.
    int lastTime = (new DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    
    // Iterate while there is more work to be done.
    while(work.hasWork() && !work.checkNonce()) {
        
      // Iterate the work nonce.
      work.nonce++;
      
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