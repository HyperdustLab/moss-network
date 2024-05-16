/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const contract = await ethers.getContractFactory('Hyperdust_GPUMining')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address, 60 * 60 * 24 * 365])
  await instance.waitForDeployment()

  await (await instance.setHyperdustTokenAddress('0x4e09099bBf643b22fDfc9405189B05D90FCCDa3B')).wait()

  await (await instance.startTGE(1715827656)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
