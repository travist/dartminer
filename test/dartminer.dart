import 'package:unittest/unittest.dart';
import 'package:dartminer/dartminer.dart';

void main() {

  test('Test byte conversions', () {
    expect(byte2LEHex(0x1a), '1a');
    expect(halfWord2LEHex(0x1a2b), '2b1a');
    expect(word2LEHex(0x1a2b3c4d), '4d3c2b1a');
    expect(bigword2LEHex(0x1a2b3c4d5e6f7a8b), '8b7a6f5e4d3c2b1a');
  });

  test("Double SHA", () {
    List<int> input = [97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122];
    List<int> output = [202, 19, 155, 193, 12, 47, 102, 13, 164, 38, 102, 247, 46, 137, 162, 37, 147, 111, 198, 15, 25, 60, 22, 17, 36, 166, 114, 5, 12, 67, 70, 113];
    expect(doubleSHA256(input), output);
    expect(new String.fromCharCodes(input), 'abcdefghijklmnopqrstuvwxyz');
  });

  test('Test int2VarIntHex', () {
    expect(int2VarIntHex(0x1a), '1a');
    expect(int2VarIntHex(0x1a2b), 'fd2b1a');
    expect(int2VarIntHex(0x1a2b3c), 'fe3c2b1a00');
    expect(int2VarIntHex(0x1a2b3c4d), 'fe4d3c2b1a');
    expect(int2VarIntHex(0x1a2b3c4d5e), 'ff5e4d3c2b1a000000');
  });

  test('Test padNumString', () {
    expect(padNumString('', 8), '00000000');
    expect(padNumString('234', 8), '00000234');
    expect(padNumString('12345678', 8), '12345678');
    expect(padNumString('', 4), '0000');
    expect(padNumString('12', 4), '0012');
    expect(padNumString('1234', 4), '1234');
  });

  test('Test doubleHash', () {
    String input = '01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff2503ef98030400001059124d696e656420627920425443204775696c640800000037000011caffffffff01a0635c95000000001976a91427a1f12771de5cc3b73941664b2537c15316be4388ac00000000';
    String output = '05f1f0c7fc25005e7c6e56805130b4d540125a8d09f81ec3da621f99ee5d15c1';
    expect(doubleHash(input), output);
  });

  // Test a mining operation.
  test('Test Mining', () {
    
    // Get the work.
    getJSON('getwork.json').then((dynamic work) {
      
      // Create the miner.
      Miner miner = new Miner(work);
      
      // Set the nonce to a value close to the solution.
      miner.work.nonce = hex2ReversedList('200e2e35')[0];
      
      // Mine for gold!
      String result = listToHex(miner.mine());
      
      // Print the result.
      print(result);
      expect(result, '01000000378da709d01338204d85458bcd0f4751dfd688b56e94beab7e20ad920000000002aea838751547f70c0d12aa880ca185ad98136af5ad1f8220374c128577b60c8703064ef8ff071d352e9531800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000280');
    });
  });
}
