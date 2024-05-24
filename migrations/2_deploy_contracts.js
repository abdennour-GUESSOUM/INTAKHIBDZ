var President = artifacts.require("President");
module.exports = function(deployer) {
  const candidates = [
    "0x1Cd056Cac37130b26cD517528b4d12308EfBDB98",
    "0x01E88CDbCF874377d31449EB759651665a2c0cf8",
    "0x40424eD954c75fB4Ac529Acfb0ab34397FE35905",
    "0x9dfA729Dcdf8Bf4B3895eEFE58A8efdA2c79d529",
    "0xAb1E1A2fB55b172A0f47E55fb0996B9ACB6bC2F7",
  ];
  const escrow = "0x6633C662ed5ef9ACf6f4D8f38dA263467C31360e";
  const duration = 1800; // Duration in seconds (3 minutes)
  const firstNames = ["Guessoum", "Lesbat", "Daoud", "Bourougua", "Toumi"];
  const lastNames = ["Abdennour", "Haithem", "Yasser", "Anis", "Hassina"];
  const imageUrls = [
    "https://gateway.pinata.cloud/ipfs/QmTQUaLfG1HhdMzE1NiYzsNzd2tNR715qmG7CV3SuP5vrc",
    "https://gateway.pinata.cloud/ipfs/QmWj2QXJPPvzC7THHq2L6AjbA5XxA2ZvmiauvfLBk8T1xk",
    "https://gateway.pinata.cloud/ipfs/QmWYHMbn1TyXK6psjzHCkwKcyUsfF7URYzn7uTF6ZmsmNG",
    "https://gateway.pinata.cloud/ipfs/QmUVninMPzYo9fs3v45XadwE3biu591Dej4WhvxGnjmMLq",
    "https://gateway.pinata.cloud/ipfs/QmcKpMSai13rpr6fiM9tkNLbg8C9uWgCJfjSiT2SHq2sp5",
  ];

  deployer.deploy(President, candidates, escrow, duration, firstNames, lastNames, imageUrls);
};


