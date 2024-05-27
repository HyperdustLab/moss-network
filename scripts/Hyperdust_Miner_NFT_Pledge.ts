/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const _Hyperdust_Storage = await ethers.getContractFactory('Hyperdust_Storage')
  const Hyperdust_Storage = await upgrades.deployProxy(_Hyperdust_Storage, [process.env.ADMIN_Wallet_Address])
  await Hyperdust_Storage.waitForDeployment()

  const contract = await ethers.getContractFactory('Hyperdust_Miner_NFT_Pledge')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  // console.info('Hyperdust_Storage:', Hyperdust_Storage.target)

  await (await Hyperdust_Storage.setServiceAddress(instance.target)).wait()

  await (await instance.setContractAddress(['0x9D88106Ba510D3852eC03B22b8F754F2bcd16739', Hyperdust_Storage.target, '0x63E3dDdbA7d0778a8c1d493F6d6b8Bc0E95f2a96', '0x9b7339B4FE58A2541d4e87FC6e6e35Dc9cBc77D5'])).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
