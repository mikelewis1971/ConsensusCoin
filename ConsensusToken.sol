// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IUniswapV3Pool {
    function slot0() external view returns (
        uint160 sqrtPriceX96,
        int24   tick,
        uint16  observationIndex,
        uint16  observationCardinality,
        uint16  observationCardinalityNext,
        uint8   feeProtocol,
        bool    unlocked
    );
}

contract ConsensusCoin {
    // 🔒 Immutable hardcoded fee recipient
    address public constant owner = 0x0F6dbb5B71372aB1d77Ed67D1260083cF9f07476;

    // 💰 Economic rules
    uint256 public constant FEE = 1 ether;             // Always 1 POL
    uint256 public constant CAP = 100_000_000;         // Max tokens per mint

    // 🧠 On-chain Uniswap V3 price oracles (Polygon PoS)
address constant ETH_USDC_POOL = 0x45dDa9cb7c25131DF268515131f647d726f50608;
address constant BTC_USDC_POOL = 0xeEF1A9507B3D505f0062f2be9453981255b503c8;



    // 📦 Storage
    mapping(bytes32 => uint256) public totalSupply;
    mapping(bytes32 => bool)    public consensusReached;
    mapping(bytes32 => mapping(address => uint256)) public balances;

    // 🧾 Events
    event Mint(address indexed by, address indexed to, string name, uint256 amount);
    event Burn(address indexed from, string name, uint256 amount);
    event Consensus(string name, bytes32 indexed id);

    constructor() {
        require(block.chainid == 137, "Only Polygon");
    }

    // 🧮 Generate a salt by summing Uniswap V3 pool sqrtPrices
    function _generateSalt() internal view returns (bytes32) {
        (uint160 ethSqrt, , , , , , ) = IUniswapV3Pool(ETH_USDC_POOL).slot0();
        (uint160 btcSqrt, , , , , , ) = IUniswapV3Pool(BTC_USDC_POOL).slot0();
        return bytes32(uint256(ethSqrt) + uint256(btcSqrt));
    }

    // 🔗 Unique ID from name + salt
    function _setId(string memory name) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(name, _generateSalt()));
    }

    /// Mint `amount` tokens with given `name`, paying 1 POL, to `to`
    function mint(string calldata name, uint256 amount, address to) external payable {
        require(msg.value == FEE, "Send 1 POL");
        require(amount > 0 && amount <= CAP, "Amount too big or zero");
        require(to != address(0), "Invalid recipient");
        require(bytes(name).length > 0 && bytes(name).length <= 64, "Bad name");

        bytes32 id = _setId(name);
        require(!consensusReached[id], "Already finalized");

        balances[id][to] += amount;
        totalSupply[id] += amount;

        (bool ok, ) = owner.call{value: msg.value}("");
        require(ok, "Fee failed");

        emit Mint(msg.sender, to, name, amount);
    }

    /// Burn `amount` tokens from msg.sender for the given name
    function burn(string calldata name, uint256 amount) external {
        bytes32 id = _setId(name);
        uint256 bal = balances[id][msg.sender];
        require(amount > 0 && bal >= amount, "Not enough to burn");

        balances[id][msg.sender] = bal - amount;
        totalSupply[id] -= amount;

        emit Burn(msg.sender, name, amount);

        if (totalSupply[id] == 0 && !consensusReached[id]) {
            consensusReached[id] = true;
            emit Consensus(name, id);
        }
    }

    /// View current balance of user in a named token set
    function balanceOf(string calldata name, address user) external view returns (uint256) {
        return balances[_setId(name)][user];
    }

    /// View if consensus has been reached for a given name
    function hasConsensus(string calldata name) external view returns (bool) {
        return consensusReached[_setId(name)];
    }
}
