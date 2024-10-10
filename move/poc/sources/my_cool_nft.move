module tto_test::coolnft;

use std::string::{String};


public struct TeoCoolNFT has key {
    id: UID,
    name: String
}


public struct Like has key, store {
    id: UID,
    liker:address
}

public struct Contest has key {
    id: UID,
}


fun init(ctx: &mut TxContext) {
    let contest = Contest{
        id: object::new(ctx),
    };
    transfer::share_object(contest);
}



public fun mint_nft(name: String, ctx: &mut TxContext) {
    transfer::transfer(TeoCoolNFT{
        id: object::new(ctx),
        name: name
    }, ctx.sender());
}


public fun like_NFT(nftId: address, ctx:&mut TxContext) {
    let myLike = Like{
        id: object::new(ctx),
        liker: ctx.sender()
    };
    transfer::public_transfer(myLike, nftId);
}
