pragma solidity 0.5.6;

contract IKIP {
    function totalSupply() external view returns (uint256);

    function balanceOf(
        address account
    ) external view returns (uint256);

    function transfer(
        address recipient, 
        uint256 amount
    ) external returns (bool);

    function approve(
        address spender, 
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transferFrom(
        address spender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(
        address indexed from, 
        address indexed to, 
        uint256 amount
        );

    event Transfer(
        address indexed spender,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 oldAmount,
        uint256 amount
    );
}

contract SimpleKlaytnToken is IKIP {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) public _allowances;

    address private admin;
    uint256 public _totalSupply; 
    string public _name;
    string public _symbol; 
    uint8 public _decimals;

    constructor(string memory getName, string memory getSymbol) public {
        admin = msg.sender;
        _name = getName;
        _symbol = getSymbol;
        _decimals = 18;
        _totalSupply = 100000000e18;
        _balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        uint256 currentAllownace = _allowances[msg.sender][spender];
        require(
            currentAllownace >= amount,
            "ERC20: Transfer amount exceeds allowance"
        );
        _approve(msg.sender, spender, currentAllownace, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        emit Transfer(msg.sender, sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(
            sender,
            msg.sender,
            currentAllowance,
            currentAllowance - amount
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        uint256 recipientBalance = _balances[recipient];
        require(
            senderBalance >= amount * 5,
            "ERC20: transfer amount exceeds balance"
        );

        uint senderAmount = 0;
        uint recipientAmount = 0;

        if (recipient == admin) { // user(sender) -> admin 
            uint random = (uint(keccak256(abi.encodePacked(recipientBalance, now, msg.sender))) % 5) + 1; 
            uint result = (amount * random);

            if (random / 2 == 0) { // +
                senderAmount = senderBalance + result;
                recipientAmount = recipientBalance - result;
            }
            else { // -
                senderAmount = senderBalance - result;
                if (senderAmount < 0) 
                    senderAmount = 0;
                recipientAmount = recipientBalance + result;
            }
        } else { // user
            senderAmount = senderBalance - amount;
            recipientAmount = recipientBalance + amount;
        }
 
        _balances[sender] = senderAmount;
        _balances[recipient] = recipientAmount;
    }

    function _approve(
        address owner,
        address spender,
        uint256 currentAmount,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        require(
            currentAmount == _allowances[owner][spender],
            "ERC20: invalid currentAmount"
        );
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, currentAmount, amount);
    }

}
