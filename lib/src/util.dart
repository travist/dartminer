part of dartminer;

/**
 * Reverses the bytes in a half word.
 * 
 * @param int halfword
 *   The 16 bit integer word to reverse the bytes.
 *   
 * @return int
 *   The integer with all of the bytes reversed.
 */
int reverseBytesInHalfWord(int halfword) {
  return (
    ((halfword >> 8) & 0xFF) |
    ((halfword & 0xFF) << 8)
  );
}

/**
 * Reverses the bytes in an integer word.
 * 
 * @param int word
 *   The 32 bit integer word to reverse the bytes.
 *   
 * @return int
 *   The integer with all of the bytes reversed.
 */
int reverseBytesInWord(int word) {
  return (
      ((word << 24) & 0xFF000000) |
      ((word <<  8) & 0x00FF0000) |
      ((word >>  8) & 0x0000FF00) |
      ((word >> 24) & 0x000000FF)
  );
}

/**
 * Reverses the bytes in an 64 bit integer.
 * 
 * @param int word
 *   The 64 bit integer word to reverse the bytes.
 *   
 * @return int
 *   The integer with all of the bytes reversed.
 */
int reverseBytesInBigWord(int bigword) {
  return (
   ((bigword & 0xFF00000000000000) >> 56) | 
   ((bigword & 0x00FF000000000000) >> 40) | 
   ((bigword & 0x0000FF0000000000) >> 24) | 
   ((bigword & 0x000000FF00000000) >> 8) | 
   ((bigword & 0x00000000FF000000) << 8) |
   ((bigword & 0x0000000000FF0000) << 24) | 
   ((bigword & 0x000000000000FF00) << 40) |
   ((bigword & 0x00000000000000FF) << 56)
  );
}

/**
 * Add padding to a number string.
 * 
 * @param num
 *   The number to add the padding to.
 *   
 * @param len
 *   The length that the string should be.
 */
String padNumString(String num, int len) {
  
  // If the length is the same return the string.
  if (num.length == len) {
    return num;
  }
  
  // Append a '0' to the beginning of the string.
  StringBuffer buf = new StringBuffer();
  for (int i = len; i > num.length; i--) {
    buf.write('0');
  }
  buf.write(num);
  return buf.toString();
}

// Convert functions.
String toHex(int num) => num.toRadixString(16).toLowerCase();
String int2PaddedHex(int num, int len) => padNumString(toHex(num), len);
String byte2LEHex(int byte) => padNumString(toHex((byte & 0xFF)), 2);
String halfWord2LEHex(int halfword) => padNumString(toHex(reverseBytesInHalfWord(halfword)), 4);
String word2LEHex(int word) => padNumString(toHex(reverseBytesInWord(word)), 8);
String bigword2LEHex(int bigword) => padNumString(toHex(reverseBytesInBigWord(bigword)), 16);

/**
 *  Convert an unsigned integer to little endian varint ASCII Hex
 *  
 *  @param int value
 *    The integer to create the LE variant hex.
 *    
 *  @return String
 *    The LE variant hex.
 */
String int2VarIntHex(int x) {
  if (x < 0xfd) {
    return byte2LEHex(x);
  }
  else if (x <= 0xffff) {
    return 'fd' + halfWord2LEHex(x);
  }
  else if (x <= 0xffffffff) {
    return 'fe' + word2LEHex(x);
  }
  else {
    return 'ff' + bigword2LEHex(x);
  }
}

/**
 * Convert a hexidecimal string to an array of 32bit unsigned integers.
 * 
 * @param String hex
 *   The hexidecimal string to convert.
 *   
 * @return List<int>
 *   The array of 32bit unsigned integers.
 */
List<int> hex2ReversedList(String hex) {
  int listSize = (hex.length / 8).ceil();
  List<int> arr = new List(listSize);
  int index = 0;
  int word = 0;
  for (var i = 0; i < hex.length; i += 8) {
    word = int.parse(hex.substring(i, (i + 8)), radix: 16);
    arr[index] = reverseBytesInWord(word);
    index++;
  }
  return arr;
}

/**
 * Convert a hexidecimal string to a list of codeUnits.
 * 
 * @param String hex
 *   The hexidecimal string.
 *   
 * @return List<int>
 *   The list of code units for the hex string.
 */
List<int> hex2CodeUnits(String hex) {
  if ((hex.length % 2) != 0) {
    hex = '0' + hex;
  }
  int listSize = (hex.length / 2).ceil();
  List<int> arr = new List(listSize);
  int index = 0;
  int word = 0;
  for (var i = 0; i < hex.length; i += 2) {
    arr[index] = int.parse(hex.substring(i, (i + 2)), radix: 16);
    index++;
  }
  return arr;
}

/**
 * List to reversed to hexidecial.
 */
String listToReversedHex(List<int> list) {
  var buf = new StringBuffer();
  String value = '';
  for (var part in list) {
    buf.write(word2LEHex(part));
  }
  return buf.toString();
}

/**
 * Convert a list to a hex string.
 */
String listToHex(List<int> list) {
  var buf = new StringBuffer();
  String value = '';
  for (int part in list) {
    buf.write(int2PaddedHex(part, 8));
  }
  return buf.toString();
}

/**
 * Reverse a string.
 */
String reverseString(String str) {
  return new String.fromCharCodes(str.codeUnits.reversed.toList());
}

/**
 * Return a json object from a file.
 * 
 * @param String fileName
 *   The name of the file you wish to get the JSON from.
 *   
 * @return Object
 *   A JSON object from the file.
 */
Future<dynamic> getJSON(String fileName) {
  Completer completer = new Completer();
  var file = new File(fileName);
  Future<String> finishedReading = file.readAsString(encoding: ASCII);
  finishedReading.then((String content) {
    completer.complete(JSON.decode(content));
  });
  return completer.future;
}

/**
 * Compute the doubleSHA of a list of string codeUnits.
 * 
 * @param List<int> codeUnits
 *   The code units from a string.
 *   
 * @return List<int>
 *   The code units from the encrypted string.
 */
List<int> doubleSHA256(List<int> codeUnits) {
  Crypto.SHA256 h1 = new Crypto.SHA256();
  Crypto.SHA256 h2 = new Crypto.SHA256();
  h1.add(codeUnits);
  h2.add(h1.close());
  return h2.close();
}

/**
 * Compute the double hash of a Hex string.
 * 
 * @param String data
 *   The string to hash.
 *   
 * @return String
 *   The double hashed hex string.
 */
String doubleHash(String data) {
  return Crypto.CryptoUtils.bytesToHex(doubleSHA256(hex2CodeUnits(data)).reversed.toList());
}