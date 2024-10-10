
import {
  NFT_ID,
  suiClient,
} from "./helpers/config";

const run = async () => {

  suiClient.getOwnedObjects({
    owner: NFT_ID,
    options: {
      showDisplay: true,
      showContent: true,
      showType: true,
    }

  }
  ).then((res) => {
    console.log("Likes for this NFT");
    for(let i = 0; i < res.data.length; i++) {
      const obj = res.data[i].data;
      if(obj && obj?.type?.endsWith("::coolnft::Like")){
        console.log("Like ID ", obj?.objectId);
      }
    }
  });
};

run();
