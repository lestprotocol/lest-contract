// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {StringUtils} from "./libraries/StringUtils.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract LestDomains is ERC721URIStorage {
    address payable public owner;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    error Unauthorized();
    error AlreadyRegistered();
    error InvalidName(string name);
    event Transfer(string name, address newOwner);

    string public tld;

    string svgPartOne =
        '<svg width="270" height="270" viewBox="0 0 270 270" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><rect width="270" height="270" fill="url(#paint0_linear_26_38)"/><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="DejaVu Sans" font-weight="bold">';
    string svgPartTwo =
        '</text><defs><pattern id="pattern0" patternContentUnits="objectBoundingBox" width="1" height="1"><use xlink:href="#image0_26_38" transform="matrix(0.00093254 0 0 0.00333333 -0.00077381 0)"/></pattern><linearGradient id="paint0_linear_26_38" x1="129" y1="127" x2="135" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#030209"/><stop offset="1" stop-color="#0B1E3E"/></linearGradient></defs></svg>';

    string avatar =
        "PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHg9IjMuNSIgeT0iMy41IiB3aWR0aD0iOTMiIGhlaWdodD0iOTMiIHJ4PSI0Ni41IiBmaWxsPSIjRjhGNUYwIiBzdHJva2U9ImJsYWNrIiBzdHJva2Utd2lkdGg9IjciLz4KPHJlY3QgeD0iMTguNSIgeT0iMjcuNSIgd2lkdGg9IjIyIiBoZWlnaHQ9IjIyIiByeD0iMTEiIGZpbGw9IiNGOEY1RjAiIHN0cm9rZT0iYmxhY2siLz4KPHJlY3QgeD0iMjIuNSIgeT0iMzEuNSIgd2lkdGg9IjEzIiBoZWlnaHQ9IjEzIiByeD0iNi41IiBmaWxsPSIjRjhGNUYwIiBzdHJva2U9ImJsYWNrIi8+CjxyZWN0IHg9IjYyLjUiIHk9IjI3LjUiIHdpZHRoPSIyMiIgaGVpZ2h0PSIyMiIgcng9IjExIiBmaWxsPSIjRjhGNUYwIiBzdHJva2U9ImJsYWNrIi8+CjxyZWN0IHg9IjY2LjUiIHk9IjMxLjUiIHdpZHRoPSIxMyIgaGVpZ2h0PSIxMyIgcng9IjYuNSIgZmlsbD0iI0Y4RjVGMCIgc3Ryb2tlPSJibGFjayIvPgo8bGluZSB4MT0iNTAuNSIgeTE9IjM5IiB4Mj0iNTAuNSIgeTI9IjUwIiBzdHJva2U9ImJsYWNrIi8+CjxsaW5lIHgxPSIyOSIgeTE9IjcwLjUiIHgyPSI3MCIgeTI9IjcwLjUiIHN0cm9rZT0iYmxhY2siLz4KPC9zdmc+Cg==";

    mapping(uint => string) public names;
    struct Domain {
        address owner;
        string name;
        string image;
        string avatar;
        string tld;
        uint256 createdAt;
        bool enableSubDomains;
        uint256 resellPrice;
        uint256 expiry; // Add the expiry property to store the timestamp of domain's expiry
    }
    struct Subdomain {
        address owner;
        string name;
        string image;
        uint256 createdAt;
        address parent;
    }

    struct Bid {
        address bidder;
        uint256 bidAmount;
    }

    // Mapping to store bids for each domain token ID
    mapping(string => Bid[]) public bids;
    // Mapping to store the expiry timestamp for each domain
    mapping(string => uint256) public domainExpiry;

    // Address of the treasury
    address public treasuryAddress;
    mapping(string => Domain) domains;
    mapping(string => Subdomain) subdomain;

    constructor(string memory _tld) payable ERC721("LestDomain", "LSD") {
        owner = payable(msg.sender);
        tld = _tld;
    }

    // function register(string calldata name, string memory _tld, uint256 expiryTimestamp) public payable {
    //     require(domains[name].owner == address(0), "Domain already registered");
    //     // Ensure the owner can only set the expiry in the future
    //     require(expiryTimestamp > block.timestamp, "Expiry timestamp must be in the future");
    //     if (!valid(name)) revert InvalidName(name);
    //     uint256 _price = price(name);
    //     require(msg.value >= _price, "Not enough Fund to purchase");

    //     string memory _name = string(abi.encodePacked(name, ".", _tld));
    //     string memory finalSvg = string(
    //         abi.encodePacked(svgPartOne, _name, svgPartTwo)
    //     );
    //     uint256 newRecordId = _tokenIds.current();
    //     uint256 length = StringUtils.strlen(name);
    //     string memory strLen = Strings.toString(length);
    //     string memory json = Base64.encode(
    //         abi.encodePacked(
    //             "{"
    //             '"name": "',
    //             _name,
    //             '", '
    //             '"description": "A domain on the Lest Protocol domains", '
    //             '"image": "data:image/svg+xml;base64,',
    //             Base64.encode(bytes(finalSvg)),
    //             '", '
    //             '"length": "',
    //             strLen,
    //             '"'
    //             "}"
    //         )
    //     );

    //     string memory finalTokenUri = string(
    //         abi.encodePacked("data:application/json;base64,", json)
    //     );
    //     _safeMint(msg.sender, newRecordId);
    //     _setTokenURI(newRecordId, finalTokenUri);

    //     // Set the domain's expiry to 1 year from now
    //     // domains[name].expiry = block.timestamp + _expiry;

    //     domains[name].owner = msg.sender;
    //     domains[name].resellPrice = _price * 2;
    //     domains[name].name = string(abi.encodePacked(name, ".", _tld));
    //     domains[name].image = string(
    //         abi.encodePacked(
    //             "data:image/svg+xml;base64,",
    //             Base64.encode(bytes(finalSvg))
    //         )
    //     );
    //     domains[name].avatar = string(
    //         abi.encodePacked("data:image/svg+xml;base64,", (avatar))
    //     );
    //     domains[name].tld = _tld;
    //     domains[name].createdAt = block.timestamp;
    //     // Set the expiry timestamp
    //     domains[name].expiry = expiryTimestamp;
    //     names[newRecordId] = name;
    //     _tokenIds.increment();
    // }

    function register(
        string calldata name,
        string memory _tld,
        uint256 expiryTimestamp
    ) public payable {
        require(domains[name].owner == address(0), "Domain already registered");
        require(valid(name), "Invalid domain name");
        require(
            msg.value >= calculatePrice(name, expiryTimestamp),
            "Not enough funds to purchase"
        );

        string memory _name = string(abi.encodePacked(name, ".", _tld));
        string memory finalSvg = string(
            abi.encodePacked(svgPartOne, _name, svgPartTwo)
        );

        uint256 newRecordId = _tokenIds.current();
        uint256 length = StringUtils.strlen(name);
        string memory strLen = Strings.toString(length);
        string memory json = Base64.encode(
            abi.encodePacked(
                "{"
                '"name": "',
                _name,
                '", '
                '"description": "A domain on the Lest Protocol domains", '
                '"image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(finalSvg)),
                '", '
                '"length": "',
                strLen,
                '"'
                "}"
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);

        domains[name].owner = msg.sender;
        domains[name].resellPrice = calculatePrice(name, expiryTimestamp) * 2;
        domains[name].name = string(abi.encodePacked(name, ".", _tld));
        domains[name].image = string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(bytes(finalSvg))
            )
        );
        domains[name].avatar = string(
            abi.encodePacked("data:image/svg+xml;base64,", avatar)
        );
        domains[name].tld = _tld;
        domains[name].createdAt = block.timestamp;
        domains[name].expiry = expiryTimestamp; // Set the expiry timestamp
        names[newRecordId] = name;
        _tokenIds.increment();
    }

    function calculatePrice(
        string calldata name,
        uint256 expiryTimestamp
    ) public view returns (uint256) {
        uint256 basePrice = price(name);

        // Calculate the price increase based on the time difference
        uint256 currentTime = block.timestamp;
        if (expiryTimestamp > currentTime) {
            uint256 timeDifference = expiryTimestamp - currentTime;
            uint256 priceIncrease = (timeDifference * basePrice) / 5 minutes; // Increase by 20% for each minute beyond the expiry time
            return basePrice + priceIncrease;
        }

        return basePrice;
    }

    /**
     * @dev Transfers ownership of a name to a new address. Can only be called by the current owner of the domain.
     * @param name The name to transfer ownership of.
     * @param newOwner The address of the new owner.
     */
    function transferDomain(
        string calldata name,
        address newOwner
    ) public virtual domainOwner(name) {
        require(
            newOwner != address(0x0),
            "cannot set owner to the zero address"
        );
        require(
            newOwner != address(this),
            "cannot set owner to the registry address"
        );

        domains[name].owner = newOwner;
        emit Transfer(name, newOwner);
    }

    // Function to check if a domain has expired
    function hasDomainExpired(string calldata name) public view returns (bool) {
        return domainExpiry[name] <= block.timestamp;
    }

    function setResellPrice(
        string memory name,
        uint256 _price
    ) public domainOwner(name) {
        domains[name].resellPrice = _price;
    }

    function setAvatar(
        string memory _avatar,
        string memory name
    ) public domainOwner(name) {
        require(
            domains[name].owner == owner,
            "You can't set the avatar because it's not yours"
        );
        domains[name].avatar = _avatar;
    }

    function valid(string calldata name) public pure returns (bool) {
        return StringUtils.strlen(name) >= 1 && StringUtils.strlen(name) <= 10;
    }

    function getAllNames() public view returns (string[] memory) {
        string[] memory allNames = new string[](_tokenIds.current());
        for (uint i = 0; i < _tokenIds.current(); i++) {
            allNames[i] = string(abi.encodePacked(names[i], ".", tld));
        }
        return allNames;
    }

    function price(string calldata name) public pure returns (uint) {
        uint len = StringUtils.strlen(name);
        require(len > 0);

        if (len == 1) {
            return 20 * 10 ** 18; // 20 ETH
        } else if (len <= 3) {
            return 4 * 10 ** 18; // 4 ETH
        } else {
            return 1.5 * 10 ** 18; // 1.5 ETH
        }
    }

    function placeBid(string calldata name, uint256 bidAmount) public payable {
        require(domains[name].owner != address(0), "Domain does not exist");
        require(msg.value == bidAmount, "Bid amount must match sent Ether");

        Domain storage domain = domains[name];
        require(
            bidAmount > domain.resellPrice,
            "Bid must be higher than current price"
        );

        // Store the bid
        bids[name].push(Bid({bidder: msg.sender, bidAmount: msg.value}));

        domain.resellPrice = bidAmount;
    }

    function _getHighestBidder(
        string calldata name
    ) internal view returns (address) {
        uint256 highestBid = 0;
        address highestBidder = address(0);

        // Loop through all bids to find the highest bidder
        // You might need to store bids separately, depending on your design
        // For this example, we assume a separate mapping for bids
        for (uint256 i = 0; i < bids[name].length; i++) {
            if (bids[name][i].bidAmount > highestBid) {
                highestBid = bids[name][i].bidAmount;
                highestBidder = bids[name][i].bidder;
            }
        }

        return highestBidder;
    }

    // Get the bid history for a specific domain
    function getBidHistory(
        string calldata name
    ) public view returns (Bid[] memory) {
        require(getDomain(name).owner != address(0), "Domain does not exist");
        return bids[name];
    }

    // function resell(string calldata name) public domainOwner(name) {
    //     address highestBidder = _getHighestBidder(name);
    //     require(highestBidder != address(0), "No valid bidders");

    //     Domain storage domain = domains[name];
    //     address currentOwner = domain.owner;

    //     domain.createdAt = block.timestamp; // Update the timestamp
    //     delete bids[name];

    //     transferDomain(name, highestBidder);

    //     // Transfer funds to the domain owner
    //     (bool success, ) = domain.owner.call{value: domain.resellPrice * 0.05}(
    //         ""
    //     );
    //     require(success, "Transfer to domain owner failed");
    //     // Reset the resell price
    //     domain.resellPrice = 0;
    //     emit Transfer(domain.name, highestBidder);
    // }

    // function sellSubdomain(
    //     string calldata parentName,
    //     string calldata name,
    //     uint256 _price
    // ) public payable {
    //     require(
    //         domains[parentName].enableSubDomains,
    //         "Domain doesn't support subdomain"
    //     );
    //     if (!valid(parentName)) revert InvalidName(parentName);

    //     uint256 $price = price(parentName);
    //     require(msg.value >= $price, "Not enough Fund to purchase");

    //     address parent = domains[parentName].owner;

    //     // Calculate commission amount
    //     uint256 commission = (_price * 0.03); // 0.3%

    //     // Calculate amount to send to seller after deducting commission
    //     uint256 amountToSeller = _price - commission;

    //     string memory _name = string(
    //         abi.encodePacked(name, domains[parentName].name)
    //     );
    //     string memory finalSvg = string(
    //         abi.encodePacked(svgPartOne, _name, svgPartTwo)
    //     );

    //     // Transfer the subdomain to the buyer
    //     address buyer = msg.sender;
    //     address seller = parent;

    //     subdomain[name].owner = buyer;
    //     subdomain[name].name = _name;
    //     subdomain[name].image = string(
    //         abi.encodePacked(
    //             "data:image/svg+xml;base64,",
    //             Base64.encode(bytes(finalSvg))
    //         )
    //     );
    //     subdomain[name].parent = seller;

    //     // Transfer funds: amountToSeller to seller, commission to contract owner
    //     (bool successSeller, ) = seller.call{value: amountToSeller}("");
    //     require(successSeller, "Transfer to seller failed");

    //     (bool successOwner, ) = owner.call{value: commission}("");
    //     require(successOwner, "Transfer to owner failed");
    // }

    function getAddress(string calldata name) public view returns (address) {
        return domains[name].owner;
    }

    function getDomain(
        string calldata name
    ) public view returns (Domain memory) {
        return domains[name];
    }

    // Get all domains with enableResell set to true
    // function getDomainsWithResellEnabled()
    //     public
    //     view
    //     returns (Domain[] memory)
    // {
    //     Domain[] memory result;
    //     uint256 totalDomains = _tokenIds.current();
    //     uint256 resellEnabledCount = 0;

    //     // Count how many domains have enableResell set to true
    //     for (uint256 i = 0; i < totalDomains; i++) {
    //         if (domains[i].enableResell) {
    //             resellEnabledCount++;
    //         }
    //     }

    //     // Initialize the result array with the correct size
    //     result = new Domain[](resellEnabledCount);

    //     // Populate the result array with domains that have enableResell set to true
    //     uint256 resultIndex = 0;
    //     for (uint256 i = 0; i < totalDomains; i++) {
    //         if (domains[i].enableResell) {
    //             result[resultIndex] = domains[i];
    //             resultIndex++;
    //         }
    //     }

    //     return result;
    // }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    modifier domainOwner(string memory _name) {
        require(domains[_name].owner == owner, "You are not the domain owner");
        _;
    }

    function setTreasuryAddress(address _address) public onlyOwner {
        treasuryAddress = _address;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    function withdraw() public onlyOwner {
        uint amount = address(this).balance;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw");
    }
}
