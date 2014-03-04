part of dartminer;

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
String word2LEHex(int word) => padNumString(toHex(reverseBytesInWord(word)), 8);

/**
 * Convert a hexidecimal string to an array of 32bit unsigned integers.
 * 
 * @param String hex
 *   The hexidecimal string to convert.
 *   
 * @return Uint32List
 *   The array of 32bit unsigned integers.
 */
Uint32List hexToList(String hex, [bool reverseWords = true]) {
  int listSize = hex.length ~/ 8;
  Uint32List arr = new Uint32List(listSize);
  int index = 0;
  int word = 0;
  for (var i = 0; i < hex.length; i += 8) {
    word = int.parse(hex.substring(i, (i + 8)), radix: 16);
    arr[index] = reverseWords ? reverseBytesInWord(word) : word;
    index++;
  }
  return arr;
}

/**
 * Convert a hexidecimal string to an array of 32bit unsigned integers.
 * 
 * @param String hex
 *   The hexidecimal string to convert.
 *   
 * @return Uint32List
 *   The array of 32bit unsigned integers.
 */
Uint32List hexToReversedList(String hex, [bool reverseWords = true]) {
  Uint32List arr = new Uint32List(hex.length ~/ 8);
  int word = 0;
  int index = 0;
  for (var i = hex.length; i > 0; i -= 8) {
    String test = hex.substring((i - 8), i);
    word = int.parse(hex.substring((i - 8), i), radix: 16);
    arr[index++] = reverseWords ? reverseBytesInWord(word) : word;
  }
  return arr;
}

/**
 * Convert a list to a hex string.
 */
String listToHex(Uint32List list) {
  StringBuffer buf = new StringBuffer();
  for (int part in list) {
    buf.write(word2LEHex(part));
  }
  return buf.toString();
}

String listToReversedHex(Uint32List list) {
  StringBuffer buff = new StringBuffer();
  int i = list.length;
  while (i-- > 0) {
    buff.write(word2LEHex(list[i]));
  }
  return buff.toString();
}
