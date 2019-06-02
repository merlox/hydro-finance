pragma solidity ^0.5.0;

/// @notice The interface of the identity registry contract
/// @author Merunas Grincalaitis <merunasgrincalaitis@gmail.com>
interface IdentityRegistryInterface {
    function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        external pure returns (bool);
    function identityExists(uint ein) external view returns (bool);
    function hasIdentity(address _address) external view returns (bool);
    function getEIN(address _address) external view returns (uint ein);
    function isAssociatedAddressFor(uint ein, address _address) external view returns (bool);
    function isProviderFor(uint ein, address provider) external view returns (bool);
    function isResolverFor(uint ein, address resolver) external view returns (bool);
    function getIdentity(uint ein) external view returns (
        address recoveryAddress,
        address[] memory associatedAddresses, address[] memory providers, address[] memory resolvers
    );
    function createIdentity(address recoveryAddress, address[] calldata providers, address[] calldata resolvers)
        external returns (uint ein);
    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] calldata providers, address[] calldata resolvers,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external returns (uint ein);
    function addAssociatedAddress(
        address approvingAddress, address addressToAdd, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function addAssociatedAddressDelegated(
        address approvingAddress, address addressToAdd,
        uint8[2] calldata v, bytes32[2] calldata r, bytes32[2] calldata s, uint[2] calldata timestamp
    ) external;
    function removeAssociatedAddress() external;
    function removeAssociatedAddressDelegated(address addressToRemove, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function addProviders(address[] calldata providers) external;
    function addProvidersFor(uint ein, address[] calldata providers) external;
    function removeProviders(address[] calldata providers) external;
    function removeProvidersFor(uint ein, address[] calldata providers) external;
    function addResolvers(address[] calldata resolvers) external;
    function addResolversFor(uint ein, address[] calldata resolvers) external;
    function removeResolvers(address[] calldata resolvers) external;
    function removeResolversFor(uint ein, address[] calldata resolvers) external;
    function triggerRecoveryAddressChange(address newRecoveryAddress) external;
    function triggerRecoveryAddressChangeFor(uint ein, address newRecoveryAddress) external;
    function triggerRecovery(uint ein, address newAssociatedAddress, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function triggerDestruction(
        uint ein, address[] calldata firstChunk, address[] calldata lastChunk, bool resetResolvers
    ) external;
}


/// @notice The Hydrogen Finance contract for managing financial accounts such as credit cards, banks and invement accounts on-chain using encryption technology
/// @author Merunas Grincalaitis <merunasgrincalaitis@gmail.com>
contract HydroFinance {
    struct Card {
        uint256 id;
        uint256 einOwner;
        string cardName;
        uint256 card;
        uint256 expiry;
        uint256 cvv;
    }
    struct Bank {
        uint256 id;
        uint256 einOwner;
        string bankName;
        uint256 bank;
    }
    struct Investment {
        uint256 id;
        uint256 einOwner;
        string investmentName;
        uint256 investment;
    }
    struct User {
        uint256 einOwner;
        address owner;
        Card[] cards;
        Bank[] banks;
        Investment[] investments;
    }
    mapping(uint256 => User) public userByEin;
    User[] public users;
    address public identityRegistry;

    /// @notice To setup the address of the identity registry to use for this contract
    /// @param _identityRegistry The address of the Identity Registry contract
    constructor(address _identityRegistry) public {
        require(_identityRegistry != 0, 'The address of the identity registry contract cannot be empty');
        identityRegistry = _identityRegistry;
    }

    // @notice To add a new credit card to your account. All function will be encrypted the moment the data is added
    function addCreditCard(uint256 _cardNumber, uint256 _expiry, string memory _name, uint256 _cvv) public {
        require(_cardNumber != 0, 'The card number cannot be empty');
        require(_expiry != 0, 'The card expiration date cannot be empty');
        require(bytes(_name).length != 0, 'The card name must be set');
        require(_cvv != 0, 'The cvv cannot be empty');


    }

    function addBank(_bankNumber, _name) public {

    }

    function addInvestmentAccount(_investmentNumber, _name) public {

    }

    function removeAccount(_id) public {

    }
}
