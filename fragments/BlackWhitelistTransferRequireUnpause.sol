// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract BlackwhitelistTransferRequireUnPause is IMoon {

    address public _owner;
    bool private _paused;

    // token balances
    // allowances 
    // blacklist and whitelist
    // modifier to restrict function access to the owner
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private blacklisted;
    mapping(address => bool) private whitelisted;
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "nah bro, not your function");
        _;
    }

    modifier whenPaused() {
        require(_paused, "pause : yes");
        _;
    }

    modifier whenNotPaused() {
        require(!_paused, "pause : no");
        _;
    }


    // set contract deployer the owner
    constructor() {
        _owner = msg.sender;
    }

    function renounceOwnership() public override(IMoon) onlyOwner {
        _owner = address(0);
    }
    
    function approve(address spender, uint amount) public override(IMoon) returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    //transfer tokens _from/_to address
    function transferFrom(address sender, address recipient, uint amount) public override(IMoon) returns (bool) {
        require(balanceOf[sender] >= amount, "error amount token");
        require(!isBlacklisted(msg.sender), "user in blacklisted");
        require(!isBlacklisted(recipient), "user in blacklisted");

            // if sender is not msg.sender, check allowance
            if (msg.sender != sender) {
                require(allowance[sender][msg.sender] >= amount, "Insufficient allowance");
                allowance[sender][msg.sender] -= amount;
            }
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }   

    function transfer(address recipient, uint amount) public override(IMoon) returns (bool) {
        return transferFrom(msg.sender, recipient, amount);
    }

    //check address is blacklisted
    function isBlacklisted(address account) public view returns (bool) {
        return blacklisted[account];
    }

    // add account to blacklist
    function _addToBlacklist(address account) public onlyOwner {
        blacklisted[account] = true;
        emit AddedToBlacklist(account);
    }

    // delete account from blacklist
    function _removeFromBlacklist(address account) public onlyOwner {
        blacklisted[account] = false;
        emit RemovedFromBlacklist(account);
    }

    //check address is whitelisted
    function isWhitelisted(address account) public view returns (bool) {
        return whitelisted[account];
    }

    // add account to whitelist
    function _addToWhitelist(address account) public onlyOwner {
        whitelisted[account] = true;
        emit AddedToWhitelist(account);
    }

    // delete account from whitelist
    function _removeFromWhitelist(address account) public onlyOwner {
        whitelisted[account] = false;
        emit RemovedFromWhitelist(account);
    }

    // checking pause contract
    function paused() external view returns (bool) {
        return _paused;
    }

    // stop contract
    function pause() external onlyOwner {
        _paused = true;
        emit Paused(msg.sender);
    }

    // start contract
    function unpause() external onlyOwner {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}
