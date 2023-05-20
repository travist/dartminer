part of dartminer;

class Work {
  // The work data.
  late Uint32List data;
  late Uint32List half;
  late Uint32List target;

  // The sha256 instance
  late DoubleSHA256 sha256;

  // The nonce value.
  int nonce;

  // If the nonce is golden.
  late bool golden;

  // The expiration of this work.
  int expires;

  // The created date.
  late int created;

  /**
   * Create a new work object from the json object of 'getwork'
   * 
   * @param Map<String, String> work
   *   The JSON representation of a work object.
   */
  Work.fromJSON(Map<String, String> work, {int this.expires = 120, int this.nonce = 0}) {
    sha256 = new DoubleSHA256();
    golden = false;
    created = now();
    sha256.midstate = hexToList(work["midstate"]!);
    half = hexToList(work["data"]!.substring(0, 128));
    data = hexToList(work["data"]!.substring(128, 256));
    target = hexToReversedList(work["target"]!);
  }

  /**
   * Create work from a single data string.
   */
  Work.fromData(String hexData, {int this.expires = 120, int this.nonce = 0}) {
    golden = false;
    created = now();
    half = hexToList(hexData.substring(0, 128));
    data = hexToList(hexData.substring(128, 256));
    sha256 = new DoubleSHA256(half);
    target = Block.bitsToTarget(hexData.substring(144, 152));
  }

  /**
   * Create a new work object from the header block.
   * 
   * @param Uint32List header
   *   The little-endian Uint32List header.
   *   
   * @param int startNonce
   *   The nonce to start with.
   */
  Work.fromHeader(Uint32List header, Uint32List this.target, {int this.expires = 120, int this.nonce = 0}) {
    golden = false;
    created = now();

    // Get the first half of the header.
    half = header.sublist(0, 16);

    // Initialize the sha256.
    sha256 = new DoubleSHA256(half);

    // Set the data list.
    data = new Uint32List(16);
    data.setAll(0, header.sublist(16));

    // Finalize the data for hashing.
    data[4] = 0x80000000;
    data[15] = 640;
  }

  /**
   * Check the nonce value.
   * 
   * @return bool
   *   TRUE if the nonce is golden, FALSE otherwise.
   */
  bool checkNonce() {
    data[3] = nonce;
    sha256.update(data);
    return isGolden();
  }

  /**
   * Return if there is more work to be done.
   * 
   * @return bool
   *   If there is more work to be done.
   */
  bool hasWork() {
    return (nonce < 0xffffffff);
  }

  /**
   * Make sure our mining has not expired.
   * 
   * @param int timestamp
   *   The timestamp to check the expiration on.
   */
  bool expired([int timestamp = 0]) {
    // If there isn't a timestamp, then create one.
    if (timestamp == 0) {
      timestamp = now();
    }

    // If no expiration, then always return true.
    if (expires == 0) {
      return false;
    }

    // Return if we still have time to mine.
    return (timestamp - created) > expires;
  }

  /**
   * Check if the sha256 state is the golden ticket.
   */
  bool isGolden() {
    if (sha256.state[7] == 0) {
      int j = 6;
      for (int i = 1; j >= 0; i++, j--) {
        int a = reverseBytesInWord(sha256.state[j]);
        int b = target[i];
        if (a == b) {
          continue;
        }

        // Return if the state is less than the target.
        golden = (a < b);
        return golden;
      }
    }

    golden = false;
    return golden;
  }

  /**
   * Provide the response for the work performed.
   */
  Map<String, String>? response([bool reverseWords = true]) {
    // Check if this is the golden hash.
    if (golden) {
      // Get the result data.
      Uint32List resultData = new Uint32List(32);
      resultData.setAll(0, half);
      resultData.setAll(16, data);

      // Return the result.
      return {'nonce': reverseBytesInWord(nonce).toString(), 'hash': listToReversedHex(sha256.state), 'data': listToHex(resultData, reverseWords)};
    }

    // Return null if no golden ticket.
    return null;
  }

  // Print this work as a string.
  String toString() {
    return {"half": listToHex(half), "data": listToHex(data), "target": listToHex(target)}.toString();
  }
}
