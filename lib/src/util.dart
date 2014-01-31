part of dartminer;

/**
 * Convert a hexidecimal string to an array of 32bit unsigned integers.
 * 
 * @param String hex
 *   The hexidecimal string to convert.
 *   
 * @return List<int>
 *   The array of 32bit unsigned integers.
 */
List<int> hexStringToList(String hex) {
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
 * Reverses the bytes in an integer word.
 * 
 * @param int word
 *   The integer word to reverse the bytes.
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
 * List to reversed to hexidecial.
 */
String listToReversedHex(List<int> list) {
  var buf = new StringBuffer();
  String value = '';
  for (var part in list) {
    part = reverseBytesInWord(part);
    value = part.toRadixString(16).toLowerCase();
    for (var i = 8; i > value.length; i--) {
      buf.write("0");
    }
    buf.write(value);
  }
  return buf.toString();
}

/**
 * Convert a list to a hex string.
 */
String listToHex(List<int> list) {
  var buf = new StringBuffer();
  String value = '';
  for (var part in list) {
    value = part.toRadixString(16).toLowerCase();
    for (var i = 8; i > value.length; i--) {
      buf.write("0");
    }
    buf.write(value);
  }
  return buf.toString();
}