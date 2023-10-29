# WorldDex
## Inspiration
As we go about our lives, all of us experience so much, witness so much, learn so much. When we were kids, exploration and excitement were a crucial part of every day, but as adults, responsibility can cause us to lose some of that magic. We wanted to remind each other that although we may not live in the Kanto region, the Earth still offers an enormous amount to see—and infinite amount to collect.

So, we built WorldDex. WorldDex is a real-life PokeDex (and so much more) that lets you scan and save anything into an ever-growing collection, offering a portal for you to learn, share, enjoy, and remember.

## What it does
WorldDex is primarily available through our mobile iOS application. Via this application, you can take a picture of any object and speak the name of what is being scanned into the interface. Be careful though! You have a limited number of catch tries per day.

Whether it's a simple lamp on your desk or a rare species of salamander, our app analyzes your image and spoken label, computing a catch probability which informs a roll of the dice. If you managed to catch your item, it is automatically added to your collection both in-app and on the blockchain. You also have the opportunity to record some information about where you were, who you were with, and any other details you're excited to include about your capture.

WorldDex allows you to have a spoken or written conversation with your collection about the items you have caught. All you need is a microphone, a speaker, and an object; from there, our intelligent models can tell you all about your item. This puts the knowledge of the world's best LLMs at your fingertips, just one scan away from a detailed educational discussion about some of your favorite memories.

Once you have completed a scan, WorldDex creates an NFT of your image. No need to panic—we are not crypto devs gearing for a rug-pull. Instead, the NFT means your ownership of that scan is provable and trade-able. Yes, someone can screenshot your NFT, but they will not be able to get it into their WorldDex!

On the social page, you can check out other people's scans and take a look at what your family, friends, and acquaintances have been collecting—in real time!

Your WorldDex account also comes with access to our web application. There, you can access a more dynamic view of your collection. Coming soon to the web version: detailed analytics, rarities, and more!

## How we built it
The workhorse of our mobile application is written in Swift, with iOS native speech-to-text translation and tons of custom styling and design. The app interacts with a variety of powerful back-ends:


**OBJECT DETECTION AND CAPTURE** are handled by an AWS EC2 instance with a Deep Learning AMI running PyTorch 2.0 with an NVIDIA T4 GPU. The instance runs inference on a state-of-the-art pre-trained zero-shot object detection model called GroundingDINO. 

_Associated technology: GroundingDINO, AWS EC2, PyTorch,  iOS speech-to-text, GPT-3.5 Turbo Instruct, GPT 4_

- A flask server runs on the EC2 instance. When the user takes a scan and speaks into their phone, iOS speech-to-text transcribes the user's message and sends both the image and the user's provided information to the back-end.

- GPT-3.5 Turbo Instruct (instruct-tuned version of GPT exceptionally good at executing novel, precise instructions) searches for the object label within the user's text.

- GroundingDINO uses the label as a prompt to search for all instances of an object in an instance. It assigns these instances with a confidence score, and the instance with the max confidence score (logits) is bounded and scanned. Whether or not the catch occurs is a function of this confidence score.


**DATA STORAGE AND BLOCKCHAIN INTERACTIONS** are handled by an intricate JavaScript microservice architecture. This back-end uses Node.js and Express to route across a variety of on and off-chain services. 

_Associated Technology: Hedera, CockroachDB, Express, web3.storage, Ethereum, IPFS_

- Database information (user account info, friends, image metadata, images, etc) are stored in a server-less CockroachDB instance. Through our endpoints, the back-end writes SQL queries to properly interact with the DB.

- When a catch is confirmed, the back-end uses the web3.storage framework to deploy the image onto IPFS for decentralized storage. Although a copy is maintained in our internal database for quick access, this grants the user the ability to share and interact with their image external to our centralized application.

- After a catch has been hosted by IPFS, our custom WLDD Token programmatically deployed on the open-source PoS Hedera network's testnet is used to mint an original NFT based on the image. This NFT contains in on-chain metadata a pointer to the IPFS metadataCID. The Hedera network offers straightforward and highly cost-effective functionality.

