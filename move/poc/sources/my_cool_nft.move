module tto_test::coolnft;

use std::string::{String};
use sui::table::{Self, Table};

//Errors
const EAlreadyLikedThisNFT : u64 = 0;


//Structs

public struct TeoCoolNFT has key {
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


//Business Functions


fun init(ctx: &mut TxContext) {
    let contest = Contest{
        id: object::new(ctx),
        voters: table::new(ctx),
        reporters: table::new(ctx),
        votesPerNFT: table::new(ctx),
        reportsPerNFT: table::new(ctx),
    };
    transfer::share_object(contest);
}


public fun mint_nft(name: String, ctx: &mut TxContext) {
    transfer::transfer(TeoCoolNFT{
        id: object::new(ctx),
        name: name
    }, ctx.sender());
}


public fun like_NFT(nftId: address, contest: &mut Contest, ctx:&mut TxContext) {
    let myLike = Like{
        id: object::new(ctx),
        liker: ctx.sender()
    };

    let votingKey = VotingKey{
        liker: ctx.sender(),
        nftId: nftId
    };

    assert!(!contest.voters.contains(votingKey),  EAlreadyLikedThisNFT);

    table::add(&mut contest.voters, votingKey, 1);

    if(contest.votesPerNFT.contains(nftId)){
        let mut likes = *table::borrow_mut(&mut contest.votesPerNFT, nftId);
        likes = likes + 1;
        table::remove(&mut contest.votesPerNFT, nftId);
        table::add(&mut contest.votesPerNFT, nftId, likes);
    }else{
        table::add(&mut contest.votesPerNFT, nftId, 1);
    };

    transfer::public_transfer(myLike, nftId);
}


public fun count_likes(nftId: address, contest: &Contest): u64 {
    *table::borrow(&contest.votesPerNFT, nftId)

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
public fun mint_nft_for_testing(name: String, ctx: &mut TxContext) : TeoCoolNFT {
    TeoCoolNFT{
        id: object::new(ctx),
        name: name
    }
}

#[test_only]
public fun delete_nft_for_testing(nft : TeoCoolNFT){
    let TeoCoolNFT{id, name: _} = nft;
    id.delete();
}
