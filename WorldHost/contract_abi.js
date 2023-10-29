const contractABI = [
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "tradeId",
				"type": "bytes32"
			}
		],
		"name": "cancelTrade",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "pokemon",
				"type": "string"
			}
		],
		"name": "catchPokemon",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "tradeId",
				"type": "bytes32"
			}
		],
		"name": "confirmTrade",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "pokemon1",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "pokemon2",
				"type": "string"
			}
		],
		"name": "initiateTrade",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "bytes32",
				"name": "pokemonHash",
				"type": "bytes32"
			}
		],
		"name": "PokemonCaught",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "bytes32",
				"name": "tradeId",
				"type": "bytes32"
			}
		],
		"name": "TradeCancelled",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "bytes32",
				"name": "tradeId",
				"type": "bytes32"
			}
		],
		"name": "TradeCompleted",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "bytes32",
				"name": "tradeId",
				"type": "bytes32"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "user1",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "pokemon1",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "pokemon2",
				"type": "string"
			}
		],
		"name": "TradeInitiated",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "activeTradeIds",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getActiveTradeIds",
		"outputs": [
			{
				"internalType": "bytes32[]",
				"name": "",
				"type": "bytes32[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getMyPokemons",
		"outputs": [
			{
				"internalType": "bytes32[]",
				"name": "",
				"type": "bytes32[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "tradeId",
				"type": "bytes32"
			}
		],
		"name": "getPokemonFromTradeId",
		"outputs": [
			{
				"internalType": "string[2]",
				"name": "",
				"type": "string[2]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "pokemonHash",
				"type": "bytes32"
			}
		],
		"name": "getPokemonName",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "user",
				"type": "address"
			}
		],
		"name": "getPokemonsOfUser",
		"outputs": [
			{
				"internalType": "bytes32[]",
				"name": "",
				"type": "bytes32[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"name": "pendingTrades",
		"outputs": [
			{
				"internalType": "address",
				"name": "user1",
				"type": "address"
			},
			{
				"internalType": "bytes32",
				"name": "pokemon1",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "pokemon2",
				"type": "bytes32"
			},
			{
				"internalType": "bool",
				"name": "isActive",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];

module.exports = contractABI;