- Once the image has been stored on IPFS and an associated NFT has been minted, the unique ID we generate per image is granted to the user's collection on our custom Ethereum smart contract deployed on the Sepolia Testnet. Why the need for interactions with Ethereum AND Hedera? Our Ethereum smart contract allows for our own two-party trading functionality. However, we plan to deploy this EVM byte code to the Hedera network to simplify in the future.


**CHATTING WITH COLLECTION** is handled by another API hosted on the same EC2 instance used by the models. When the user records an audio message in the mobile app, we use iOS speech to text to transcribe thee message and send it to this API. The API uses GPT-4 to determine the response. Then, it uses the state-of-the-art text-to-speech model from ElevenLabs (with streaming functionality for minimized latency) to read out the model's response. 

_Associated Technology: GPT-4, ElevenLabs TTS, AWS EC2_


**THE WEB APPLICATION** is built with Reflex and backed by the same JavaScript API and databases as the other front-end. Here, we display a more dynamic interface meant to be more nostalgic of opening the PokeDex. However, we also wanted to include a web app to give us flexibility for future extensions, with the ability to display detailed visualizations, analytics, and more.

_Associated Technology: Reflex_


**We know that's a lot of text and a lot of technologies. So:** 

##The TLDR is: 
- your image and label are sent to a Python back-end, which use a combination of models to determine if you actually correctly identified what you scanned. If you did (and get a bit lucky), your catch completes. 

- At this point, we store a copy in a centralized CockroachDB server less database. We also store your image in a decentralized manner on IPFS, mint you an NFT on Hedera associated with the IPFS metadata, and register your ownership on Ethereum in case you want to start trading.

- The user can chat with an item from their collection. Their audio message is transcribed and sent to a back-end, which asks GPT-4 for a prompted response and plays this back with ElevenLabs Text-to-Speech for the user.

- There's also a Reflex web application, from which you can check out your collection. In the future, it offers a great home for more complex analytics and displays.

