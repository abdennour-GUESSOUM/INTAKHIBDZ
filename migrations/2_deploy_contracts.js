var President = artifacts.require("President");
module.exports = function(deployer) {
  const candidates = [
    "0x2d35370874f078D00fE22f6202be9000070E8782",
    "0x8EC3744B8f12DaedCCD809CE0c847188928D9b4f",
    "0x791f85aB7B725380370949c1576a19B47EfB32C3"
  ];
  const escrow = "0xb71645E9752fB726a082FE3899e39962e2933795";
  const duration = 500; // Duration in seconds (3 minutes)
  const firstNames = ["Guessoum", "Lesbat", "Daoud"];
  const lastNames = ["Abdennour", "Haithem", "Yasser"];
  const imageUrls = [
    "https://gateway.pinata.cloud/ipfs/QmX6zGVETnu7SKdy6GahWV3bSFBZjTB2RG1MCJmBYrky8S",
    "https://gateway.pinata.cloud/ipfs/QmVJu6zhRBHNHNeC8ZVmXFBUxKcRkPfKRhxNhoRNdVH1c9",
    "https://gateway.pinata.cloud/ipfs/QmUMr4z2HyymMxJL4PvzXTJ87uePTT3LKDHdTntiPktAMM"
  ];

  deployer.deploy(President, candidates, escrow, duration, firstNames, lastNames, imageUrls);
};


