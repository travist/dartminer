// Import the dartminer package.
import 'package:dartminer/dartminer.dart';

// Our main file
void main() {  
  
  // Create a bitcoin client with the proper configuration.  
  Bitcoin bitcoin = new Bitcoin({
    "scheme": "http",
    "host": "127.0.0.1",
    "port": 18332,
    "user": "bitcoinrpc",
    "pass": "123123123123123"
  });
  
  int nonce = 0;
  String midstate = '';
  
  // Mine for gold.
  void mineForGold() {
    
    // Get work from the bitcoind.
    bitcoin.getwork().then((dynamic work) {
      
      // Work.
      print(work);
      
      // Reset the nonce if this is different work.
      if (midstate != work['midstate']) {
        nonce = 0;
      }
      
      // Create the miner.
      Miner miner = new Miner.fromJSON(work, nonce: nonce);
      
      // Mine for gold!
      Map<String, String> result = miner.mine();
      
      // If the result isn't null, then
      if (result != null) {
        
        // We found gold!
        print('Gold!');
        print(result);
        bitcoin.getwork(params: [result['data']]);
      }
      else {
        
        // Save the nonce and midstate to pick up where we left off.
        nonce = miner.work.nonce;
        midstate = work['midstate'];
      }
      
      // Mine for more gold.
      mineForGold();
    });
  }
  
  // Mine for gold.
  mineForGold();
}
