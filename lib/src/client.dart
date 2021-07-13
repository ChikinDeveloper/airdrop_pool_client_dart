import 'dart:convert';

import 'package:chikin_airdrop_pool_client/src/model.dart';
import 'package:solana/solana.dart';

import 'utils.dart' as utils;

Future<AirdropPool?> getAirdropPool({
  required RPCClient rpcClient,
  required String poolAccountId,
}) async {
  final poolAccount = await rpcClient.getAccountInfo(poolAccountId);
  if (poolAccount == null) return null;
  final dataBytes = base64.decode(poolAccount.data[0]);
  return AirdropPool.unpack(dataBytes);
}

Future<AirdropClaimer?> getAirdropClaimer({
  required RPCClient rpcClient,
  required String programId,
  required String poolAccountId,
  required String claimerWalletId,
}) async {
  final claimerAccountId = await utils.getClaimerAccountId(
    programId: programId,
    poolAccountId: poolAccountId,
    claimerWalletId: claimerWalletId,
  );
  final claimerAccount = await rpcClient.getAccountInfo(claimerAccountId);
  if (claimerAccount == null) return null;
  final dataBytes = base64.decode(claimerAccount.data[0]);
  return AirdropClaimer.unpack(dataBytes);
}
