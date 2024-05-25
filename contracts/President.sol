// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract President {

    struct Conditions {
        uint256 deadline;
        uint32 envelopes_casted;
        uint32 envelopes_opened;
        bool open;
        bool valid_results;
    }

    struct Candidate {
        uint32 votes;
        string firstName;
        string lastName;
        string imageUrl;
        string gender;
        string jobPosition;
        string electoralDistrict;
        string politicalAffiliation;
        uint32 age;  // Added age property
    }

    event NewPresident(address indexed _candidate);
    event InvalidElections(address indexed _escrow);
    event EnvelopeCast(address indexed _voter);
    event EnvelopeOpen(address indexed _voter, address indexed _sign);
    event EnvelopeWithdrawn(address indexed _voter);

    modifier canVote() {
        require(block.timestamp <= voting_condition.deadline, "Voting period has ended");
        require(!hasConfirmed[msg.sender], "You have already confirmed your vote");
        require(envelopes[msg.sender] == 0x0, "You have already cast your vote");
        _;
    }

    modifier canConfirm() {
        require(block.timestamp <= voting_condition.deadline, "Voting period has ended");
        require(envelopes[msg.sender] != 0x0, "You have not cast any votes");
        require(!envelopeOpened[msg.sender], "Envelope has already been confirmed");
        require(!hasConfirmed[msg.sender], "You have already confirmed your vote");
        _;
    }

    modifier canCheckOutcome() {
        require(block.timestamp > voting_condition.deadline, "Cannot check the winner before the deadline");
        require(voting_condition.open != false, "The elections have already been declared");
        _;
    }

    modifier canGetResults() {
        require(!voting_condition.open, "The elections have not been declared yet");
        require(voting_condition.valid_results == true, "The elections are invalid");
        _;
    }

    address[] public candidate;
    address payable public escrow;

    mapping(address => bytes32) envelopes;
    Conditions voting_condition;
    mapping(address => bool) public envelopeOpened;
    mapping(address => bool) public hasConfirmed;
    mapping(address => Candidate) candidates;
    address[] voters;

    constructor(
        address[] memory _candidates,
        address payable _escrow,
        uint256 _duration,
        string[] memory _firstNames,
        string[] memory _lastNames,
        string[] memory _imageUrls,
        string[] memory _genders,
        string[] memory _jobPositions,
        string[] memory _electoralDistricts,
        string[] memory _politicalAffiliations,
        uint32[] memory _ages  // Added ages parameter
    ) {
        require(
            _candidates.length == _firstNames.length &&
            _candidates.length == _lastNames.length &&
            _candidates.length == _imageUrls.length &&
            _candidates.length == _genders.length &&
            _candidates.length == _jobPositions.length &&
            _candidates.length == _electoralDistricts.length &&
            _candidates.length == _politicalAffiliations.length &&
            _candidates.length == _ages.length,  // Added age length check
            "Mismatched input arrays"
        );

        for (uint i = 0; i < _candidates.length; i++) {
            address key = _candidates[i];
            candidate.push(key);
            candidates[key] = Candidate({
                votes: 0,
                firstName: _firstNames[i],
                lastName: _lastNames[i],
                imageUrl: _imageUrls[i],
                gender: _genders[i],
                jobPosition: _jobPositions[i],
                electoralDistrict: _electoralDistricts[i],
                politicalAffiliation: _politicalAffiliations[i],
                age: _ages[i]  // Set age
            });
        }

        escrow = _escrow;
        voting_condition = Conditions({
            envelopes_casted: 0,
            envelopes_opened: 0,
            open: true,
            valid_results: true,
            deadline: block.timestamp + _duration
        });
    }

    function cast_envelope(bytes32 _envelope) public canVote {
        if (envelopes[msg.sender] == 0x0) {
            voting_condition.envelopes_casted++;
        }
        envelopes[msg.sender] = _envelope;
        emit EnvelopeCast(msg.sender);
    }

    function confirm_envelope(uint _sigil, address _sign) public canConfirm {
        bytes32 _casted_envelope = envelopes[msg.sender];
        bytes32 _sent_envelope = compute_envelope(_sigil, _sign);

        require(_casted_envelope == _sent_envelope, "Sent envelope does not correspond to the one cast");

        envelopeOpened[msg.sender] = true;
        hasConfirmed[msg.sender] = true;
        candidates[_sign].votes += 1;
        voting_condition.envelopes_opened++;
        voters.push(msg.sender);

        emit EnvelopeOpen(msg.sender, _sign);
    }

    function valid_candidate_check() canCheckOutcome public {
        voting_condition.open = false;

        address elected = address(0);
        uint maxVotes = 0;
        bool invalid = false;

        for (uint i=0; i<candidate.length; i++){
            Candidate memory cnd = candidates[candidate[i]];

            if (cnd.votes > maxVotes){
                elected = candidate[i];
                maxVotes = cnd.votes;
                invalid = false;
            } else if (cnd.votes == maxVotes){
                invalid = true;
            }
        }

        if (invalid) {
            voting_condition.valid_results = false;
            emit InvalidElections(escrow);
        } else {
            emit NewPresident(elected);
        }
    }

    function auto_declare_results() public canCheckOutcome {
        // Automatically declare results after the deadline
        if (voting_condition.open) {
            valid_candidate_check();
        }
    }

    function get_status(address addr) public view returns (uint32, uint32, bool, bool, bool) {
        return (
            voting_condition.envelopes_casted,
            voting_condition.envelopes_opened,
            envelopes[addr] != 0x0,
            voting_condition.open,
            is_candidate(addr)
        );
    }

    function get_candidate_names() public view returns (
        address[] memory addresses,
        string[] memory firstNames,
        string[] memory lastNames,
        string[] memory imageUrls,
        string[] memory genders,
        string[] memory jobPositions,
        string[] memory electoralDistricts,
        string[] memory politicalAffiliations,
        uint32[] memory ages  // Added ages to return values
    ) {
        addresses = new address[](candidate.length);
        firstNames = new string[](candidate.length);
        lastNames = new string[](candidate.length);
        imageUrls = new string[](candidate.length);
        genders = new string[](candidate.length);
        jobPositions = new string[](candidate.length);
        electoralDistricts = new string[](candidate.length);
        politicalAffiliations = new string[](candidate.length);
        ages = new uint32[](candidate.length);  // Initialized ages array

        for (uint i = 0; i < candidate.length; i++) {
            addresses[i] = candidate[i];
            firstNames[i] = candidates[candidate[i]].firstName;
            lastNames[i] = candidates[candidate[i]].lastName;
            imageUrls[i] = candidates[candidate[i]].imageUrl;
            genders[i] = candidates[candidate[i]].gender;
            jobPositions[i] = candidates[candidate[i]].jobPosition;
            electoralDistricts[i] = candidates[candidate[i]].electoralDistrict;
            politicalAffiliations[i] = candidates[candidate[i]].politicalAffiliation;
            ages[i] = candidates[candidate[i]].age;  // Set age
        }

        return (addresses, firstNames, lastNames, imageUrls, genders, jobPositions, electoralDistricts, politicalAffiliations, ages);
    }

    function get_results() public view canGetResults returns (
        address[] memory, uint[] memory, string[] memory firstNames, string[] memory lastNames, string[] memory imageUrls, string[] memory genders, string[] memory jobPositions, string[] memory electoralDistricts, string[] memory politicalAffiliations, uint32[] memory ages  // Added ages to return values
    ) {
        uint[] memory all_votes = new uint[](candidate.length);
        firstNames = new string[](candidate.length);
        lastNames = new string[](candidate.length);
        imageUrls = new string[](candidate.length);
        genders = new string[](candidate.length);
        jobPositions = new string[](candidate.length);
        electoralDistricts = new string[](candidate.length);
        politicalAffiliations = new string[](candidate.length);
        ages = new uint32[](candidate.length);  // Initialized ages array

        for (uint i = 0; i < candidate.length; i++) {
            all_votes[i] = candidates[candidate[i]].votes;
            firstNames[i] = candidates[candidate[i]].firstName;
            lastNames[i] = candidates[candidate[i]].lastName;
            imageUrls[i] = candidates[candidate[i]].imageUrl;
            genders[i] = candidates[candidate[i]].gender;
            jobPositions[i] = candidates[candidate[i]].jobPosition;
            electoralDistricts[i] = candidates[candidate[i]].electoralDistrict;
            politicalAffiliations[i] = candidates[candidate[i]].politicalAffiliation;
            ages[i] = candidates[candidate[i]].age;  // Set age
        }

        return (candidate, all_votes, firstNames, lastNames, imageUrls, genders, jobPositions, electoralDistricts, politicalAffiliations, ages);
    }

    function compute_envelope(uint _sigil, address _sign) private pure returns (bytes32) {
        return keccak256(abi.encode(_sigil, _sign));
    }

    function is_candidate(address addr) private view returns (bool) {
        for (uint i = 0; i < candidate.length; i++) {
            if (addr == candidate[i]) {
                return true;
            }
        }
        return false;
    }

    function get_deadline() public view returns (uint256) {
        return voting_condition.deadline;
    }

    function get_vote_count() public view returns (uint256) {
        return voters.length;
    }
}
