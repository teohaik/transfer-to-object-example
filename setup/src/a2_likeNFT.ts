import { Transaction } from "@mysten/sui/transactions";

import {
  NFT_ID,
  PACKAGE_ID,
  suiClient,
} from "./helpers/config";
import { getUserSignerKeypair } from "./helpers/getSigner";

const run = async () => {
  const tx = new Transaction();

  const USER_ADDRESS = getUserSignerKeypair().toSuiAddress();

console.log("USER_ADDRESS", USER_ADDRESS);


  tx.moveCall({
    target: `${PACKAGE_ID}::coolnft::like_NFT`,
    arguments: [tx.pure.address(NFT_ID)],
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
    let createdNft = res?.objectChanges?.find((obj) => {
      if (obj.type === "created" && obj.objectType.endsWith("Like")) {
        return true;
      }
    });

    if (createdNft?.type == "created") {
      console.log("Like created successfully");
      const tpEnvVar = `LIKE_ID=${createdNft.objectId}\n`;
      console.log(tpEnvVar);
    }
  } else {
    console.log("Tx Failed. Error "+JSON.stringify(res.effects?.status));
  }
};

run();
