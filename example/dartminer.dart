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
    "pass": "123123123123"
  });
  
  // Get work from the client.
  bitcoin.getwork().then((Map<String, String> work) {
    
    // Create the miner.
    Miner miner = new Miner(work);
    
    // Mine for gold!
    List<int> result = miner.mine();
    
    // Print the result!
    print(result);
  });
}
