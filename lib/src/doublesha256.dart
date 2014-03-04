part of dartminer;

// Finalized array for a 32 byte hash.
List<int> hash32 = [0, 0, 0, 0, 0, 0, 0, 0, 0x80000000, 0, 0, 0, 0, 0, 0, 256];

// Finalized array for a 64 byte hash.
List<int> hash64 = [0x80000000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 512];

class doubleSHA256 extends SHA256 {

  // The midstate.
  Uint32List midstate = null;
  
  // If they provide an initialize, then set the midstate.
  doubleSHA256([Uint32List init = null]) {
    if (init != null) {
      super.update(init);
      midstate = new Uint32List.fromList(state.toList());
    }
  }
  
  /**
   * Perform a double hash.
   */
  void update(List<int> data, [int length = 8]) {
    
    // The data size must be either 64 or 32 bytes long.
    assert((data.length == 16 || data.length == 8));
    
    // Reset with the midstate.
    reset(midstate);
    
    // Update with the data.
    super.update(data);
    
    // If the data is 64 bytes long, then update with the finalized data.
    if (length == 16) {
      super.update(hash64);
    }
    
    // Add the 32 byte state to the 64 byte hash32.
    hash32.setAll(0, state);
    
    // Reset the sha256 hash.
    reset();
    
    // Update with the data from previous hash.
    super.update(hash32);
  }
}