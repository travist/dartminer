part of dartminer;

class Work {
  
  // The work data.
  List<int> data;
  List<int> half;
  List<int> hash1;
  List<int> midstate;
  List<int> target;
  
  // The sha256 instance
  SHA256 sha256;
  
  // The nonce value.
  int nonce;
  
  // If the nonce is golden.
  bool golden; 
  
  /**
   * Constructor
   * 
   * @param Map<String, String> work
   *   The JSON representation of a work object.
   */
  Work(Map<String, String> work) {
    sha256 = new SHA256();
    nonce = 0;
    golden = false;
    midstate = hexStringToList(work["midstate"]);
    half = hexStringToList(work["data"].substring(0, 128));
    data = hexStringToList(work["data"].substring(128, 256));
    hash1 = hexStringToList(work["hash1"]);
    target = hexStringToList(work["target"]);
    print(this);
  }
  
  /**
   * Check the nonce value.
   * 
   * @return bool
   *   TRUE if the nonce is golden, FALSE otherwise.
   */
  bool checkNonce() {
    data[3] = nonce;
    sha256.reset(midstate);
    sha256.update(data);
    for (int i = 0; i < 8; i++) {
      hash1[i] = sha256.state[i];
    }
    sha256.reset();
    sha256.update(hash1);
    nonce++;
    return isGolden();
  }
  
  /**
   * Check if the sha256 state is the golden ticket.
   */
  bool isGolden() {
    if (sha256.state[7] == 0) {
      golden = sha256.state[6] <= target[6];
    }
    return golden;
  }
  
  /**
   * Provide the response for the work performed.
   */
  List<int> response() {
    List<int> retVal = [];
    
    // If this is a golden nonce...
    if (golden) {
      
      // Build the response.
      for (int i = 0; i < half.length; i++) {
        retVal.add(half[i]); 
      }
      for (int i = 0; i < data.length; i++) {
        retVal.add(data[i]);
      }
    }
    
    // Return the golden response.
    return retVal;
  }
  
  // Print this work as a string.
  String toString() {
    return {
      "midstate": listToHex(midstate),
      "half": listToHex(half),
      "data": listToHex(data),
      "hash1": listToHex(hash1),
      "target": listToHex(target)
    }.toString();
  }
}