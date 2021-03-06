// Import the dartminer package.
import 'package:dartminer/dartminer.dart';
import 'package:dartminer/dartrpcminer.dart';

// Our main file
void main() {
  
  // Create a bitcoin client with the proper configuration.  
  Bitcoin bitcoin = new Bitcoin({
    "scheme": "http",
    "host": "127.0.0.1",
    "port": 18332,
    "user": "bitcoinrpc",
    "pass": "123123123123123123"
  }, new RPCRequest());
  
  int nonce = 0;
  String prevHash = '';
  
  // Mine for gold.
  void mineForGold() {
    
    // Get work from the bitcoind.
    bitcoin.getblocktemplate().then((dynamic tpl) {
      
      // The template we are mining.
      print(tpl);
      
      // Create the new template.
      Template template = new Template.fromJSON(tpl, address: 'mrvHE9WB1YzSKdXM271MKo5tKskLhbSaBn');
      
      // Reset the nonce if the previousblock hash isn't the same.
      if (prevHash != tpl['previousblockhash']) {
        nonce = 0;
      }
      
      // Mine for gold.
      Map<String, String> result = template.mine(nonce);
      
      // See if there is a result.
      if (result != null) {
        
        // We found gold!
        print('GOLD!');
        
        // Print the result.
        print(result);
        
        // Submit the block.
        bitcoin.submitblock(params: [result['data']]);
        nonce = 0;
      }
      else {
        
        // Save the nonce in case the merkle root is the same next pass.
        nonce = template.miner.work.nonce;
        prevHash = tpl['previousblockhash'];
      }
     
      // Mine for more gold!
      mineForGold();
    });
  }
  
  // Mine for gold.
  mineForGold();
}