**DOUBLE TAP!**
- Check out our [Sepolia Ethereum Smart Contract](https://sepolia.etherscan.io/address/0x048Efe7fA4D562CC6B27aBEec0882B69dDc13f9C) (code in the GitHub Repo) governing trading.
- Check out what's being minted on our custom Hedera [WLDD Token](https://hashscan.io/testnet/token/0.0.5787090).
- Check out one of our [favorite IPFS hosted images](https://bafybeidtghyccwmqqswuxt2snz5b7yrq6gszu4zpzn7opduntmxo3lbw4m.ipfs.w3s.link/1698548676598_uploaded_image.jpg), which was recently collected and minted!

## Challenges we ran into

**HIGH LATENCY**
Our APIs are highly complex and interact with a variety of frameworks. This introduces latency and robustness issues. Specifically, on successful catch, we have to:
1. Perform speech-to-text with iOS built-in functionality
2. Analyze text using fine-tuned GPT 3.5
3. Identify instances of an object type using GroundingDINO and rank them by probability, selecting the highest probability one and determining if a catch will happen
4. Writing caught image and associated metadata to CockroachDB
5. Deploying caught image to IPFS
6. Minting NFT including IPFS metadata CID on Hedera
7. Transferring NFT from treasury to user
8. Logging catch onto Ethereum smart contract

To solve this problem, we divided this functionality into two portions: low-latency required and high-latency allowed. The user needs to know if they caught their object, which requires steps 1-3 to happen rapidly. To adjust, we used built-in iOS speech-to-text instead of a more general-purpose transcription model like the one offered by AssemblyAI (we tested it, but latency was too high). We used a fine-tuned version of GPT 3.5 Turbo Instruct, which is geared towards novel instruction types to reduce the performance tradeoff you get from avoiding the cost and time required by GPT-4. We also hosted on an AWS EC2 instance using a T4 GPU to speed up GroundingDINO computation.

Once the user has caught their item, we display a cached version of the image, allowing our back-end time to handle the higher-latency blockchain and database interactions.

**EXPLODING COMPLEXITY**
Our three back-ends threatened to create an exploding complexity problem which would have made debugging impossible. However, by siloing endpoints and routing related calls to more abstracted sections handling functionality, we were able to develop iteratively and minimize failure. We have:
- A set of independent endpoints handling Ethereum smart contract interactions
- A set of independent functions handling IPFS deployment
- A set of independent functions handling Hedera minting and transfer
- A set of endpoints wrapping IPFS deployment, Hedera interactions, and Ethereum calls into a single abstraction.
- A set of endpoints wrapping serverless CockroachDB functionality and caching.

We used a similar approach to carefully create an effective back-end for our AWS EC2 instance.

## Accomplishments that we are proud of
**User Interface and Design**
We had a vision for our application—to interweave the joy of exploration with the extraordinary nature of everyday life. Although our mobile app, back-ends, and models are far from perfect, we are incredibly excited at just how _fun_ it is for the four of us to scan random objects, talk to our collection, and share what we have discovered. 

**Integration of New Technologies**
We rapidly prototyped and iterated over a wide variety of new technologies. We knew just how extensible a real-life PokeDex could be; there were infinite directions to take! Using the sponsor list and our own field knowledge as inspiration, we tested out different APIs, frameworks, and models until we found the combination that matched our vision. Although this means we took an uncommon and often complex approach to our project, it has also resulted in some very cool functionality.

**Purposeful Incorporation of AI and Crypto**
We find using the blockchain or artificial intelligence simply because they exist to be a silly approach. Instead, as we read about different new technologies, we asked ourselves how their design aligns with our vision for WorldDex. We used a variety of state-of-the-art models for a plethora of functions, but nothing is casual; difference instances of GPT help to contextualize or explain, object-detection models... detect objects, text-to-speech models bring alive the PokeDex we remember from watching Cartoon Network as kids.

Meanwhile, decentralization lets us put the collection in the hands of the users. If we could, the model would be running on the blockchain too (trust us - we looked into some ideas related to that). While NFTs and smart contracts allow for trading, monetization, and a market economy, they more fundamentally mean that when you collect a picture, it's verifiably _yours_. Hedera lets us do these mints at a remarkably low cost.

## What we learned
It is hard to describe how much we learned in such a short period of time! We are frankly shocked at how many different technologies and functionalities we were able to weave into the same project in less than two days. 

**Model Comparison Shopping**
We learned a ton about different state-of-the-art models and their relative tradeoffs. We had to select the best models to our latency, accuracy, cost, and storage requirements. While we all know a lot about machine learning and artificial intelligence in the academic environment, watching the impact of different real-world models on these crucial in-production outcomes was fascinating.

**Crypto and Blockchain Integrations**
It is becoming increasingly clear that while adoption of crypto nosedives, technology and infrastructure for the field is exploding. We are ridiculously excited at how efficiently new crypto protocols and chains are offering high levels of programmability at low costs without sacrificing core blockchain principles. While we might still be most comfortable in Solidity, the once-painful smart contract programming process has gotten so much easier.

**Databases and Back-end Integrations**
It is remarkable how easy it is to get up and running on a database like CockroachDB, with direct SQL queries after minimal setup. High-performance back-ends interacting with a variety of different APIs and data storage solutions are increasingly viable every day. It was so much fun to construct one (or a couple) and watch them work in real-time.

And finally, a lot of what we learned and are excited about happens in what we did not use. In the future, we want to spend more time exploring vector databases for RAG, increased privacy chains and crypto-native languages, and more when extending this project and others.

## What's next for WorldDex

- We want to expand on the community. We imagine planned events in which scavenger hunts and collection events ask users to capture a certain subset of items in a set period or a set geographical location. Imagine: collect the SF 100 Set of Items in 24 hours to win a prize!
- We want to build out the social side of the application. Being able to interact with other users, trade more robustly, and create a more open marketplace will allow for tons of fun and has cool implications for rarity and more.
- We want to improve the educational features. While being able to talk with an object is a feature we are really happy about, augmenting GPT's ability to explain facts about an item with a vector database would supercharge our app's ability to teach. 
