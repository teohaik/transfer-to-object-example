import { config } from "dotenv";
import { SuiClient } from "@mysten/sui/client";
import {KioskClient, Network} from "@mysten/kiosk";

config({});
export const SUI_NETWORK = process.env.SUI_NETWORK!;
export const ADMIN_ADDRESS = process.env.ADMIN_ADDRESS!;
export const USER_ADDRESS = process.env.ADMIN_ADDRESS!;
export const ADMIN_SECRET_KEY = process.env.ADMIN_SECRET_KEY!;
export const USER_SECRET_KEY = process.env.USER_SECRET_KEY!;
export const NFT_ID = process.env.NFT_ID!;
export const PUBLISHER_ID = process.env.PUBLISHER_ID!;


export const PACKAGE_ID = process.env.PACKAGE_ADDRESS;

export const KIOSK_ID = process.env.KIOSK_ID;
export const TRANSFER_POLICY_ID = process.env.TRANSFER_POLICY_ID;

export const NFT_TYPE = `${PACKAGE_ID}::coolnft::TeoCoolNFT`;
export const NFT_EXT_TYPE = `${PACKAGE_ID}::coolnftext::TeoCoolNFT`;


// console.log everything in the process.env object
const keys = Object.keys(process.env);
console.log("env contains ADMIN_ADDRESS:", keys.includes("ADMIN_ADDRESS"));
console.log("env contains ADMIN_SECRET_KEY:", keys.includes("ADMIN_SECRET_KEY"));
console.log("env contains PACKAGE_ADDRESS:", keys.includes("PACKAGE_ADDRESS"));
console.log("env contains PUBLISHER_ID:", keys.includes("PUBLISHER_ID"));


export const suiClient = new SuiClient({
    url: SUI_NETWORK,
  });

export const kioskClient = new KioskClient({
    client: suiClient,
    network: SUI_NETWORK.includes("mainnet") ? Network.MAINNET : Network.TESTNET
});