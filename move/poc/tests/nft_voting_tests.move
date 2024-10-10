module tto_test::nft_voting_tests;

use sui::test_scenario::{Self as ts};
use std::string::{Self};
use tto_test::coolnft::{Self as nft, 
    Contest, 
    mint_nft_for_testing, 
    like_NFT,
    count_likes,
    init_for_testing,
    delete_nft_for_testing
};


#[test]
fun test_vote() {
    let mut ts = ts::begin(@admin);
    init_for_testing(ts.ctx());

    ts.next_tx(@alice);

    let coolNFT = mint_nft_for_testing(string::utf8(b"Sui NFT"), ts.ctx());

    ts.next_tx(@bob);

    let mut contest = ts.take_shared<Contest>();
    let nft_id = object::id_address(&coolNFT);
    like_NFT(nft_id, &mut contest, ts.ctx());
    let likes = count_likes(nft_id, &contest);

    //Assert that the NFT has actually only 1 Like
    assert!(likes == 1, 111);


    //Liking again, now from a different user
    ts.next_tx(@admin);

    let nft_id = object::id_address(&coolNFT);
    like_NFT(nft_id, &mut contest, ts.ctx());
    let likes = count_likes(nft_id, &contest);

    //Assert that the NFT has actually only 2 Likes
    assert!(likes == 2, 111);

    ts::return_shared(contest);
    delete_nft_for_testing(coolNFT);
    ts.end();
}


#[test]
#[expected_failure(abort_code = nft::EAlreadyLikedThisNFT)]
fun test_double_vote() {
    let mut ts = ts::begin(@admin);

    init_for_testing(ts.ctx());

    ts.next_tx(@alice);

    let coolNFT = mint_nft_for_testing(string::utf8(b"Sui NFT"), ts.ctx());


    ts.next_tx(@bob);
    let mut contest = ts.take_shared<Contest>();


    let nft_id = object::id_address(&coolNFT);

    nft::like_NFT(nft_id, &mut contest, ts.ctx());
    nft::like_NFT(nft_id, &mut contest, ts.ctx());

    ts::return_shared(contest);

    delete_nft_for_testing(coolNFT);
    ts.end();
}