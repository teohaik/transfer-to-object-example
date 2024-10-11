import { Transaction } from "@mysten/sui/transactions";

import {
  KIOSK_ID, NFT_TYPE,
  PACKAGE_ID, SUI_NETWORK,
  suiClient, TRANSFER_POLICY_ID,
} from "./helpers/config";
import * as fs from "fs";
import { getAdminSignerKeypair } from "./helpers/getSigner";


const run = async () => {
  const tx = new Transaction();


  const coolNFt = tx.moveCall({
    target: `${PACKAGE_ID}::coolnftext::mint_nft`,
    arguments: [tx.pure.string(" My cool NFT lives in a Kiosk Extension!")],
  });

  tx.moveCall({
    target: `${PACKAGE_ID}::coolnftext::place`,
    arguments: [tx.object(KIOSK_ID!), tx.object(coolNFt), tx.object(TRANSFER_POLICY_ID!)]
  });


  tx.setGasBudget(100000000);

  const res = await suiClient.signAndExecuteTransaction({
    signer: getAdminSignerKeypair(),
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
    let createdNft = res?.objectChanges?.find((obj) => {
      if (obj.type === "created" && obj.objectType.endsWith("TeoCoolNFT")) {
        return true;
      }
    });

    if (createdNft?.type == "created") {
      console.log("Cool NFT created successfully");
      const tpEnvVar = `\nNFT_ID=${createdNft.objectId}\n`;
      console.log(tpEnvVar);
      fs.appendFileSync("./.env", tpEnvVar);
    }
  } else {
    console.log("Tx Failed. Error "+JSON.stringify(res.effects?.status));
  }
};

run();
