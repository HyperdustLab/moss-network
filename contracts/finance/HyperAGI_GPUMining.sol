import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "../utils/StrUtil.sol";

contract HyperAGI_GPUMining is OwnableUpgradeable, AccessControlUpgradeable {
    using Strings for *;
    using StrUtil for *;

    using Math for uint256;

    uint256 public _GPUMiningTotalAward;

    uint256 private _GPUMiningCurrMiningRatio;

    uint256 constant FACTOR = 10 ** 18 * 100;

    uint256 private _GPUMiningCurrYearTotalSupply;

    uint256 public _epochAward;

    uint256 private _GPUMiningCurrYearTotalAward;

    uint256 private _GPUMiningReleaseInterval;

    uint256 private _GPUMiningRateInterval;

    uint256 private _GPUMiningAllowReleaseTime;

    uint256 private _lastGPUMiningRateTime;

    uint256 public _lastGPUMiningMintTime;

    uint256 public _GPUMiningCurrAward;

    uint256 public _TGE_timestamp;

    receive() external payable {}

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    function initialize(address onlyOwner, uint256 GPUMiningReleaseInterval) public initializer {
        __Ownable_init(onlyOwner);
        _grantRole(DEFAULT_ADMIN_ROLE, onlyOwner);

        _GPUMiningTotalAward = (210000000 ether * 57) / 100;
        _GPUMiningCurrMiningRatio = 10 * 10 ** 18;
        _GPUMiningCurrYearTotalSupply = Math.mulDiv(_GPUMiningTotalAward, _GPUMiningCurrMiningRatio, FACTOR);

        _epochAward = _GPUMiningCurrYearTotalSupply / 365 / 225;

        _GPUMiningReleaseInterval = GPUMiningReleaseInterval;
        _GPUMiningRateInterval = 4 * GPUMiningReleaseInterval;
    }

    function getGPUMiningCurrAllowMintTotalNum() public view returns (uint256, uint256, uint256) {
        require(_GPUMiningAllowReleaseTime > 0, "The commencement of the release of GPU mining has not yet commenced");

        uint256 GPUMiningCurrMiningRatio = _GPUMiningCurrMiningRatio;
        uint256 GPUMiningCurrYearTotalAward = _GPUMiningCurrYearTotalAward;

        uint256 GPUMiningCurrYearTotalSupply = _GPUMiningCurrYearTotalSupply;

        uint256 epochAward = _epochAward;

        if (block.timestamp >= _lastGPUMiningRateTime + _GPUMiningRateInterval) {
            GPUMiningCurrMiningRatio = Math.mulDiv(GPUMiningCurrMiningRatio, FACTOR, 2 * FACTOR);

            require(GPUMiningCurrMiningRatio > 0, "currMiningRatio is 0");
        }

        if (block.timestamp >= _GPUMiningAllowReleaseTime + _GPUMiningReleaseInterval) {
            GPUMiningCurrYearTotalAward = 0;

            GPUMiningCurrYearTotalSupply = Math.mulDiv(_GPUMiningTotalAward - _GPUMiningCurrAward, GPUMiningCurrMiningRatio, FACTOR);

            epochAward = GPUMiningCurrYearTotalSupply / 365 / 225;
        }

        if (block.timestamp >= _GPUMiningAllowReleaseTime) {
            if (block.timestamp - _lastGPUMiningMintTime >= 384) {
                return (GPUMiningCurrYearTotalSupply - GPUMiningCurrYearTotalAward, GPUMiningCurrYearTotalSupply, epochAward);
            } else {
                return (0, GPUMiningCurrYearTotalSupply, epochAward);
            }
        } else {
            return (0, 0, epochAward);
        }
    }

    function mint(address payable account, uint256 mintNum) public onlyRole(MINTER_ROLE) {
        require(_TGE_timestamp > 0, "TGE_timestamp is not started");

        if (block.timestamp >= _lastGPUMiningRateTime + _GPUMiningRateInterval) {
            _GPUMiningCurrMiningRatio = _GPUMiningCurrMiningRatio / 2;
            require(_GPUMiningCurrMiningRatio > 0, "currMiningRatio is 0");

            _lastGPUMiningRateTime += _GPUMiningRateInterval;
        }

        if (block.timestamp >= _GPUMiningAllowReleaseTime + _GPUMiningReleaseInterval) {
            _GPUMiningCurrYearTotalAward = 0;

            _GPUMiningAllowReleaseTime += _GPUMiningReleaseInterval;

            _GPUMiningCurrYearTotalSupply = Math.mulDiv(_GPUMiningTotalAward - _GPUMiningCurrAward, _GPUMiningCurrMiningRatio, FACTOR);

            _epochAward = _GPUMiningCurrYearTotalSupply / 365 / 225;
        }

        require(_GPUMiningCurrYearTotalSupply - _GPUMiningCurrYearTotalAward - mintNum >= 0, "currYearTotalSupply is not enough");

        require(_GPUMiningTotalAward - _GPUMiningCurrAward - mintNum >= 0, "GPUMiningTotalAward is not enough");

        require(_epochAward >= mintNum, string(abi.encodePacked("epochAward (", _epochAward.toString(), ") is not enough for mintNum (", mintNum.toString(), ")")));

        _GPUMiningCurrYearTotalAward += mintNum;
        _GPUMiningCurrAward += mintNum;

        _lastGPUMiningMintTime = block.timestamp;

        transferETH(account, mintNum);
    }

    function startTGE(uint256 TGE_timestamp) public onlyOwner {
        require(_TGE_timestamp == 0, "TGE_timestamp is started");

        _TGE_timestamp = TGE_timestamp;

        _GPUMiningAllowReleaseTime = TGE_timestamp;
        _lastGPUMiningMintTime = TGE_timestamp;
    }

    function transferETH(address payable recipient, uint256 amount) private {
        require(address(this).balance >= amount, "Insufficient balance in contract");
        recipient.transfer(amount);
    }

    function recalculateGPUMiningTotalAward() public onlyOwner {
        _GPUMiningTotalAward = (210000000 ether * 48) / 100;
        _GPUMiningCurrMiningRatio = 10 * 10 ** 18;
        _GPUMiningCurrYearTotalSupply = Math.mulDiv(_GPUMiningTotalAward, _GPUMiningCurrMiningRatio, FACTOR);

        _epochAward = _GPUMiningCurrYearTotalSupply / 365 / 225;
        _GPUMiningRateInterval = 4 * _GPUMiningReleaseInterval;
    }

    function getEpochAward() public view returns (uint256) {
        uint256 GPUMiningCurrMiningRatio = _GPUMiningCurrMiningRatio;
        uint256 GPUMiningCurrYearTotalSupply = _GPUMiningCurrYearTotalSupply;
        uint256 epochAward = _epochAward;

        if (block.timestamp >= _lastGPUMiningRateTime + _GPUMiningRateInterval) {
            GPUMiningCurrMiningRatio = GPUMiningCurrMiningRatio / 2;
            require(GPUMiningCurrMiningRatio > 0, "currMiningRatio is 0");

            GPUMiningCurrYearTotalSupply = Math.mulDiv(_GPUMiningTotalAward - _GPUMiningCurrAward, GPUMiningCurrMiningRatio, FACTOR);
            epochAward = GPUMiningCurrYearTotalSupply / 365 / 225;
        }

        if (block.timestamp >= _GPUMiningAllowReleaseTime + _GPUMiningReleaseInterval) {
            GPUMiningCurrYearTotalSupply = Math.mulDiv(_GPUMiningTotalAward - _GPUMiningCurrAward, GPUMiningCurrMiningRatio, FACTOR);
            epochAward = GPUMiningCurrYearTotalSupply / 365 / 225;
        }

        return epochAward;
    }
}
