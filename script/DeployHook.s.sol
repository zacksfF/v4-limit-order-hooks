// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.24;

// import "forge-std/Script.sol";
// import "../src/hooks/LimitOrderHook.sol";
// import "../src/interfaces/IPoolManager.sol";

// contract DeployHook is Script {
//     function run() external {
//         vm.startBroadcast();

//         // deploy mock PoolManager
//         address mockManager = address(new IPoolManager(){});

//         LimitOrderHook hook = new LimitOrderHook(mockManager);
//         console.log("Deployed LimitOrderHook at:", address(hook));

//         vm.stopBroadcast();
//     }
// }
