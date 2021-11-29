import 'package:chikin_airdrop_pool_client/src/model.dart';
import 'package:solana/solana.dart';

import 'utils.dart' as utils;

Future<AirdropPool?> getAirdropPool({
  required RpcClient rpcClient,
  required String poolAccountId,
}) async {
  final poolAccount = await rpcClient.getAccountInfo(poolAccountId, encoding: Encoding.base64);
  if (poolAccount == null) return null;
  return AirdropPool.unpack((poolAccount.data as BinaryAccountData).data);
}

Future<AirdropClaimer?> getAirdropClaimer({
  required RpcClient rpcClient,
  required String programId,
  required String poolAccountId,
  required String claimerWalletId,
}) async {
  final claimerAccountId = await utils.getClaimerAccountId(
    programId: programId,
    poolAccountId: poolAccountId,
    claimerWalletId: claimerWalletId,
  );
  final claimerAccount = await rpcClient.getAccountInfo(claimerAccountId, encoding: Encoding.base64);
  if (claimerAccount == null) return null;
  return AirdropClaimer.unpack((claimerAccount.data as BinaryAccountData).data);
}
