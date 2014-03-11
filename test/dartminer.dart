import 'package:unittest/unittest.dart';
import 'package:dartminer/dartminer.dart';
import 'dart:async';

void main() {
  
  // Gets the mining result from a block.
  Map<String, String> getResult(dynamic blockJSON) {
    Block block = new Block.fromJSON(blockJSON);
    Miner miner = new Miner.fromWork(block.toWork());
    return miner.mine();
  }
  
  // Test getting the merkle root.
  test('MerkleRoot calculations', () {
    getJSON('getblock3.json').then(expectAsync((dynamic res) {
      Block block = new Block.fromJSON(res['result']);
      expect(block.merkleroot, block.merkleRoot());
      getJSON('getblock4.json').then(expectAsync((dynamic res) {
        Block block = new Block.fromJSON(res['result']);
        expect(block.merkleroot, block.merkleRoot());
        getJSON('getblock5.json').then(expectAsync((dynamic res) {
          Block block = new Block.fromJSON(res['result']);
          expect(block.merkleroot, block.merkleRoot());
          getJSON('getblock.json').then(expectAsync((dynamic res) {
            Block block = new Block.fromJSON(res['result']);
            expect(block.merkleroot, block.merkleRoot());
          }));
        }));
      }));
    }));
  });

  // Test a mining operation.
  test('Block Mining', () {
    getJSON('getblock3.json').then(expectAsync((dynamic res) {
      Map<String, String> result = getResult(res['result']);
      expect(int.parse(result['nonce']), res['result']['nonce']);
      expect(result['hash'], res['result']['hash']);
      getJSON('getblock4.json').then(expectAsync((dynamic res) {
        Map<String, String> result = getResult(res['result']);
        expect(int.parse(result['nonce']), res['result']['nonce']);
        expect(result['hash'], res['result']['hash']);
        getJSON('getblock5.json').then(expectAsync((dynamic res) {
          Map<String, String> result = getResult(res['result']);
          expect(int.parse(result['nonce']), res['result']['nonce']);
          expect(result['hash'], res['result']['hash']);
          getJSON('getblock.json').then(expectAsync((dynamic res) {
            Map<String, String> result = getResult(res['result']);
            expect(int.parse(result['nonce']), res['result']['nonce']);
            expect(result['hash'], res['result']['hash']);
          }));
        }));
      }));
    }));
  });
  
  test('doubleHash', () {
    String test = '020000003c48a294584f90e58325c60ca82896d071826b45680a661cec4d424d00000000de6433d46c0c7f50d84a05aec77be0199176cdd47f77e344b6f50c84380fddba66dc47501d00ffff00000000';
    String hash = '913d5c7f6625529bde85c1d656591b64560b8bbf11213c4d22c4bad957c954ae';
    expect(doubleHash(test), hash);
  });
  
  test('getwork Mining', () {
    getJSON('getwork.json').then(expectAsync((dynamic res) {
      String data = '0000000109a78d37203813d08b45854d51470fcdb588d6dfabbe946e92ad207e0000000038a8ae02f7471575aa120d0c85a10c886a1398ad821fadf5124c37200cb677854e0603871d07fff831952e35000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000';
      Miner miner = new Miner.fromJSON(res['result'], nonce: reverseBytesInWord(0x204e2e35));
      Map<String, String> result = miner.mine();
      expect(result['data'], data);
    }));
  });
  
  test('Data to Header to Miner', () {
    String data = '00000002b15704f4ecae05d077e54f6ec36da7f20189ef73b77603225ae56d2b00000000b052cbbdeed2489ccb13a526b77fadceef4caf7d3bb82a9eb0b69ebb90f9f5a7510c27fd1c0e8a37fa531338000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000';
    Block block = new Block.fromData(data);
    Miner miner = new Miner.fromHeader(block.getHeader(), block.target);
    miner.work.nonce = miner.work.data[3];
    Map<String, String> result = miner.mine();
    expect(result['data'], data);
  });
  
  test('Data to Miner', () {
    String data = '00000002b15704f4ecae05d077e54f6ec36da7f20189ef73b77603225ae56d2b00000000b052cbbdeed2489ccb13a526b77fadceef4caf7d3bb82a9eb0b69ebb90f9f5a7510c27fd1c0e8a37fa531338000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000';
    Miner miner = new Miner.fromWork(new Work.fromData(data));
    miner.work.nonce = miner.work.data[3];
    Map<String, String> result = miner.mine();
    expect(result['data'], data);
  });
  
  test('Data to Block to Miner', () {
    String data = '00000002b15704f4ecae05d077e54f6ec36da7f20189ef73b77603225ae56d2b00000000b052cbbdeed2489ccb13a526b77fadceef4caf7d3bb82a9eb0b69ebb90f9f5a7510c27fd1c0e8a37fa531338000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000';
    Block block = new Block.fromData(data);
    Miner miner = new Miner.fromWork(block.toWork());
    miner.work.nonce = miner.work.data[3];
    Map<String, String> result = miner.mine();
    expect(result['data'], data);
  });
  
  test('Test getblocktemplate', () {
    getJSON('template.json').then(expectAsync((dynamic tpl) {
      String data = '020000003c48a294584f90e58325c60ca82896d071826b45680a661cec4d424d00000000de6433d46c0c7f50d84a05aec77be0199176cdd47f77e344b6f50c84380fddba66dc47501d00ffff000001000101000000010000000000000000000000000000000000000000000000000000000000000000ffffffff1302955d0f00456c6967697573005047dc66085fffffffff02fff1052a010000001976a9144ebeb1cd26d6227635828d60d3e0ed7d0da248fb88ac01000000000000001976a9147c866aee1fa2f3b3d5effad576df3dbf1f07475588ac00000000';
      Template template = new Template.fromJSON(tpl['result'], address: '1N438cAaGjY9cyZ5J5hgvixkch3hiu6XA1');
      Map<String, String> result = template.mine();
      expect(result['data'], data);
    }));
  });  
}
