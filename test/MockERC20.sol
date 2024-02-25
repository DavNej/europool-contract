// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    uint256 public constant INITIAL_SUPPLY = 1000000 ether;

    constructor() ERC20("Test Token", "TOK") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
