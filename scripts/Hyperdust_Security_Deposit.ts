/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const _Hyperdust_Storage = await ethers.getContractFactory('Hyperdust_Storage')
  const Hyperdust_Storage = await upgrades.deployProxy(_Hyperdust_Storage, [process.env.ADMIN_Wallet_Address])
  await Hyperdust_Storage.waitForDeployment()

  const contract = await ethers.getContractFactory('Hyperdust_Security_Deposit')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  await (await Hyperdust_Storage.setServiceAddress(instance.target)).wait()

  await (await instance.setContractAddress(['0x9bDaf3912e7b4794fE8aF2E748C35898265D5615', '0x4e09099bBf643b22fDfc9405189B05D90FCCDa3B', Hyperdust_Storage.target, '0x9b7339B4FE58A2541d4e87FC6e6e35Dc9cBc77D5', '0xFc64b7e8A0062693B4dE78D6d5014DcA677B4372'])).wait()

  const Hyperdust_Roles_Cfg = await ethers.getContractAt('Hyperdust_Roles_Cfg', '0x9bDaf3912e7b4794fE8aF2E748C35898265D5615')
  await (await Hyperdust_Roles_Cfg.addAdmin(instance.target)).wait()

  console.info('Hyperdust_Storage:', Hyperdust_Storage.target)

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
