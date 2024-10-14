module tto_test::kiosk_nft_voting_tests;

use sui::test_scenario::{Self as ts};
use std::string::{Self};
use sui::package::{Self};

use sui::transfer_policy::{Self as policy, TransferPolicy, TransferPolicyCap};

use sui::kiosk_test_utils::{Self as test};


public struct OTW has drop {}

use tto_test::coolnftext::{
    mint_nft_for_testing, 
    place,
    install,
    delete_nft_for_testing,
    TeoCoolNFT
};


#[test]
fun test_mint_place() {
    let mut ts = ts::begin(@admin);

    let (mut kiosk, owner_cap) = test::get_kiosk(ts.ctx());
    let (policy, policy_cap) = prepare(ts.ctx());

    install(&mut kiosk, &owner_cap, ts.ctx());
    ts.next_tx(@alice);

    let (coolNFT, nftID) = mint_nft_for_testing(string::utf8(b"Sui NFT"), ts.ctx());

    place(&mut kiosk, coolNFT, &policy);

    assert!(kiosk.has_item(nftID));

    let asset : TeoCoolNFT = kiosk.take<TeoCoolNFT>(&owner_cap, nftID);
    assert!(!kiosk.has_item(nftID));


    wrapup(policy, policy_cap, ts.ctx());
    let profits = kiosk.close_and_withdraw(owner_cap, ts.ctx());
    profits.burn_for_testing();
    delete_nft_for_testing(asset);
    ts.end();
}


public fun prepare(ctx: &mut TxContext): (TransferPolicy<TeoCoolNFT>, TransferPolicyCap<TeoCoolNFT>) {
    let publisher = package::test_claim(OTW {}, ctx);
    let (policy, cap) = policy::new<TeoCoolNFT>(&publisher, ctx);
    publisher.burn_publisher();
    (policy, cap)
}

public fun wrapup(policy: TransferPolicy<TeoCoolNFT>, cap: TransferPolicyCap<TeoCoolNFT>, ctx: &mut TxContext): u64 {
    let profits = policy.destroy_and_withdraw(cap, ctx);
    profits.burn_for_testing()
}
