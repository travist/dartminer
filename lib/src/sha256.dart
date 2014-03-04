part of dartminer;

// This is a customized/stand-alone version of SHA256 that is different than the 
// crypto/SHA256 in a couple of ways...
//
//   1.) It is optimized for performance for faster hashes.
//   2.) It allows you to update the state (_h) which allows you to set the
//       midstate of the sha256 hash.

// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

const _MASK_32 = 0xffffffff;

/**
 * SHA256 hash function implementation.
 * 
 * Taken from crypto/src/sha256.dart with changes to support
 * bitcoin mining.
 */
class SHA256 {
  
  // Construct a SHA256 hasher object.
  SHA256([Uint32List init]) : 
    state = new Uint32List(8),
    _w = new Uint32List(64) {
    
    // Reset with the inital value.
    reset(init);
  }
  
  // Initial value of the hash parts. First 32 bits of the fractional parts
  // of the square roots of the first 8 prime numbers.
  static Uint32List _I = new Uint32List.fromList([
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
  ]);

  // Table of round constants. First 32 bits of the fractional
  // parts of the cube roots of the first 64 prime numbers.
  static Uint32List _K = new Uint32List.fromList([
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
  ]);

  // Helper functions as defined in http://tools.ietf.org/html/rfc6234
  int _add32(x, y) => (x + y) & _MASK_32;
  _rotr32(n, x) => (x >> n) | ((x << (32 - n)) & _MASK_32);
  _ch(x, y, z) => (x & y) ^ ((~x & _MASK_32) & z);
  _maj(x, y, z) => (x & y) ^ (x & z) ^ (y & z);
  _bsig0(x) => _rotr32(2, x) ^ _rotr32(13, x) ^ _rotr32(22, x);
  _bsig1(x) => _rotr32(6, x) ^ _rotr32(11, x) ^ _rotr32(25, x);
  _ssig0(x) => _rotr32(7, x) ^ _rotr32(18, x) ^ (x >> 3);
  _ssig1(x) => _rotr32(17, x) ^ _rotr32(19, x) ^ (x >> 10);
  
  // Set the state of the hash.
  void setState(List<int> _state) {
    for (int i = 0; i < 8; i++) {
      state[i] = _state[i];
    }
  }
  
  // Reset the hash to the initial state.
  void reset([List<int> init]) {
    setState(init == null ? _I : init);
  }
  
  // Compute one iteration of the SHA256 algorithm with a chunk of
  // 16 32-bit pieces.
  void update(List<int> M) {
    assert(M.length == 16);

    // Prepare message schedule.
    var i = 0;
    for (; i < 16; i++) {
      _w[i] = M[i];
    }
    for (; i < 64; i++) {
      _w[i] = _add32(_add32(_ssig1(_w[i - 2]), _w[i - 7]),
                     _add32(_ssig0(_w[i - 15]), _w[i - 16]));
    }

    // Shuffle around the bits.
    var a = state[0];
    var b = state[1];
    var c = state[2];
    var d = state[3];
    var e = state[4];
    var f = state[5];
    var g = state[6];
    var h = state[7];

    for (var t = 0; t < 64; t++) {
      var t1 = _add32(_add32(h, _bsig1(e)),
                      _add32(_ch(e, f, g), _add32(_K[t], _w[t])));
      var t2 = _add32(_bsig0(a), _maj(a, b, c));
      h = g;
      g = f;
      f = e;
      e = _add32(d, t1);
      d = c;
      c = b;
      b = a;
      a = _add32(t1, t2);
    }

    // Update hash values after iteration.
    state[0] = _add32(a, state[0]);
    state[1] = _add32(b, state[1]);
    state[2] = _add32(c, state[2]);
    state[3] = _add32(d, state[3]);
    state[4] = _add32(e, state[4]);
    state[5] = _add32(f, state[5]);
    state[6] = _add32(g, state[6]);
    state[7] = _add32(h, state[7]);
  }

  Uint32List _w;
  Uint32List state;  
}
