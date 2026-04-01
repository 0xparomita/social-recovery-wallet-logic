// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SocialRecoveryWallet
 * @dev A wallet contract that can be recovered by trusted guardians.
 */
contract SocialRecoveryWallet is ReentrancyGuard {
    address public owner;
    mapping(address => bool) public isGuardian;
    uint256 public guardianCount;
    uint256 public threshold;

    struct RecoveryRequest {
        address proposedOwner;
        uint256 signatures;
        bool active;
    }

    mapping(address => RecoveryRequest) public recoveryRequests;
    mapping(address => mapping(address => bool)) public hasSigned;

    event RecoveryInitiated(address indexed proposedOwner, address indexed byGuardian);
    event RecoverySuccessful(address indexed oldOwner, address indexed newOwner);

    constructor(address _owner, address[] memory _guardians, uint256 _threshold) {
        require(_guardians.length >= _threshold, "Threshold too high");
        owner = _owner;
        threshold = _threshold;
        for (uint256 i = 0; i < _guardians.length; i++) {
            isGuardian[_guardians[i]] = true;
        }
        guardianCount = _guardians.length;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function execute(address to, uint256 value, bytes calldata data) external onlyOwner returns (bytes memory) {
        (bool success, bytes memory result) = payable(to).call{value: value}(data);
        require(success, "Execution failed");
        return result;
    }

    function initiateRecovery(address _newOwner) external {
        require(isGuardian[msg.sender], "Not a guardian");
        require(!recoveryRequests[_newOwner].active, "Recovery already active");

        recoveryRequests[_newOwner] = RecoveryRequest({
            proposedOwner: _newOwner,
            signatures: 1,
            active: true
        });
        hasSigned[_newOwner][msg.sender] = true;

        emit RecoveryInitiated(_newOwner, msg.sender);
    }

    function supportRecovery(address _newOwner) external {
        require(isGuardian[msg.sender], "Not a guardian");
        require(recoveryRequests[_newOwner].active, "No active request");
        require(!hasSigned[_newOwner][msg.sender], "Already signed");

        recoveryRequests[_newOwner].signatures++;
        hasSigned[_newOwner][msg.sender] = true;

        if (recoveryRequests[_newOwner].signatures >= threshold) {
            address oldOwner = owner;
            owner = _newOwner;
            recoveryRequests[_newOwner].active = false;
            emit RecoverySuccessful(oldOwner, _newOwner);
        }
    }

    receive() external payable {}
}
