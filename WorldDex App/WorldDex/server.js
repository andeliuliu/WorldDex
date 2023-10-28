/* 
=================================
================================= 
HELPER AND SETUP, IGNORE
=================================
================================= 
*/

require("dotenv").config();
const db = require("./db");
const contractABI = require("./contract_abi");
const express = require("express");
const bodyParser = require("body-parser");
const Web3 = require("web3");
const fs = require("fs");
const app = express();
const path = require("path");
const fileUpload = require('express-fileupload');
const { Web3Storage, File } = require('web3.storage');
const { AccountId, PrivateKey, Client, TokenCreateTransaction, TokenType, TokenSupplyType, TokenMintTransaction, TransferTransaction } = require("@hashgraph/sdk");

const web3StorageAPIKey = process.env.web3StorageAPIKey;
const operatorAccountId = AccountId.fromString(process.env.operatorAccountId);
const operatorPrivateKey = PrivateKey.fromString(process.env.operatorPrivateKey);
const supplyKey = PrivateKey.fromString(process.env.supplyKey);
const tokenId = process.tokenId;
const recipientAccountId = AccountId.fromString(process.env.recipientAccountId);
const recipientPrivateKey = PrivateKey.fromString(process.env.recipientPrivateKey);

app.use(bodyParser.json());

app.use(fileUpload({useTempFiles: true}));

const web3 = new Web3(
  new Web3.providers.HttpProvider(
    `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`
  )
);
const contractAddress = "0x048Efe7fA4D562CC6B27aBEec0882B69dDc13f9C";

const pokemonCollectorContract = new web3.eth.Contract(
  contractABI,
  contractAddress
);

tradeIdManager = {};
nextTradeId = 0;

// Private key of the account that will send the transaction
const privateKey = process.env.PRIVATE_KEY;
if (!privateKey) {
  console.error("PRIVATE_KEY is not set");
  process.exit(1);
}
const account = web3.eth.accounts.privateKeyToAccount(privateKey);
web3.eth.accounts.wallet.add(account);
web3.eth.defaultAccount = account.address;

const handleWeb3StorageUpload = async (req) => {
  const { username } = req.body;
  const label = req.body['image_id'];
  const { image } = req?.files ?? {};
  console.log(`Uploading image: [${label}] to ipfs.`);
  console.log(`Image: ${image}`);
  if (!image && !label || label === undefined) {
    return res.status(200).send({ message: 'invalid input' });
  }
  const imageName = `${new Date().getTime()}_${image.name.replaceAll(' ', '')}`;
  const file = await fileFromPath(image, imageName);
  const imageCid = await storeFiles(file);
  const files = await makeFileObjects(label, `https://${imageCid}.ipfs.w3s.link/${imageName}`);
  const metaDataCid = await storeFiles(files);
  await fs.promises.unlink(image.tempFilePath);
  const metadataUrl = `https://${metaDataCid}.ipfs.w3s.link/metadata.json`;
  console.log(metaDataCid);

  const newTokenId = await mintNft(username, label, metaDataCid, username);

  const ipfsTierInfo = {
    label,
    ipfsUrl: metadataUrl,
    tokenId: newTokenId.newTokenId,
    serialNumber: newTokenId.serialNumber
  };
  return {
    success: true,
    ipfsTierInfo: ipfsTierInfo, 
  };
};

/* 
=================================
================================= 
END OF HELPER AND SETUP
=================================
================================= 
*/

/* 
=================================
================================= 
LOOK HERE FOR USEFUL ENDPOINTS
=================================
================================= 
*/


