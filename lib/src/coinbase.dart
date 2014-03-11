part of dartminer;

class Coinbase {
  
  String data;
  
  /**
   * Create a new coinbase provided the scriptsig, value, and address.
   * 
   * @param String script
   *   The coinbase scriptsig value.  Provided from coinbaseaux parameter.
   *   
   * @param int value
   *   The value of the coinbase in Satoshi's
   *   
   * @param String address
   *   The base58 Bitcoin address to send the value.
   */
  Coinbase(String script, int value, String address) {
    
    // Create a new string buffer.
    StringBuffer buffer = new StringBuffer();
    String pubKey = addressToPubKey(address);
    
    // txn version
    buffer.write('01000000');
    
    // txn in-counter
    buffer.write('01');
    
    // input[0] prev hash
    buffer.write('0000000000000000000000000000000000000000000000000000000000000000');
    
    // input[0] prev seqnum
    buffer.write('ffffffff');
    
    // input[0] script length;
    buffer.write(int2VarIntHex(script.length ~/ 2));
    
    // input[0] script
    buffer.write(script);
    
    // input[0] seqnum
    buffer.write('ffffffff');
    
    // out-counter
    buffer.write('01');
    
    // output[0] value (little endian)
    buffer.write(word2LEHex(value));
    
    // output[0] script length
    buffer.write(int2VarIntHex(pubKey.length ~/ 2));
    
    // output[0] script.
    buffer.write(pubKey);
    
    // lock-time
    buffer.write('00000000');
    
    // Assign the data to the buffer string.
    data = buffer.toString();
  }
  
  /**
   * Create a new coinbase from data already provided.
   */
  Coinbase.fromData(String this.data);
  
  /**
   * Convert a Base58 Bitcoin address to its Hash-160 ASCII Hex
   * 
   * @param String address
   *   The base58 bitcoin address.
   *   
   * @return String
   *   The hash160 version of the address.
   */
  String addressToHash160(String address) {
    String table = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
    address = reverseString(address);
    int hash = 0;
    for (int i = 0; i < address.length; i++) {
      hash += pow(58, i) * table.indexOf(address[i]);
    }
    
    // Return the hash160.
    String hash160 = hash.toRadixString(16);
    return hash160.substring(0, (hash160.length - 8));
  }

  /**
   * Convert a bitcoin address to a public Key
   * 
   * @param String address
   *   The base58 bitcoin address.
   *   
   * @return String
   *   The public key version of a bitcoin address.
   */
  String addressToPubKey(String address) {
    StringBuffer buffer = new StringBuffer();
    buffer.write('76');   // OP_DUP
    buffer.write('a9');   // OP_HASH160
    buffer.write('14');   // push 20 bytes
    buffer.write(addressToHash160(address));
    buffer.write('88');   // OP_EQUALVERIFY
    buffer.write('ac');   // OP_CHECKSIG
    return buffer.toString();
  }
  
  /**
   * Return the data provided an extranonce.
   * 
   * @param int extranonce
   *   The extranonce to add to the coinbase data.
   *   
   * @return String
   *   The data from the coinbase.
   */
  String getData([int extranonce = 0]) {
    // Return the original coinbase if the extranonce is 0.
    if (extranonce == 0) {
      return data;
    }
    
    // Get the original length;
    int origLen = int.parse(data.substring(82, 84), radix: 16);
    int newLen = origLen + 8;
    int offset = 84 + (origLen * 2);
    
    // Create a new string buffer.
    StringBuffer coinbase = new StringBuffer();
    coinbase.write(data.substring(0, 82));
    coinbase.write(int2PaddedHex(newLen, 2));
    coinbase.write(data.substring(84, offset));
    coinbase.write(bigword2LEHex(extranonce));
    coinbase.write(data.substring(offset));
    return coinbase.toString();
  }
}