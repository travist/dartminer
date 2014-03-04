import 'package:unittest/unittest.dart';
import 'package:dartminer/dartminer.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

void main() {
  
  // Gets the JSON from a file.
  Future<dynamic> getJSON(String fileName) {
    Completer completer = new Completer();
    var file = new File(fileName);
    Future<String> finishedReading = file.readAsString(encoding: ASCII);
    finishedReading.then((String content) {
      completer.complete(JSON.decode(content));
    });
    return completer.future;
  }
  
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
  
  test('getwork Mining', () {
    getJSON('getwork.json').then(expectAsync((dynamic res) {
      String data = '0000000109a78d37203813d08b45854d51470fcdb588d6dfabbe946e92ad207e0000000038a8ae02f7471575aa120d0c85a10c886a1398ad821fadf5124c37200cb677854e0603871d07fff831952e35000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000';
      Miner miner = new Miner.fromJSON(res['result'], reverseBytesInWord(0x204e2e35));
      Map<String, String> result = miner.mine();
      expect(result['data'], data);
    }));
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
}