// THIS WRITES ALL IMAGES TO A TEMPORARY FOLDER FOR A GIVEN USER
// EXAMPLE USAGE: http://localhost:3000/images?userId=4
app.get("/images", async (req, res) => {
  try {
    const userId = req.query.userId;
    const tempDir = "temp";
    const userDir = path.join(__dirname, tempDir, userId);

    if (!userId) {
      return res.status(400).send("Missing userId");
    }

    // Ensure the directory exists
    if (!fs.existsSync(userDir)) {
      fs.mkdirSync(userDir, { recursive: true });
    } else {
      // Directory exists, clear it
      const files = fs.readdirSync(userDir);
      for (const file of files) {
        fs.unlinkSync(path.join(userDir, file));
      }
    }

    const result = await db.query(
      "SELECT image_data, image_id FROM images WHERE user_id = $1",
      [userId]
    );

    if (result.rows.length === 0) {
      console.log("No images found for the user.");
      return res.status(404).send("Image not found");
    }

    const imagePaths = [];

    result.rows.forEach((row, index) => {
      const imageId = row.image_id || `image_${index}`;
      const imagePath = path.join(userDir, `${imageId}.jpg`);
      fs.writeFileSync(imagePath, row.image_data);
      imagePaths.push(imagePath);
    });

    res.json({ imagePaths });
  } catch (err) {
    console.error("Database error:", err);
    res.status(500).send("Internal Server Error");
  }
});

// THIS GETS ALL USER IDs (for images), USERNAMES, AND EMAILS
app.get("/users", async (req, res) => {
  try {
    const result = await db.query("SELECT * FROM users");
    res.json(result.rows);
  } catch (err) {
    console.error("error executing query: ", err);
    res.status(500).send("Internal Server Error");
  }
});

// THIS ADDS A NEW USER
app.post("/users", async (req, res) => {
  const { user_id, username, email } = req.body;

  if (!user_id || !username || !email) {
    return res.status(400).send("Missing parameters.");
  }

  try {
    await db.query(
      "INSERT INTO users (user_id, username, email) VALUES ($1, $2, $3)",
      [user_id, username, email]
    );
    res.send("User added successfully!");
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error.");
  }
});

/* THIS EXECUTES A CATCH FOR POKEMON. IT:
- ADDS A CATCH TO ETHEREUM SMART CONTRACT FOR TRADING
- UPLOADS TO IPFS FOR DECENTRALIZED STORAGE
- MINTS AN NFT ON HEDERA TO USER WITH IPFS LINK
- ADDS TO CENTRALIZED COCKROACHDB STORAGE FOR EASIER USE FROM OUR FRONT-END
*/
app.post('/catch', async (req, res) => {
  try {
    const {
      image_id,
      userId,
      locationTaken,
      userAddress,
    } = req.body;

    const { image, croppedImage } = req.files ?? {};

    if (!croppedImage || !image) {
      return res.status(400).send('Missing croppedImage or image');
    }
    const imageData = fs.readFileSync(image.tempFilePath);
    const croppedImageData = fs.readFileSync(croppedImage.tempFilePath);

    const pokemon = image_id;
    const dateAdded = new Date().toISOString();

    const imageUploadResponse = await catchPokemonAndMintNft(userAddress, pokemon, req);
    const blockchainUrl = imageUploadResponse.ipfsTierInfo.ipfsUrl;
    
    const result = await db.query(
      "INSERT INTO images (image_id, user_id, blockchain_url, date_added, location_taken, cropped_image, image_data) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *",
      [
        image_id,
        userId,
        blockchainUrl,
        dateAdded,
        locationTaken,
        croppedImageData,
        imageData
      ]
    );

    res.send(`Image saved with ID: ${result.rows[0].image_id}`);
  } catch (err) {
    console.error(err);
    res.status(500).send("Internal Server Error");
  }
});

/*
=================================
================================= 
END OF USEFUL ENDPOINTS AND BEGINNING OF HORROR
=================================
================================= */

