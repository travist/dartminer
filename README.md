Dartminer - An example bitcoin mining package written in Dart.
-----------------------------------------------------------------
This is an example application of how to build a Bitcoin mining application
using the Dart language.  I also recommend only using this
application using the TestNet within Bitcoin so that you do not risk of 
hitting the live network with sample code.

On my machine, I was able to hit hash rate of about 500kH/s, which turns out
to be about a 15x speed improvement on a JavaScript implementation... While
this is impressive, here's hoping that the Dash VM improves in performance with
future releases.

Usage
===========
Below is the steps necessary to get this to work.

 - Install the Dart SDK and Editor by going to http://dartlang.org.
 - Install the Bitcoin-Qt client by going to https://bitcoin.org/en/download
 - Ensure that you run Bitcoin-Qt in testnet mode by following the guide http://suffix.be/blog/getting-started-bitcoin-testnet
 - Add this project to your library and then use the following code to mine bitcoins.

Mining with getwork.
===================== 
```dart
import 'package:dartminer/dartminer.dart';
 
 // Our main entry point.
void main() {  
  
  // Create a bitcoin client with the proper configuration.  
  Bitcoin bitcoin = new Bitcoin({
    "scheme": "http",
    "host": "127.0.0.1",
    "port": 18332,
    "user": "bitcoinrpc",
    "pass": "123123123123"
  });
  
  // Get work from the bitcoind.
  bitcoin.getwork().then((Map<String, String> work) {
    
    // Work.
    print(work);
    
    // Create the miner.
    Miner miner = new Miner.fromJSON(work);
    
    // Mine for gold!
    Map<String, String> result = miner.mine();
    
    // If the result isn't null, then
    if (result != null) {
      print('Gold!');
      print(result);
      bitcoin.getwork(params: [result['data']]);
    }
  });
}
```

Mining with getblocktemplate
============================

```dart
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
    
  // Get work from the bitcoind.
  bitcoin.getblocktemplate().then((dynamic tpl) {
    
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
  });
}
```

Donations Welcome:  1N438cAaGjY9cyZ5J5hgvixkch3hiu6XA1

Enjoy...
