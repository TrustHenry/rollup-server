import "@nomiclabs/hardhat-ethers";
import * as hre from "hardhat";
import { Block, BlockHeader, Hash, hashFull } from "rollup-pm-sdk";
import { RollUp } from "../../../typechain-types";

export class RollUpContractManager {
    /**
     * Constructor
     */
    constructor() {
    }

    public static async addBlockHeader(header:BlockHeader, CID:string) {
        try {
            const rollUpFactory = await hre.ethers.getContractFactory("RollUp");
            const rollUpContract:RollUp = rollUpFactory.attach(process.env.ROLLUP_CONTRACT || "") as RollUp;

            await rollUpContract.add(header.height,
                hashFull(header).toBinary() ,
                header.prev_block.toBinary(),

                
                header.merkle_root.toBinary(),
                header.timestamp,
                CID);




            console.log("RollUpContract address :", rollUpContract.address);
        } catch (error) {

            console.error(`Failed to get rollUp contract: ${error}`);
            process.exit(1);
        }
    }

    public static async deployRollUpContract() {
        const provider = hre.ethers.provider;
        const manager = new hre.ethers.Wallet(process.env.MANAGER_KEY || "");
        const manager_signer = provider.getSigner(manager.address);
        const RollUpFactory = await hre.ethers.getContractFactory("RollUp");
        const contract = await RollUpFactory.connect(manager_signer).deploy();
        await contract.deployed().then((contract) => {
            return contract;
        }).catch((reason) => {
            return new Error(reason);
        });
    }
}
