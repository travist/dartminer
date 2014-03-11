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
  Miner.fromJSON(Map<String, String> work, {int expires: 120, int nonce: 0}) {
    this.work = new Work.fromJSON(work, nonce: nonce, expires: expires);
  }
  
  /**
   * Create a new miner from the header.
   * 
   * @param Uint32List header
   *   The little-endian Uint32List header.
   *   
   * @param int startNonce
   *   The nonce to start with.
   */
  Miner.fromHeader(Uint32List header, Uint32List target, {int expires: 120, int nonce: 0}) {
    this.work = new Work.fromHeader(header, target, nonce: nonce, expires: expires);
  }
  
  /**
   * Create a new miner from work.
   */
  Miner.fromWork(Work this.work);
  
  /**
   * Mine for the nonce.
   */
  Map<String, String> mine([bool reverseWords = true]) {
    
    // Perform a hash check every 1M cycles.
    int hashCheck = 1000000;
    
    // Record the last time.
    int lastTime = now();
    
    // Iterate while there is more work to be done.
    while(work.hasWork() && !work.checkNonce()) {
        
      // Iterate the work nonce.
      work.nonce++;
      
      // Print an update...
      if ((work.nonce % hashCheck) == 0) {
        
        // Get the current time.
        int thisTime = now();
        
        // Make sure our mining has not expired.
        if (work.expired(thisTime)) {
          print('Mining expired.');
          break;
        }
        
        // Determine the hash rate and print.
        int hashRate = hashCheck ~/ (thisTime - lastTime);
        print('HashRate: ' + hashRate.toString() + ' H/s  Nonce: 0x' + work.nonce.toRadixString(16));
        lastTime = thisTime;
      }
    }
    
    // Return the work response.
    return work.response(reverseWords);
  }
}