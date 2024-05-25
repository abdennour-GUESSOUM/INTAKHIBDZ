const fs = require('fs');
const path = require('path');
const President = artifacts.require("President");

module.exports = function(deployer) {
  const filePath = path.join(__dirname, 'president_candidates.json');
  const rawData = fs.readFileSync(filePath);
  const data = JSON.parse(rawData);

  const candidates = data.candidates.map(candidate => candidate.address);
  const firstNames = data.candidates.map(candidate => candidate.firstName);
  const lastNames = data.candidates.map(candidate => candidate.lastName);
  const imageUrls = data.candidates.map(candidate => candidate.imageUrl);
  const genders = data.candidates.map(candidate => candidate.gender);
  const jobPositions = data.candidates.map(candidate => candidate.jobPosition);
  const electoralDistricts = data.candidates.map(candidate => candidate.electoralDistrict);
  const politicalAffiliations = data.candidates.map(candidate => candidate.politicalAffiliation);
  const ages = data.candidates.map(candidate => candidate.age);

  const escrow = data.escrow;
  const duration = data.duration;

  deployer.deploy(President, candidates, escrow, duration, firstNames, lastNames, imageUrls, genders, jobPositions, electoralDistricts, politicalAffiliations, ages);
};
