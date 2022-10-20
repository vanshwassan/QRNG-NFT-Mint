//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract API3QRNG is ERC721, RrpRequesterV0, Ownable {
    struct Character {
        uint256 strength;
        uint256 intelligence;
        uint256 mana;
        uint256 experience;
        string name;
    }

    Character[] public characters;

    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;

    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    mapping(bytes32 => string) public requestToCharacterName;
    mapping(bytes32 => address) public requestToSender;
    mapping(bytes32 => uint256) public requestToTokenId;

    constructor(address _airnodeRrp) RrpRequesterV0(_airnodeRrp) ERC721("DungeonsAndDragonsCharacter", "D&D") {}

    function setRequestParameters(
        address _airnode,
        bytes32 _endpointIdUint256,
        address _sponsorWallet
    ) external {
        airnode = _airnode;
        endpointIdUint256 = _endpointIdUint256;
        sponsorWallet = _sponsorWallet;
    }

    function requestNewRandomCharacter(string memory name) public returns (bytes32) {
        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointIdUint256,
            address(this),
            sponsorWallet,
            address(this),
            this.fulfillRandomness.selector,
            ""
        );
        expectingRequestWithIdToBeFulfilled[requestId] = true;
        requestToCharacterName[requestId] = name;
        requestToSender[requestId] = msg.sender;
        return requestId;
    }

    function fulfillRandomness(bytes32 requestId, bytes calldata data)
        public
    {
        require(
            expectingRequestWithIdToBeFulfilled[requestId],
            "Request ID not known"
        );
        expectingRequestWithIdToBeFulfilled[requestId] = false;
        uint256 qrngUint256 = abi.decode(data, (uint256));
        
        uint256 newId = characters.length;
        uint256 strength = ((qrngUint256 % 100000000) / 100);
        uint256 intelligence = ((qrngUint256 % 100000000) / 100000);
        uint256 mana = ((qrngUint256 % 100000000) / 1000000);
        uint256 experience = 0;

        characters.push(
            Character(
                strength,
                intelligence,
                mana,
                experience,
                requestToCharacterName[requestId]
            )
        );
        _safeMint(requestToSender[requestId], newId);
    }

    function getCharacterStats(uint256 tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            characters[tokenId].strength,
            characters[tokenId].intelligence,
            characters[tokenId].mana,
            characters[tokenId].experience
        );
    }
}