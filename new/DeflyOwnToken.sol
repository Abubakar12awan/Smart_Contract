// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DeflyOwnToken is ERC20 {
    constructor() ERC20("DEFLY", "DEFLY") {
        _mint(msg.sender, 100000000 * 10**decimals());
    }
}
