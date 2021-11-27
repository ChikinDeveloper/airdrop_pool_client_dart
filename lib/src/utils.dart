import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:solana/solana.dart' as solana;
import 'package:solana_js/solana_js.dart';

import 'config.dart';

Future<String> getPoolAccountId({
  required String programId,
  required String tokenMintId,
  required List<int> nonce,
}) {
  return SolanaJsUtils.findProgramAddress(
    seeds: [
      solana.base58decode(programId),
      solana.base58decode(tokenMintId),
      utf8.encode('pool_account'),
      nonce,
    ],
    programId: programId,
  );
}

Future<String> getPoolTokenAccountId({
  required String programId,
  required String poolAccountId,
}) {
  return SolanaJsUtils.findProgramAddress(
    seeds: [
      solana.base58decode(programId),
      solana.base58decode(poolAccountId),
      utf8.encode('pool_token_account'),
    ],
    programId: programId,
  );
}

Future<String> getClaimerAccountId({
  required String programId,
  required String poolAccountId,
  required String claimerWalletId,
}) {
  return SolanaJsUtils.findProgramAddress(
    seeds: [
      solana.base58decode(programId),
      solana.base58decode(poolAccountId),
      solana.base58decode(claimerWalletId),
      utf8.encode('claimer_account'),
    ],
    programId: programId,
  );
}

Future<String> getClaimerTokenAccountId({
  required Config config,
  required String tokenMintId,
  required String claimerWalletId,
}) async {
  return SolanaJsUtils.findProgramAddress(
    seeds: [
      solana.base58decode(claimerWalletId),
      solana.base58decode(config.tokenProgramId),
      solana.base58decode(tokenMintId),
    ],
    programId: config.associatedTokenProgramId,
  );
}

int unpackUInt(List<int> data, {Endian endian = Endian.little}) {
  var slice = List.of(data);
  if (endian == Endian.big) {
    slice = slice.reversed.toList();
  }
  var result = 0;
  var pow = 0;
  for (final e in slice) {
    result += e * math.pow(2, pow).toInt();
    pow += 8;
  }
  return result;
}

List<int> packUInt32(int data, {Endian endian = Endian.little}) {
  return Uint8List(4)..buffer.asByteData().setUint32(0, data, endian);
}

List<int> packUInt64(int data, {Endian endian = Endian.little}) {
  return Uint8List(8)..buffer.asByteData().setUint64(0, data, endian);
}
