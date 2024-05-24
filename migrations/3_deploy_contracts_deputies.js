var Deputies = artifacts.require("Deputies");


module.exports = function(deployer) {
  const groupNames = ["Front de Libération Nationale (FLN)", "Rassemblement National Démocratique (RND)", "Mouvement de la Société pour la Paix (MSP)"];
  const groupPictures = [
    "https://white-high-quokka-246.mypinata.cloud/ipfs/QmQ6LtHJhCiwvkrtd22Tx9FNnYufsztxEfT1RCrk9vSS2f",
    "https://white-high-quokka-246.mypinata.cloud/ipfs/QmTT67kkk4F4KWbHojGH7zM7qTuv8tpWhAgeviyLG4UhW3",
    "https://white-high-quokka-246.mypinata.cloud/ipfs/QmQ6LtHJhCiwvkrtd22Tx9FNnYufsztxEfT1RCrk9vSS2f",
  ];
  const groupAddresses = [
    "0x172DD14CE59eff5a812f0ceeCD8ff517524b85B5",
    "0x5CcE2B9B8ec42DA09A981efFD41c07f6Ea6c746d",
    "0x20ee5B08a56aAA9Df01B5BE9F7F55d4ed286F3f1",
  ];
  const escrow = "0xb464b12c9AdE127a17d96012BE4e3bc3eC220857";
  const duration = 1800;

  deployer.deploy(Deputies, escrow, duration, groupNames, groupPictures, groupAddresses).then(async (instance) => {
    const candidates = [
      {
        address: "0xBDC3BA9DB079773a8d11e592C9d98C4037f53cff",
        firstName: "Benyakoub",
        lastName: "Abdelaziz",
        imageUrl: "https://gateway.pinata.cloud/ipfs/QmPY9P4AHXawJ9cMZmrSCJnbAwcKQYFuraF6h27RxPBfjR",
        groupAddress: "0x172DD14CE59eff5a812f0ceeCD8ff517524b85B5"
      },
      {
        address: "0xdFa64e3a03910188836A45E27906489F53541E70",
        firstName: "Bouzelat",
        lastName: "Tarek",
        imageUrl: "https://gateway.pinata.cloud/ipfs/QmTaiB83PWnVjwr6tPegq3wQBvMBS9imUnnHyayB14C4zs",
        groupAddress: "0x5CcE2B9B8ec42DA09A981efFD41c07f6Ea6c746d"
      },
      {
              address: "0x6a4e533466D395EC291dfE027511F337FF26E0F0",
              firstName: "Douga",
              lastName: "Hamida",
        imageUrl: "https://gateway.pinata.cloud/ipfs/QmcGiUfCnC54XwmyFGF6z1Y4g7hHSex7xPCYgsy5HkHpdm",
              groupAddress: "0x172DD14CE59eff5a812f0ceeCD8ff517524b85B5"
            },
      {
        address: "0x5CcE2B9B8ec42DA09A981efFD41c07f6Ea6c746d",
        firstName: "Chelghoum",
        lastName: "Wassim",
        imageUrl: "https://gateway.pinata.cloud/ipfs/QmYyUKQ5QvunSxdnJ8sHbbqajzpVxZMiDSwPWf25f94UKS",
        groupAddress: "0x20ee5B08a56aAA9Df01B5BE9F7F55d4ed286F3f1"
      },
      {
              address: "0x8C030fF34e95E85f0A11B284921415f8f06B8983",
              firstName: "Hamdi",
              lastName: "Oussama",
              imageUrl: "https://gateway.pinata.cloud/ipfs/QmeCwxntzQbvBctywpjWNyShSgA7WmgtK9mwwMbYi4qNcr",
              groupAddress: "0x20ee5B08a56aAA9Df01B5BE9F7F55d4ed286F3f1"
            },
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
