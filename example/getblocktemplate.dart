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
  
  // Mine for gold.
  void mineForGold() {
    
    // Get work from the bitcoind.
    bitcoin.getblocktemplate().then((dynamic tpl) {
      
      // The template we are mining.
      print(tpl);
      
      // Create the new template.
      Template template = new Template.fromJSON(tpl, address: '1N438cAaGjY9cyZ5J5hgvixkch3hiu6XA1');
      
      // Mine for gold.
      Map<String, String> result = template.mine();
      
      // See if there is a result.
      if (result != null) {
        
        // We found gold!
        print('GOLD!');
        
        // Print the result.
        print(result);
        
        // Submit the block.
        bitcoin.submitblock(params: [result['data']]);
      }
      
      // Mine for more gold!
      mineForGold();
    });
  }
  
  // Mine for gold.
  mineForGold();
}
