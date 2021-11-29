import 'package:chikin_airdrop_pool_client/src/config.dart';
import 'package:chikin_airdrop_pool_client/src/model.dart';
import 'package:solana/solana.dart';

import 'client.dart' as client;
import 'utils.dart' as utils;

Future<Instruction> initialize({
  required Config config,
  required String payerId,
  required String tokenMintId,
  required List<int> poolAccountNonce,
  required int rewardPerAccount,
  required int rewardPerReferral,
  required int maxReferralDepth,
}) async {
  final poolAccountId = await utils.getPoolAccountId(
      programId: config.programId,
      tokenMintId: tokenMintId,
      nonce: poolAccountNonce);
  final poolTokenAccountId = await utils.getPoolTokenAccountId(
      programId: config.programId, poolAccountId: poolAccountId);

  return Instruction(
    programId: config.programId,
    accounts: [
      AccountMeta.writeable(pubKey: payerId, isSigner: true),
      AccountMeta.readonly(pubKey: config.programId, isSigner: false),
      AccountMeta.readonly(pubKey: config.rentSysvarId, isSigner: false),
      AccountMeta.readonly(pubKey: config.systemProgramId, isSigner: false),
      AccountMeta.readonly(pubKey: config.tokenProgramId, isSigner: false),
      AccountMeta.readonly(pubKey: tokenMintId, isSigner: false),
      AccountMeta.readonly(pubKey: poolAccountId, isSigner: false),
      AccountMeta.readonly(pubKey: poolTokenAccountId, isSigner: false),
    ],
    data: AirdropPoolInstructionInitialize(
      poolAccountNonce: poolAccountNonce,
      rewardPerAccount: rewardPerAccount,
      rewardPerReferral: rewardPerReferral,
      maxReferralDepth: maxReferralDepth,
    ).pack(),
  );
}

Future<Instruction> claim({
  required RpcClient rpcClient,
  required Config config,
  required String tokenMintId,
  required String poolAccountId,
  required String claimerWalletId,
  String? referrerWalletId,
}) async {
  final poolTokenAccountId = await utils.getPoolTokenAccountId(
      programId: config.programId, poolAccountId: poolAccountId);
  final claimerAccountId = await utils.getClaimerAccountId(
      programId: config.programId,
      poolAccountId: poolAccountId,
      claimerWalletId: claimerWalletId);
  final claimerTokenAccountId = await utils.getClaimerTokenAccountId(
      config: config,
      tokenMintId: tokenMintId,
      claimerWalletId: claimerWalletId);

  final accounts = <AccountMeta>[
    AccountMeta.readonly(pubKey: config.programId, isSigner: false),
    AccountMeta.readonly(pubKey: config.rentSysvarId, isSigner: false),
    AccountMeta.readonly(pubKey: config.systemProgramId, isSigner: false),
    AccountMeta.readonly(pubKey: config.tokenProgramId, isSigner: false),
    AccountMeta.readonly(pubKey: tokenMintId, isSigner: false),
    AccountMeta.writeable(pubKey: poolAccountId, isSigner: false),
    AccountMeta.writeable(pubKey: poolTokenAccountId, isSigner: false),
    AccountMeta.writeable(pubKey: claimerWalletId, isSigner: true),
    AccountMeta.writeable(pubKey: claimerAccountId, isSigner: false),
    AccountMeta.writeable(pubKey: claimerTokenAccountId, isSigner: false),
  ];

  if (referrerWalletId != null) {
    // Get referrer list
    final poolAccountState = (await client.getAirdropPool(
        rpcClient: rpcClient, poolAccountId: poolAccountId))!;
    String? currentReferrerWalletId = referrerWalletId;
    var currentReferralDepth = 1;
    while (currentReferrerWalletId != null &&
        currentReferralDepth <= poolAccountState.maxReferralDepth) {
      final referrerAccountId = await utils.getClaimerAccountId(
          programId: config.programId,
          poolAccountId: poolAccountId,
          claimerWalletId: currentReferrerWalletId);
      final referrerTokenAccountId = await utils.getClaimerTokenAccountId(
          config: config,
          tokenMintId: tokenMintId,
          claimerWalletId: currentReferrerWalletId);
      accounts.add(
          AccountMeta.writeable(pubKey: referrerWalletId, isSigner: false));
      accounts.add(
          AccountMeta.writeable(pubKey: referrerAccountId, isSigner: false));
      accounts.add(AccountMeta.writeable(
          pubKey: referrerTokenAccountId, isSigner: false));
      final referrerAccount = (await client.getAirdropClaimer(
          rpcClient: rpcClient,
          programId: config.programId,
          poolAccountId: poolAccountId,
          claimerWalletId: currentReferrerWalletId))!;
      currentReferrerWalletId = (referrerAccount.referrerWallet == null)
          ? null
          : base58encode(referrerAccount.referrerWallet!);
      currentReferralDepth += 1;
    }
  }

  return Instruction(
    programId: config.programId,
    accounts: accounts,
    data: AirdropPoolInstructionClaim(
      referrerWallet:
          (referrerWalletId == null) ? null : base58decode(referrerWalletId),
    ).pack(),
  );
}
