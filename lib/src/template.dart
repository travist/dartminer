part of dartminer;

class Template {
  // The base58 bitcoin address.
  String address;

  // The block for this template.
  late Block block;

  // The extra nonce.
  int extranonce;

  // The template object.
  dynamic template;

  // The created timestamp.
  late int created;

  // The expiration of this template.
  int? expires;

  // The coinbase data.
  late String coinbaseData;

  // The list of mutations.
  late Map<String, bool> mutations;

  // The miner for the template.
  late Miner miner;

  /**
   * Create a new template from JSON.
   */
  Template.fromJSON(dynamic this.template, {int this.extranonce = 0, String this.address = ''}) {
    // Set the created timestamp.
    created = now();

    // Set the expiration time.
    expires = template['expires'];
    expires = (expires == null) ? 120 : expires;

    // Set the mutations.
    mutations = {};
    template['result']['mutable'].forEach((mutable) {
      mutations[mutable] = true;
    });
  }

  /**
   * Determine if we have time left in our mining.
   */
  bool timeLeft() {
    // If no expiration, then return true.
    if (expires == null || expires == 0) {
      return true;
    }

    // Get the now time.
    int timestamp = now();

    // See how old this template is.
    int age = timestamp - created;
    return (age < expires!);
  }

  /**
   * Determine if there is more work to be done.
   */
  bool workLeft() {
    // If these mutations are not available, then always return true.
    if (!mutations.containsKey('coinbase/append') && !mutations.containsKey('coinbase')) {
      return true;
    }

    // Return that the extranonce can be iterated.
    return (extranonce < 0xffffffffffffffff);
  }

  /**
   * Mine for gold.
   */
  Map<String, String>? mine([int nonce = 0]) {
    // Initialize the variables.
    Map<String, String>? result = null;
    Uint32List? data = null;

    // Iterate while we are still creating blocks.
    while (createBlock()) {
      // Create the miner.
      miner = new Miner.fromHeader(block.getHeader(false), block.target, nonce: nonce, expires: (expires! - (now() - created)));

      // Mine for gold.
      result = miner.mine(false);
      break;

      // Increment the extranonce.
      extranonce++;
    }

    // Reformat the result for a submitwork.
    StringBuffer buffer = new StringBuffer();
    buffer.write(result!['data']!.substring(0, 152));
    buffer.write(int2PaddedHex(miner.work.nonce, 8));

    // If submit/truncate is not in the mutations.
    if (!mutations.containsKey('submit/truncate')) {
      // Add the length of transactions.
      buffer.write(int2VarIntHex(block.tx.length));

      // Add the coinbase transaction.
      buffer.write(coinbaseData);

      // Only execute if the submit/coinbase isn't set.
      if (!mutations.containsKey('submit/coinbase')) {
        for (int i = 1; i < template['transactions'].length; i++) {
          buffer.write(template['transactions'][i]['data']);
        }
      }
    }

    // Set the new data.
    result['data'] = buffer.toString();

    // Return the result.
    return result;
  }

  /**
   * Returns more work to do.
   */
  bool createBlock([int nonce = 0]) {
    // The coinbase.
    Coinbase? coinbase = null;

    // See if there is more work to do.
    if (workLeft() && timeLeft()) {
      // Create the coinbase if it hasn't already been created.
      if (coinbase == null) {
        // Check to see if the template has the actual coinbase txn.
        if (template['result'].containsKey('coinbasetxn')) {
          // Create the coinbase from existing data.
          coinbase = new Coinbase.fromData(template['result']['coinbasetxn']['data']);
        } else if (template['result'].containsKey('coinbaseaux')) {
          // We must have a bitcoin address to create a coinbase with address.
          if (address != '') {
            // Create a new coinbase from the aux, value and bitcoin address.
            coinbase = new Coinbase(template['result']['coinbaseaux']['flags'], template['result']['coinbasevalue'], address);
          } else {
            // Throw an error.
            throw ("You must define a bitcoin address to create coinbase.");
          }
        }
      }

      // Make sure we have a coinbase.
      coinbaseData = coinbase!.getData(extranonce);
      template['transactions'].insert(0, {'data': coinbaseData, 'hash': doubleHash(coinbaseData)});

      // Set the nonce to 0.
      template['nonce'] = nonce;

      // Create a new block from the template.
      block = new Block.fromTemplate(template);

      // Return that we have more work to do.
      return true;
    }

    // Return that work has been done.
    return false;
  }
}
