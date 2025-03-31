/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  // const _HyperAGI_Node_Mgr = await ethers.getContractFactory('HyperAGI_Node_Mgr')

  // const HyperAGI_Node_Mgr = await upgrades.upgradeProxy('0xe138B94334eE720291EF5F7D926CbE18f9eeAB93', _HyperAGI_Node_Mgr)

  const implementationAddress = await upgrades.erc1967.getImplementationAddress('0x97a7194815d8699287473a378861950fc2042676')
  await run('verify:verify', {
    address: implementationAddress,
    constructorArguments: [],
  })
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
