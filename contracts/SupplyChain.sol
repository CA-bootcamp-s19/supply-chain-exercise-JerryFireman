pragma solidity ^0.5.0;

contract SupplyChain {

  // @dev Owner of the contract
  address public owner;

  // @dev Tracks the most recent sku number
  uint internal skuCount;

  // @dev Maps sku numbers to their associated Item
  mapping (uint => Item) public items;

  // @dev Represents the possible states of an Item
  enum State { ForSale, Sold, Shipped, Received }
  State public state;

  // @dev Goods handled by the supply chain
  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }

  // @dev Events correspond to each possible state
  event LogForSale(uint sku);
  event LogSold(uint sku);
  event LogShipped(uint sku);
  event LogReceived(uint sku);

  // @dev Checks if the msg.sender is the owner of the contract
  modifier onlyOwner () {
    require(msg.sender == owner, "Message sender is not owner of contract");
     _;
  }

  // @dev Checks if the message sender is a specfic address
  // @param _address The address the message is supposed to come from
  modifier verifyCaller (address _address) {
    require (msg.sender == _address, "Message sender is not required address");
    _;
  }

  // @dev Checks if the customer sent enough to pay for items
  // @param _price The price of the item
  modifier paidEnough(uint _price) {
    require(msg.value >= _price, "the customer did not send enough to pay for the item");
     _;
  }
    
  // @dev Refunds buyers that overpay for items
  // @param _sku Sku number of purchased item
  modifier checkValue(uint _sku) {
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }

  // @dev Checks that state of item is ForSale
  // @param _sku Sku number of item to be checked
  modifier forSale (uint _sku) {
    require(items[_sku].state == State.ForSale && items[_sku].price != 0, "Item is not for sale");
    _;
  }

  // @dev Checks that state of item is Sold
  // @param _sku Sku number of item to be checked
  modifier sold (uint _sku) {
    require(items[_sku].state == State.Sold , "Item is not sold");
    _;
  }

  // @dev Checks that state of item is Shipped
  // @param _sku Sku number of item to be checked
  modifier shipped (uint _sku) {
    require(items[_sku].state == State.Shipped , "Item is not shipped");
    _;
  }

  // @dev Checks that state of item is Received
  // @param _sku Sku number of item to be checked
  modifier received (uint _sku) {
    require(items[_sku].state == State.Received , "Item is not received");
    _;
  }

  // @dev Sets owner to the address that instantiated the contract
  constructor() public {
    owner = msg.sender;
    skuCount = 0;
  }

  // @dev Adds item to goods for sale
  // @param _name Name of item
  // @param _price Price of item
  function addItem(string memory _name, uint _price) public returns(bool) {
    emit LogForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
    skuCount = skuCount + 1;
    return true;
  }

  // @dev Called by the buyer to purchase an item
  // @param _sku Sku number of item being purchased
  function buyItem(uint _sku)
    public
    payable
    forSale(_sku)
    paidEnough(_sku)
    checkValue(_sku)
  {
    items[_sku].buyer = msg.sender;
    items[_sku].state = State.Sold;
    items[_sku].seller.transfer(items[_sku].price);
    emit LogSold(_sku);
  }

  // @dev Called by the seller to ship an item
  // @param _sku Sku number of item being purchased
  function shipItem(uint _sku)
    public
    sold(_sku)
    verifyCaller(items[_sku].seller)
  {
    items[_sku].state = State.Shipped;
    emit LogShipped(_sku);
  }

  // @dev Called by the buyerer to receive an item
  // @param _sku Sku number of item being received
  function receiveItem(uint _sku)
    public
    shipped(_sku)
    verifyCaller(items[_sku].buyer)
  {
    items[_sku].state = State.Received;
    emit LogReceived(_sku);
  }

  // @dev This function included only for use in running tests
  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }
}
