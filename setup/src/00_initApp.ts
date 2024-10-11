import {Transaction} from "@mysten/sui/transactions";

import {
    kioskClient,
    NFT_EXT_TYPE, PACKAGE_ID,
    PUBLISHER_ID,
    suiClient,
} from "./helpers/config";
import {getAdminSignerKeypair} from "./helpers/getSigner";
import {KioskTransaction, Network, TransferPolicyTransaction} from "@mysten/kiosk";
import fs from "fs";

const run = async () => {
    const tx = new Transaction();

    const adminAddress = getAdminSignerKeypair().toSuiAddress();


    let objectDisplay = tx.moveCall({
        target: `0x2::display::new_with_fields`,
        arguments: [
            tx.object(PUBLISHER_ID),
            tx.pure.vector("string",["name", "image_url"]),
            tx.pure.vector("string",   ["{name}", "https://storage.googleapis.com/gsw_nft/android-apple-sq.jpg"]),
        ],
        typeArguments: [NFT_EXT_TYPE],
    });

    tx.moveCall({
        target: `0x2::display::update_version`,
        arguments: [objectDisplay],
        typeArguments: [NFT_EXT_TYPE],
    });

    tx.transferObjects(
        [objectDisplay],
        tx.pure.address(adminAddress)
    );

    ////// Transfer Policy Initialization

    const tpTx = new TransferPolicyTransaction({
        kioskClient,
        transaction: tx,
    });

    await tpTx.create({
        type: NFT_EXT_TYPE,
        publisher: PUBLISHER_ID,
    });

    tx.transferObjects([tx.object(tpTx.getPolicyCap())], adminAddress);
    tx.transferObjects([tx.object(tpTx.getPolicy())], adminAddress);

    /////// Kiosk Initialization

    const kioskTx = new KioskTransaction(
        {
            transaction: tx,
            kioskClient
        });

    kioskTx.create();

    tx.moveCall({
        target: `${PACKAGE_ID}::coolnftext::install`,
        arguments: [kioskTx.getKiosk(), kioskTx.getKioskCap()],
    });

    kioskTx.shareAndTransferCap(adminAddress);

    kioskTx.finalize();

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

        console.log("Init TX ran successfully | Digest: " + res.digest);

        let kioskId = "";
        let kioskCapId = "";
        let tranferPolicyId = "";
        let tranferPolicyCapId = "";

        res?.objectChanges?.find((obj) => {
            if (obj.type === "created" && obj.objectType.startsWith("0x2::transfer_policy::TransferPolicy<")) {
                tranferPolicyId = obj.objectId;
                return true;
            }
        });
        res?.objectChanges?.find((obj) => {
            if (obj.type === "created" && obj.objectType.startsWith("0x2::transfer_policy::TransferPolicyCap<")) {
                tranferPolicyCapId = obj.objectId;
                return true;
            }
        });
        res?.objectChanges?.find((obj) => {
            if (obj.type === "created" && obj.objectType.endsWith("kiosk::Kiosk")) {
                kioskId = obj.objectId;
                return true;
            }
        });
        res?.objectChanges?.find((obj) => {
            if (obj.type === "created" && obj.objectType.startsWith("0x2::kiosk::KioskOwnerCap")) {
                kioskCapId = obj.objectId;
                return true;
            }
        });

        const tpEnvVar = `\nTRANSFER_POLICY_ID=${tranferPolicyId}\n`;
        console.log(tpEnvVar);
        fs.appendFileSync("./.env", tpEnvVar);

        const tpCapEnvVar = `\nTRANSFER_POLICY_CAP_ID=${tranferPolicyCapId}\n`;
        console.log(tpCapEnvVar);
        fs.appendFileSync("./.env", tpCapEnvVar);

        const kioskVar = `\nKIOSK_ID=${kioskId}\n`;
        console.log(kioskVar);
        fs.appendFileSync("./.env", kioskVar);

        const kioskCapVar = `\nKIOSK_CAP_ID=${kioskCapId}\n`;
        console.log(kioskCapVar);
        fs.appendFileSync("./.env", kioskCapVar);


    } else {
        console.log("Tx Failed. Error " + JSON.stringify(res.effects?.status));
    }
};

run();
