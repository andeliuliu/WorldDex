// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PokemonCollector {
    // Struct to store the details of a pending trade
    struct Trade {
        address user1;
        bytes32 pokemon1;
        bytes32 pokemon2;
        bool isActive;
    }


    // Mapping from user addresses to their hashed list of collected Pokemon
    mapping(address => bytes32[]) private collections;

    // Mapping to store the pending trades
    mapping(bytes32 => Trade) public pendingTrades;

    // Mapping pending trades to their index
    mapping(bytes32 => uint256) private tradeIndex;

    // Translate pokemon hashes to their names
    mapping(bytes32 => string) private hashToPokemon;

    // List of active trade IDs
    bytes32[] public activeTradeIds;

    // Address of the owner (back-end)
    address public owner;

    // Event to log when a new Pokemon is caught
    event PokemonCaught(address indexed user, bytes32 pokemonHash);

    // Event to log when a trade is initiated
    event TradeInitiated(bytes32 tradeId, address indexed user1, string pokemon1, string pokemon2);

    // Event to log when a trade is cancelled
    event TradeCancelled(bytes32 tradeId);

    // Event to log when a trade is completed
    event TradeCompleted(bytes32 tradeId);

    // Modifier to restrict certain functions to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Constructor to set the owner of the contract
    constructor() {
        owner = msg.sender;
    }

    function catchPokemon(address user, string calldata pokemon) external onlyOwner {
        require(bytes(pokemon).length > 0, "Pokemon name cannot be empty");
        bytes32 pokemonHash = keccak256(bytes(pokemon));
        
        collections[user].push(pokemonHash);
        hashToPokemon[pokemonHash] = pokemon;
        emit PokemonCaught(user, pokemonHash);
    }


    // Internal function to find the index of a Pokemon in a user's collection
    // Returns -1 if the Pokemon is not found
    function findPokemonIndex(address user, bytes32 pokemonHash) private view returns (int) {
        bytes32[] memory collection = collections[user];
        for (uint i = 0; i < collection.length; i++) {
            if (collection[i] == pokemonHash) {
                return int(i);
            }
        }
        return -1;
    }

    // Function to initiate a trade
    function initiateTrade(string memory pokemon1, string memory pokemon2) public returns (bytes32) {
        require(bytes(pokemon1).length > 0, "Pokemon1 name cannot be empty");
        require(bytes(pokemon2).length > 0, "Pokemon2 name cannot be empty");

        bytes32 pokemon1Hash = keccak256(bytes(pokemon1));
        bytes32 pokemon2Hash = keccak256(bytes(pokemon2));

        require(bytes(hashToPokemon[pokemon1Hash]).length > 0, "Offered pokemon does not exist");
        require(bytes(hashToPokemon[pokemon2Hash]).length > 0, "Desired pokemon does not exist");

        bytes32 tradeId = keccak256(abi.encodePacked(msg.sender, pokemon1Hash, pokemon2Hash, block.timestamp));
        pendingTrades[tradeId] = Trade({
            user1: msg.sender,
            pokemon1: pokemon1Hash,
            pokemon2: pokemon2Hash,
            isActive: true
        });

        activeTradeIds.push(tradeId);
        tradeIndex[tradeId] = activeTradeIds.length - 1;        
        emit TradeInitiated(tradeId, msg.sender, pokemon1, pokemon2);

        return tradeId;
    }

    function getPokemonFromTradeId(bytes32 tradeId) public view returns (string[2] memory) {
        Trade memory trade = pendingTrades[tradeId];
        require(trade.isActive, "Trade is not active");

        return [hashToPokemon[trade.pokemon1], hashToPokemon[trade.pokemon2]];
    }

    // Function to get all active trade IDs
    function getActiveTradeIds() public view returns (bytes32[] memory) {
        return activeTradeIds;
    }

    // Function to confirm a trade
    function confirmTrade(bytes32 tradeId) public {
        Trade storage trade = pendingTrades[tradeId];
        require(trade.isActive, "Trade is not active");
        require(msg.sender != trade.user1, "Cannot trade with yourself");
        
        // Remove the Pokemon from the original owners
        removePokemonFromCollection(trade.user1, trade.pokemon1);
        removePokemonFromCollection(msg.sender, trade.pokemon2);

        // Add the Pokemon to the new owners
        addPokemonToCollection(trade.user1, trade.pokemon2);
        addPokemonToCollection(msg.sender, trade.pokemon1);

        // Clean up the trade
        uint256 index = tradeIndex[tradeId];
        activeTradeIds[index] = activeTradeIds[activeTradeIds.length - 1];
        tradeIndex[activeTradeIds[index]] = index;
        activeTradeIds.pop();
        
        delete pendingTrades[tradeId];
        delete tradeIndex[tradeId];
        
        emit TradeCompleted(tradeId);
    }

    // Function to add a Pokemon to a user's collection
    function addPokemonToCollection(address user, bytes32 pokemonHash) private {
        // Here you can add any necessary logic to add the Pokemon to the user's collection
        collections[user].push(pokemonHash);
    }

    // Function to get pokemons for the calling user
    function getMyPokemons() public view returns (bytes32[] memory) {
        return collections[msg.sender];
    }

    // Function to get pokemons of a specific user, restricted to the owner
    function getPokemonsOfUser(address user) public view onlyOwner returns (bytes32[] memory) {
        return collections[user];
    }

    // Function to remove a Pokemon from a user's collection
    function removePokemonFromCollection(address user, bytes32 pokemonHash) private {
        int256 index = findPokemonIndex(user, pokemonHash);
        require(index != -1, "Pokemon not found in user's collection");

        // Replace the Pokemon to be removed with the last Pokemon in the array
        collections[user][uint256(index)] = collections[user][collections[user].length - 1];
        
        // Remove the last Pokemon in the array
        collections[user].pop();
    }


    function cancelTrade(bytes32 tradeId) public {
        Trade storage trade = pendingTrades[tradeId];
        require(trade.isActive, "Trade is not active");
        require(msg.sender == trade.user1, "Only user proposing trade can cancel the trade");

        uint256 index = tradeIndex[tradeId];
        activeTradeIds[index] = activeTradeIds[activeTradeIds.length - 1];
        tradeIndex[activeTradeIds[index]] = index;
        activeTradeIds.pop();

        delete pendingTrades[tradeId];
        delete tradeIndex[tradeId];
        
        emit TradeCancelled(tradeId);
    }

    function getPokemonName(bytes32 pokemonHash) public view returns (string memory) {
        require(bytes(hashToPokemon[pokemonHash]).length > 0, "Pokemon does not exist");
        return hashToPokemon[pokemonHash];
    }
}
