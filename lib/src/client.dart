import 'package:chikin_airdrop_pool_client/src/model.dart';
import 'package:solana/solana.dart';

import 'utils.dart' as utils;

Future<AirdropPool?> getAirdropPool({
  required RPCClient rpcClient,
  required String poolAccountId,
}) async {
  final poolAccount = await rpcClient.getAccountInfo(poolAccountId);
  if (poolAccount == null) return null;
  final result = poolAccount.data
      ?.mapOrNull(fromBytes: (value) => AirdropPool.unpack(value.bytes));
  if (result == null) {
    throw Exception(
        'client.getAirdropPool : Failed to unpack account ${poolAccount.data?.runtimeType}');
  }
  return result;
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
  final result = claimerAccount.data
      ?.mapOrNull(fromBytes: (value) => AirdropClaimer.unpack(value.bytes));
  if (result == null) {
    throw Exception(
        'client.getAirdropClaimer : Failed to unpack account ${claimerAccount.data?.runtimeType}');
  }
  return result;
}
