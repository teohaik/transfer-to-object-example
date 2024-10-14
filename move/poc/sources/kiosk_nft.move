module tto_test::coolnftext;

use std::string::{String};
use sui::table::{Self, Table};
use sui::bag::{Self,Bag};
use sui::package::{Self};

use sui::kiosk_extension as ext;
use sui::kiosk::{Kiosk, KioskOwnerCap};
use sui::transfer_policy::{TransferPolicy};

//Errors
const ENotEnoughPermissions: u64 = 0;

/// The expected set of permissions for extension. It requires `place`.
const PERMISSIONS: u128 = 1;

/// The Witness struct used to identify and authorize the extension.
public struct CoolNftExtension has drop {}

//Structs

public struct TeoCoolNFT has key , store {
    id: UID,
    name: String
}

//  A key to store the likes of a user for a specific NFT. 
// This ensure that a user can like an NFT only once.
public struct VotingKey has copy, store, drop {
    liker:address,
    nftId:address
}

public struct Like has key, store {
    id: UID,
    liker:address
}

public struct Contest has key {
    id: UID,
    voters: Table<VotingKey, u64>,
    reporters: Table<VotingKey, u64>,
    votesPerNFT: Table<address, u64>,
    reportsPerNFT: Table<address, u64>
}


public struct COOLNFTEXT has drop {}


//Business Functions

fun init(otw: COOLNFTEXT, ctx: &mut TxContext) {
    package::claim_and_keep(otw, ctx);
    let contest = Contest{
        id: object::new(ctx),
        voters: table::new(ctx),
        reporters: table::new(ctx),
        votesPerNFT: table::new(ctx),
        reportsPerNFT: table::new(ctx),
    };
    transfer::share_object(contest);
}


/// Install the extension into the Kiosk.
public fun install(kiosk: &mut Kiosk, cap: &KioskOwnerCap, ctx: &mut TxContext) {
    ext::add(CoolNftExtension {}, kiosk, cap, PERMISSIONS, ctx)
}

/// Place a letter into the kiosk without the `KioskOwnerCap`.
public fun place(kiosk: &mut Kiosk, nft: TeoCoolNFT, policy: &TransferPolicy<TeoCoolNFT>) {
    assert!(ext::can_place<CoolNftExtension>(kiosk), ENotEnoughPermissions);

    ext::place(CoolNftExtension {}, kiosk, nft, policy)
}

public fun mint_and_place_nft(name: String, kiosk: &mut Kiosk, policy: &TransferPolicy<TeoCoolNFT>, ctx: &mut TxContext)  {
    let nft = mint_nft(name, ctx);
    place(kiosk, nft, policy)
}

public fun mint_nft(name: String, ctx: &mut TxContext) : TeoCoolNFT {
    TeoCoolNFT{
        id: object::new(ctx),
        name: name
    }
}


public fun vote_NFT(nftId: ID, kiosk: &mut Kiosk) {

    let storageBag: &mut Bag = ext::storage_mut(CoolNftExtension {}, kiosk);

    if(storageBag.contains(nftId)){
        let mut votesForThisNFT = bag::remove<ID, u64>(storageBag, nftId);
        votesForThisNFT = votesForThisNFT + 1;
        storageBag.add(nftId, votesForThisNFT);
    }else{
        storageBag.add(nftId, 1);
    };
}

public fun count_votes(nftId: ID,  kiosk: &mut Kiosk): u64 {
    let storageBag: &mut Bag = ext::storage_mut(CoolNftExtension {}, kiosk);
    *bag::borrow<ID, u64>(storageBag, nftId)
}


#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    let contest = Contest{
        id: object::new(ctx),
        voters: table::new(ctx),
        reporters: table::new(ctx),
        votesPerNFT: table::new(ctx),
        reportsPerNFT: table::new(ctx),
    };
    transfer::share_object(contest);
}

#[test_only]
public fun mint_nft_for_testing(name: String, ctx: &mut TxContext) : (TeoCoolNFT, ID) {
    let uid = object::new(ctx);
    let id = uid.to_inner();
    (TeoCoolNFT{
        id: uid,
        name: name
    }, id)
}

#[test_only]
public fun delete_nft_for_testing(nft : TeoCoolNFT){
    let TeoCoolNFT{id, name: _} = nft;
    id.delete();
}
