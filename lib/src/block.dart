part of dartminer;

class Block {
  
  // The block version. 
  int version;
  
  // The previous block hash.
  String previousblockhash;
  
  // The merkle root of the transactions.
  String merkleroot;  
  
  // The current time.
  int time;
  
  // The bits value.
  String bits;
  
  // The target array.
  Uint32List target;
  
  // The nonce for this block.
  int nonce;
  
  // The expiration.
  int expires;
  
  // The list of transactions in this block.
  List<String> tx;
  
  Block.fromJSON(dynamic block) {
    
    // The version of the block.
    version = block['version'];
    
    // The previous block hash.
    previousblockhash = block['previousblockhash'];
    
    // The current time.
    time = block['time'];
    
    // The bits.
    bits = getBits(block['bits']);
    
    // The nonce for this block.
    nonce = block['nonce'];
    
    // Get the target from the bits.
    target = bitsToTarget(bits);
    
    // Set the list of transactions.
    tx = block['tx'];
    
    // No expiration.
    expires = 0;
    
    // Get the merkle root if not provided for us.
    merkleroot = (block['merkleroot'] != null) ? block['merkleroot'] : merkleRoot();
  }
  
  /**
   * Create a new block from a block template.
   */
  Block.fromTemplate(dynamic template) {
    
    // The version of the block.
    version = template['version'];
    
    // The previous block hash.
    previousblockhash = template['previousblockhash'];
    
    // The current time.
    time = template['curtime'];
    
    // The bits. 
    bits = getBits(template['bits']);
    
    // Get the target from the bits.
    target = bitsToTarget(bits);
    
    // The nonce for this block.
    nonce = template['nonce'];
    
    // Set the expiration.
    expires = template['expires'];
    
    // Get the list of transactions.
    tx = [];
    template['transactions'].forEach((Map<String, String> transaction) {
      tx.add(transaction['hash']);
    });
    
    // Get the merkleroot.
    merkleroot = reverseBytes(merkleRoot()); 
  }
  
  /**
   * Create a block header from data.
   */
  Block.fromData(String data) {
    
    // No expiration.
    expires = 0;
    
    // Get the version.
    int offset = 0;
    int length = 8;
    version = int.parse(data.substring(offset, offset + length), radix: 16);
    
    // Set the previous block hash.
    offset += length;
    length = 64;
    previousblockhash = data.substring(offset, offset + length);
    previousblockhash = listToHex(hexToReversedList(previousblockhash));
    
    // Set the merkle root.
    offset += length;
    length = 64;
    merkleroot = data.substring(offset, offset + length);
    merkleroot = listToHex(hexToReversedList(merkleroot));
    
    // Set the time
    offset += length;
    length = 8;
    time = int.parse(data.substring(offset, offset + length), radix: 16);
    
    // Set the bits
    offset += length;
    length = 8;
    bits = getBits(data.substring(offset, offset + length));
    target = bitsToTarget(bits);
    
    // Set the bits
    offset += length;
    length = 8;
    nonce = int.parse(data.substring(offset, offset + length), radix: 16);
  }
  
  /**
   * The bits have a tendency to be the wrong endian within the template.
   * Use this as a way to try and get the correct bits.
   *
   * @param String bits
   *   The bits to get.
   *
   * @param String
   *   The bits in the correct endianness.
   */
  String getBits(String bits) {
    int bitsLength = int.parse(bits.substring(0, 2), radix: 16);
    if (bitsLength > 32) {
      return reverseBytes(bits);
    }
    return bits;
  }

  /**
   * Convert the bits string to a target.
   */
  static Uint32List bitsToTarget(String bits) {
    int bitsLength = int.parse(bits.substring(0, 2), radix: 16);
    int numBits = ((bits.length ~/ 2) - 1);
    int offset = 32 - bitsLength;
    
    // Create the target.
    Uint8List target = new Uint8List(32);
    int bitpos = 2;
    while ((bitpos + 2) <= bits.length) {
      target[offset++] = int.parse(bits.substring(bitpos, (bitpos + 2)), radix: 16);
      bitpos += 2;
    }
    
    // Get the little endian version of the target.
    Uint32List target32 = new Uint32List.view(target.buffer);
    for (int i = 0; i < target32.length; i++) {
      target32[i] = reverseBytesInWord(target32[i]); 
    }
    
    // Return the target.
    return target32;
  }
  
  /**
   * Convert this block to work.
   */
  Work toWork() {
    
    // Return the work from header.
    return new Work.fromHeader(
      getHeader(), 
      target, 
      nonce: reverseBytesInWord(nonce),
      expires: expires
    );
  }
  
  /**
   * Form a block header from this block.
   */
  Uint32List getHeader([bool reverseBits = true]) {
    Uint32List header = new Uint32List(32);
    header[0] = reverseBytesInWord(version);
    header.setAll(1, hexToReversedList(previousblockhash));
    header.setAll(9, hexToReversedList(merkleroot));
    header[17] = reverseBytesInWord(time);
    header[18] = reverseBits ? reverseBytesInWord(int.parse(bits, radix: 16)) : int.parse(bits, radix: 16);
    header[19] = reverseBytesInWord(nonce);
    header[20] = 0x80000000;
    return header;
  }
    
  /**
   * Compute the merkle root provided a list of transactions.
   */
  String merkleRoot() {
    
    // Get the init hashes.
    List<Uint32List> intHashes = [];
    
    // Convert each hash into a reversed list of ints.
    for (int i = 0; i < tx.length; i++) {
      intHashes.add(hexToReversedList(tx[i]));
    }
    
    // The hash.
    Uint32List hash = new Uint32List(16);
    
    // Create a new double sha256 object.
    doubleSHA256 sha256 = new doubleSHA256();
    
    // Iteratively compute the merkle root hash
    while (intHashes.length > 1) {
      
      // Duplicate last hash if the list is odd
      if ((intHashes.length % 2) != 0) {
        intHashes.add(intHashes[(intHashes.length - 1)]);
      }
      
      List<Uint32List> newHashes = [];
      int pairLength = (intHashes.length ~/ 2);
      for (int j = 0; j < pairLength; j++) {
        hash.setAll(0, intHashes.removeAt(0));
        hash.setAll(8, intHashes.removeAt(0));
        sha256.update(hash, 16);
        newHashes.add(new Uint32List.fromList(sha256.state.toList()));
      }
      
      intHashes = newHashes;
    }
    
    // Return the reverse string.
    return listToReversedHex(intHashes[0]);
  }
}