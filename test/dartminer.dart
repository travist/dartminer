import 'package:unittest/unittest.dart';
import 'package:dartminer/dartminer.dart';

void main() {
  
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
