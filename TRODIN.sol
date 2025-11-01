// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TRODIN is ERC20, Ownable {
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10**18;
    uint256 public constant FEE_RATE = 30; // 0.3%
    uint256 public constant BURN_RATE = 30; // 0.3%
    uint256 public constant DENOMINATOR = 10000;

    address public relayer;
    uint256 public usdToTrodinRate = 100; // 1 USD = 100 TRODIN

    event FiatPayment(address indexed player, uint256 usdCents, uint256 trodinMinted);
    event FeeCollected(address indexed to, uint256 amount);
    event Burned(address indexed from, uint256 amount);

    constructor(address _relayer, address initialOwner) ERC20("TRODIN", "TRODIN") Ownable(initialOwner) {
        relayer = _relayer;
        _mint(initialOwner, TOTAL_SUPPLY);
    }

    modifier onlyRelayer() {
        require(msg.sender == relayer, "Not relayer");
        _;
    }

    function mintFromFiat(address player, uint256 usdCents) external onlyRelayer {
        uint256 trodinAmount = usdCents * usdToTrodinRate;
        uint256 fee = (trodinAmount * FEE_RATE) / DENOMINATOR;
        uint256 burn = (trodinAmount * BURN_RATE) / DENOMINATOR;
        uint256 net = trodinAmount - fee - burn;

        _mint(player, net);
        _mint(owner(), fee);
        _burn(address(this), burn);

        emit FiatPayment(player, usdCents, net);
        emit FeeCollected(owner(), fee);
        emit Burned(address(this), burn);
    }

    function setRelayer(address newRelayer) external onlyOwner {
        relayer = newRelayer;
    }

    function setUsdToTrodinRate(uint256 newRate) external onlyOwner {
        usdToTrodinRate = newRate;
    }

    function withdrawFees(uint256 amount) external onlyOwner {
        _transfer(address(this), owner(), amount);
    }
}