app.get("/getCollection", async (req, res) => {
  try {
    // Get user address from query parameters
    const { userAddress } = req.query;

    // Validate user address
    if (!web3.utils.isAddress(userAddress)) {
      return res.status(400).send("Invalid Ethereum address");
    }

    // Call the getMyPokemons function
    const pokemonHashes = await pokemonCollectorContract.methods
      .getMyPokemons()
      .call({ from: userAddress });

    // Convert each Pokemon hash to its name
    const pokemonNames = [];
    for (const pokemonHash of pokemonHashes) {
      const pokemonName = await pokemonCollectorContract.methods
        .getPokemonName(pokemonHash)
        .call();
      pokemonNames.push(pokemonName);
    }

    console.log(pokemonNames);

    // Send the list of Pokemon names as the response
    res.json(pokemonNames);
  } catch (error) {
    console.error("Error getting collection:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.get("/getTrade", async (req, res) => {
  try {
    // Get tradeId from query parameters
    const { tradeId } = req.query;

    // Validate tradeId
    if (!tradeId) {
      return res.status(400).send("tradeId is required");
    }

    // Call the getPokemonFromTradeId function
    const [offeredPokemon, desiredPokemon] =
      await pokemonCollectorContract.methods
        .getPokemonFromTradeId(tradeId)
        .call();

    // Send the Pokemon pair as the response
    res.json({ offeredPokemon, desiredPokemon });
  } catch (error) {
    console.error("Error getting trade:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.get("/getAllTrades", async (req, res) => {
  try {
    // Call the getActiveTradeIds function
    const activeTradeIds = await pokemonCollectorContract.methods
      .getActiveTradeIds()
      .call();

    // Prepare the response array
    const trades = [];

    // Loop through each tradeId and get the offered and desired Pokemon
    for (const tradeId of activeTradeIds) {
      const [offeredPokemon, desiredPokemon] =
        await pokemonCollectorContract.methods
          .getPokemonFromTradeId(tradeId)
          .call();
      trades.push({ tradeId, offeredPokemon, desiredPokemon });
    }

    // Send the array of trades as the response
    res.json(trades);
  } catch (error) {
    console.error("Error getting all trades:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.post("/catchPokemon", async (req, res) => {
  const userAddress = req.body['userAddress'];
  const pokemon = req.body['pokemon'];
  console.log(userAddress);
  console.log(pokemon);

  try {
    const data = pokemonCollectorContract.methods
      .catchPokemon(userAddress, pokemon)
      .encodeABI();

    const tx = {
      from: account.address,
      to: contractAddress,
      data,
      gas: 2000000,
      // You might also want to specify gasPrice or use an oracle to determine a good gas price
    };

    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);
    const receipt = await web3.eth.sendSignedTransaction(
      signedTx.rawTransaction
    );
    res.json({ success: true, transactionHash: receipt.transactionHash });
  } catch (error) {
    console.error("Error:", error);

    // Check if the error message contains the "Pokemon already in user's collection" string
    if (error.message.includes("Pokemon already in user's collection")) {
      return res
        .status(400)
        .json({
          success: false,
          error: "You have already caught this Pokémon!",
        });
    }

    // Handle other errors
    res.status(500).json({ success: false, error: "Internal Server Error" });
  }
});

app.post("/initiateTrade", async (req, res) => {
  try {
    // Destructure the required fields from the request body
    const { privateKeyAlias, offeredPokemon, desiredPokemon } = req.body;

    // Map alias to actual private key
    let privateKey;
    if (privateKeyAlias === "user1") {
      privateKey = process.env.USER_1_PRIVATE_KEY;
    } else if (privateKeyAlias === "user2") {
      privateKey = process.env.USER_2_PRIVATE_KEY;
    }

    // Validate the input
    if (!privateKey || !offeredPokemon || !desiredPokemon) {
      return res
        .status(400)
        .send(
          'Invalid input. Make sure all fields (privateKeyAlias, offeredPokemon, desiredPokemon) are provided and the privateKeyAlias is either "user1" or "user2".'
        );
    }

    // Create an account object from the private key
    const tradeAccount = web3.eth.accounts.privateKeyToAccount(privateKey);
    web3.eth.accounts.wallet.add(tradeAccount);

    // Encode the initiateTrade function call
    const data = pokemonCollectorContract.methods
      .initiateTrade(offeredPokemon, desiredPokemon)
      .encodeABI();

    // Estimate gas for the transaction
    const gasEstimate = await web3.eth.estimateGas({
      from: tradeAccount.address,
      to: contractAddress,
      data,
    });

    // Create the transaction object
    const tx = {
      from: tradeAccount.address,
      to: contractAddress,
      data,
      gas: gasEstimate,
      // You might also want to specify gasPrice or use an oracle to determine a good gas price
    };

    // Sign the transaction
    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);

    // Send the transaction
    const receipt = await web3.eth.sendSignedTransaction(
      signedTx.rawTransaction
    );

    // Remove the account from the wallet after use
    web3.eth.accounts.wallet.remove(tradeAccount.address);

    // Get the tradeId from the transaction logs
    const tradeInitiatedEventSignature = web3.utils.sha3(
      "TradeInitiated(bytes32,address,string,string)"
    );
    const tradeInitiatedLog = receipt.logs.find(
      (log) => log.topics[0] === tradeInitiatedEventSignature
    );

    if (!tradeInitiatedLog) {
      throw new Error(
        "TradeInitiated event not found in the transaction receipt"
      );
    }

    // Decode the tradeId from the log
    const tradeId = web3.eth.abi.decodeParameter(
      "bytes32",
      tradeInitiatedLog.topics[1]
    );

    tradeIdManager[nextTradeId] = tradeId;
    currTradeId = nextTradeId;
    nextTradeId += 1;

    console.log(tradeId);
    // Send the transaction receipt and tradeId as the response
    res.json({
      success: true,
      transactionHash: receipt.transactionHash,
      currTradeId,
    });
  } catch (error) {
    console.error("Error initiating trade:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.post("/confirmTrade", async (req, res) => {
  try {
    // Destructure the required fields from the request body
    const { privateKeyAlias, currentTradeId } = req.body;

    let tradeId = tradeIdManager[currentTradeId];

    let privateKey;
    if (privateKeyAlias == "user1") {
      privateKey = process.env.USER_1_PRIVATE_KEY;
    } else if (privateKeyAlias == "user2") {
      privateKey = process.env.USER_2_PRIVATE_KEY;
    }

    // Validate the input
    if (!privateKey || !tradeId) {
      return res.status(400).send("Both privateKey and tradeId are required");
    }

    // Create an account object from the private key
    const tradeAccount = web3.eth.accounts.privateKeyToAccount(privateKey);
    web3.eth.accounts.wallet.add(tradeAccount);

    // Encode the confirmTrade function call
    const data = pokemonCollectorContract.methods
      .confirmTrade(tradeId)
      .encodeABI();

    // Estimate gas for the transaction
    const gasEstimate = await web3.eth.estimateGas({
      from: tradeAccount.address,
      to: contractAddress,
      data,
    });

    // Create the transaction object
    const tx = {
      from: tradeAccount.address,
      to: contractAddress,
      data,
      gas: gasEstimate,
      // You might also want to specify gasPrice or use an oracle to determine a good gas price
    };

    // Sign the transaction
    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);

    // Send the transaction
    const receipt = await web3.eth.sendSignedTransaction(
      signedTx.rawTransaction
    );

    // Remove the account from the wallet after use
    web3.eth.accounts.wallet.remove(tradeAccount.address);

    // Send the transaction receipt as the response
    res.json({ success: true, transactionHash: receipt.transactionHash });
  } catch (error) {
    console.error("Error confirming trade:", error);
    res.status(500).send("Internal Server Error");
  }
});


app.post("/catchPokemonAndMintNft", async (req, res) => {
  const userAddress = req.body['userAddress'];
  const pokemon = req.body['image_id'];

  try {
    // Step 1: Catch the Pokemon
    await catchPokemon(userAddress, pokemon);
    
    // Step 2: Mint the NFT
    const imageUploadResponse = await handleWeb3StorageUpload(req);

    const { label, ipfsUrl, tokenId, serialNumber } = { imageUploadResponse };

    // Step 3: Respond with success
    res.json({
      success: true,
      message: "Pokemon caught and NFT minted successfully",
      label: label,
      ipfsUrl: ipfsUrl,
      tokenId: tokenId,
      serialNumber: serialNumber,
    });
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ success: false, error: "Internal Server Error" });
  }
});



async function catchPokemonAndMintNft(userAddress, pokemon, req) {
  // Step 1: Catch the Pokemon
  await catchPokemon(userAddress, pokemon);
  
  // Step 2: Mint the NFT
  const imageUploadResponse = await handleWeb3StorageUpload(req);

  // Return the result
  return imageUploadResponse;
}

async function makeStorageClient() {
  const { default: fetch } = await import('node-fetch');
  return new Web3Storage({ token: web3StorageAPIKey, fetch });
}

async function makeFileObjects(name, image) {
  const obj = { name, image };
  const buffer = Buffer.from(JSON.stringify(obj));

  const files = [
    new File(["contents-of-file-1"], "plain-utf8.txt"),
    new File([buffer], "metadata.json"),
  ];
  return files;
}

async function storeFiles(files) {
  const client = await makeStorageClient();
  const cid = await client.put(files);
  return cid;
}

const fileFromPath = async (image, fileName) => {
  const filePath = image.tempFilePath;
  const mimeType = image.mimetype;

  const content = await fs.promises.readFile(filePath);
  const files = [
    new File(["contents-of-file-1"], mimeType),
    new File([content], fileName),
  ];

  return files;
};

async function createNftTokenType() {
  const client = Client.forTestnet();
  client.setOperator(operatorAccountId, operatorPrivateKey);

  const tokenCreateTx = await new TokenCreateTransaction()
    .setTokenName("WorldDex Capture")
    .setTokenSymbol("WLDD")
    .setTokenType(TokenType.NonFungibleUnique)
    .setSupplyType(TokenSupplyType.Infinite)
    .setTreasuryAccountId(operatorAccountId) // Explicitly set the treasury account
    .setSupplyKey(supplyKey) // Set the supply key
    .freezeWith(client);

  const tokenCreateSign = await tokenCreateTx.sign(operatorPrivateKey);
  const tokenCreateSubmit = await tokenCreateSign.execute(client);
  const tokenCreateRx = await tokenCreateSubmit.getReceipt(client);
  const tokenId = tokenCreateRx.tokenId;

  console.log(`Token type created: ${tokenId}`);
  return tokenId;
}

async function mintNft(username, label, metaDataCid, recipId) {
  const client = Client.forTestnet();
  client.setOperator(operatorAccountId, operatorPrivateKey);

  // Mint the NFT
  const shortString = `${label},${metaDataCid}`;
  const nftMintTx = await new TokenMintTransaction()
    .setTokenId(process.env.tokenId)
    .addMetadata(Buffer.from(shortString))
    .freezeWith(client);

  const nftMintSign = await nftMintTx.sign(supplyKey);
  const nftMintSubmit = await nftMintSign.execute(client);
  const nftMintRx = await nftMintSubmit.getReceipt(client);
  const serialNumber = nftMintRx.serials[0];
  /*
const associateRecipientTx = await new TokenAssociateTransaction()
.setAccountId(recipientAccountId)
.setTokenIds([tokenId])
.freezeWith(client)
.sign(receipientPrivateKey);

const associateRecipientTxSubmit = await associateRecipientTx.execute(client);

const associateRecipientRx = await associateRecipientTxSubmit.getReceipt(client);

console.log(`- NFT association with recipient's account: ${associateRecipientRx.status}\n`)
*/
  const tokenTransferTx = await new TransferTransaction()
    .addNftTransfer(
      process.env.tokenId,
      serialNumber,
      operatorAccountId,
      recipientAccountId
    )
    .freezeWith(client)
    .sign(operatorPrivateKey);

  const tokenTransferSubmit = await tokenTransferTx.execute(client);
  const tokenTransferRx = await tokenTransferSubmit.getReceipt(client);
  console.log(
    `\n- NFT transfer from Treasury to recipient: ${tokenTransferRx.status} \n`
  );

  console.log(
    `NFT Minted and Transferred: Token ID: ${process.env.tokenId}, Serial Number: ${serialNumber}, Recipient Account ID: ${recipientAccountId}`
  );

  let tID = tokenId;

  return { tID, serialNumber };
}

async function catchPokemon(userAddress, pokemon) {
  const data = pokemonCollectorContract.methods
    .catchPokemon(userAddress, pokemon)
    .encodeABI();

  const tx = {
    from: account.address,
    to: contractAddress,
    data,
    gas: 2000000,
    // Add gasPrice if necessary
  };

  const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);
  const receipt = await web3.eth.sendSignedTransaction(
    signedTx.rawTransaction
  );

  // You can handle specific errors here if necessary

  return receipt;
}

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
