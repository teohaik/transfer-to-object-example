import { Transaction } from "@mysten/sui/transactions";

import {
  KIOSK_ID,
  NFT_ID,
  PACKAGE_ID,
  suiClient,
} from "./helpers/config";
import { getUserSignerKeypair } from "./helpers/getSigner";

const run = async () => {
  const tx = new Transaction();

  tx.moveCall({
    target: `${PACKAGE_ID}::coolnftext::vote_NFT`,
    arguments: [tx.object(NFT_ID!), tx.object(KIOSK_ID!)],
  });

  tx.moveCall({
    target: `${PACKAGE_ID}::coolnftext::count_votes`,
    arguments: [tx.object(NFT_ID!), tx.object(KIOSK_ID!)],
  });

  tx.setGasBudget(100000000);

  const res = await suiClient.signAndExecuteTransaction({
    signer: getUserSignerKeypair(),
    transaction: tx,
    options: {
      showEffects: true,
      showObjectChanges: true,
    },
  });

  if (
    res.effects &&
    res.effects.status &&
    res.effects.status.status === "success"
  ) {
   console.log("Vote created successfully, Digest: " + res.digest);
  } else {
    console.log("Tx Failed. Error "+JSON.stringify(res.effects?.status));
  }
};

run();
