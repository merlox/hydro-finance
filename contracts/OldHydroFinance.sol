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
        uint256[] cardIds;
        uint256[] bankIds;
        uint256[] investmentIds;
    }
    mapping(uint256 => User) public userByEin;
    mapping(uint256 => Card) public cardById;
    mapping(uint256 => Bank) public bankById;
    mapping(uint256 => Investment) public investmentById;
    uint256 public lastCardId;
    uint256 public lastBankId;
    uint256 public lastInvestmentId;
    User[] public users;
    address public identityRegistry;

    /// @notice To setup the address of the identity registry to use for this contract
    /// @param _identityRegistry The address of the Identity Registry contract
    constructor(address _identityRegistry) public {
        require(_identityRegistry != address(0), 'The address of the identity registry contract cannot be empty');
        identityRegistry = _identityRegistry;
    }

    /// @notice To add a new credit card to your account. All function will be encrypted the moment the data is added
    /// @param _cardNumber The number of the credit or debit card to add to your account
    /// @param _expiry When the card expires in timestamp
    /// @param _name The name of the card
    /// @param _cvv The 3 or 4 digit code for verifying the card
    function addCard(uint256 _cardNumber, uint256 _expiry, string memory _name, uint256 _cvv) public {
        require(_cardNumber != 0, 'The card number cannot be empty');
        require(_expiry != 0, 'The card expiration date cannot be empty');
        require(bytes(_name).length != 0, 'The card name must be set');
        require(_cvv != 0, 'The cvv cannot be empty');

        checkAndCreateUser();
        lastCardId++;
        uint256 ein = IdentityRegistryInterface(identityRegistry).getEIN(msg.sender);
        Card memory newCard = Card(lastCardId, ein, _name, _cardNumber, _expiry, _cvv);

        cardById[lastCardId] = newCard;
        userByEin[ein].cardIds.push(lastCardId);
    }

    /// @notice To add a new bank
    /// @param _bankNumber The number of the bank to add
    /// @param _name The name of the bank
    function addBank(uint256 _bankNumber, string memory _name) public {
        require(_bankNumber != 0, 'The bank number must be set');
        require(bytes(_name).length != 0, 'The bank name must be set');

        checkAndCreateUser();
        lastBankId++;
        uint256 ein = IdentityRegistryInterface(identityRegistry).getEIN(msg.sender);
        Bank memory newBank = Bank(lastBankId, ein, _name, _bankNumber);
        bankById[lastBankId] = newBank;
        userByEin[ein].bankIds.push(lastBankId);
    }

    /// @notice To create an investment account for your user
    /// @param _investmentNumber The number of the investment account that you want to create
    /// @param _name The name of the investment account
    function addInvestmentAccount(uint256 _investmentNumber, string memory _name) public {
        require(_investmentNumber != 0, 'The investment account number must be set');
        require(bytes(_name).length != 0, 'The name of the investment account must be set');

        checkAndCreateUser();
        lastInvestmentId++;
        uint256 ein = IdentityRegistryInterface(identityRegistry).getEIN(msg.sender);
        Investment memory inv = Investment(lastInvestmentId, ein, _name, _investmentNumber);
        investmentById[lastInvestmentId] = inv;
        userByEin[ein].investmentIds.push(lastInvestmentId);
    }

    /// @notice To delete an account
    function removeAccount() public {
        uint256 ein = IdentityRegistryInterface(identityRegistry).getEIN(msg.sender);
        require(userByEin[ein].einOwner == ein, 'Only the EIN owner of the account can remove the account');

        delete userByEin[ein];
        for(uint256 i = 0; i < users.length; i++) {
            if(users[i].einOwner == ein) {
                User memory lastElement = users[users.length - 1];
                users[i] = lastElement;
                users.length--;
            }
        }
    }

    /// @notice To create a new user if he doesn't have an account yet using his EIN identifier
    function checkAndCreateUser() internal {
        uint256 ein = IdentityRegistryInterface(identityRegistry).getEIN(msg.sender);

        // If we can't find the user, create a new one
        if(userByEin[ein].owner == address(0)) {
            uint256[] memory emptyArray = new uint256[](0);
            User memory newUser = User(ein, msg.sender, emptyArray, emptyArray, emptyArray);
            users.push(newUser);
            userByEin[ein] = newUser;
        }
    }

    /// @notice To get the user data
    /// @return Returns the EIN, address owner, array of card ids, array of bank ids and array of investment ids
    function getUserData() public view returns(uint256, address, uint256[] memory, uint256[] memory, uint256[] memory) {
        uint256 ein = IdentityRegistryInterface(identityRegistry).getEIN(msg.sender);
        User memory u = userByEin[ein];

        return (u.einOwner, u.owner, u.cardIds, u.bankIds, u.investmentIds);
    }
}