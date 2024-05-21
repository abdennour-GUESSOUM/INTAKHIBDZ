var Deputies = artifacts.require("Deputies");


module.exports = function(deployer) {
  const groupNames = ["FLN", "RND", "MSP"];
  const groupPictures = [
    "https://white-high-quokka-246.mypinata.cloud/ipfs/QmTT67kkk4F4KWbHojGH7zM7qTuv8tpWhAgeviyLG4UhW3",
    "https://white-high-quokka-246.mypinata.cloud/ipfs/QmQ6LtHJhCiwvkrtd22Tx9FNnYufsztxEfT1RCrk9vSS2f",
    "https://white-high-quokka-246.mypinata.cloud/ipfs/QmQ6LtHJhCiwvkrtd22Tx9FNnYufsztxEfT1RCrk9vSS2f",
  ];
  const groupAddresses = [
    "0xB9823fDaFFA161642F3DDbAB7aec6f4d8446c3dF",
    "0xcEd68506aa814BD6f31026F2052a70b868934B46",
    "0x828Da9fc4EEa60646356E4bD79264Ee936dBF98a"
  ];
  const escrow = "0xc60A10b0cA12AC42116b8C76d177a3267C748fBB";
  const duration = 500;

  deployer.deploy(Deputies, escrow, duration, groupNames, groupPictures, groupAddresses).then(async (instance) => {
    const candidates = [
      {
        address: "0xCA10107f11C0C7A46A461f799F741AEDdaad64A6",
        firstName: "Guessoum",
        lastName: "Abdennour",
        imageUrl: "https://gateway.pinata.cloud/ipfs/QmX6zGVETnu7SKdy6GahWV3bSFBZjTB2RG1MCJmBYrky8S",
        groupAddress: "0xB9823fDaFFA161642F3DDbAB7aec6f4d8446c3dF"
      },
      {
        address: "0xb71645E9752fB726a082FE3899e39962e2933795",
        firstName: "Lesbat",
        lastName: "Haithem",
        imageUrl: "https://gateway.pinata.cloud/ipfs/QmVJu6zhRBHNHNeC8ZVmXFBUxKcRkPfKRhxNhoRNdVH1c9",
        groupAddress: "0xB9823fDaFFA161642F3DDbAB7aec6f4d8446c3dF"
      },
      {
              address: "0x791f85aB7B725380370949c1576a19B47EfB32C3",
              firstName: "Boudraa",
              lastName: "Soufiane",
              imageUrl: "https://white-high-quokka-246.mypinata.cloud/ipfs/QmNuiSq99N1UrAiPoAqWpmzuqXfVdbKxgrpqJXBSF89L4r",
              groupAddress: "0xcEd68506aa814BD6f31026F2052a70b868934B46"
            },
      {
        address: "0x8EC3744B8f12DaedCCD809CE0c847188928D9b4f",
        firstName: "Daoud",
        lastName: "Yasser",
        imageUrl: "https://gateway.pinata.cloud/ipfs/QmUMr4z2HyymMxJL4PvzXTJ87uePTT3LKDHdTntiPktAMM",
        groupAddress: "0x828Da9fc4EEa60646356E4bD79264Ee936dBF98a"
      }
    ];

    for (let i = 0; i < candidates.length; i++) {
      const candidate = candidates[i];
      await instance.addCandidateToGroup(
        candidate.groupAddress,
        candidate.address,
        candidate.firstName,
        candidate.lastName,
        candidate.imageUrl
      );
    }
  }).catch((error) => {
    console.error(error);
  });
};
