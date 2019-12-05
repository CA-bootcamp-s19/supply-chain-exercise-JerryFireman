pragma solidity ^0.5.0;

contract SupplyChain {

  // @dev Owner of the contract
  address public owner;

  // @dev Tracks the most recent sku number
  uint internal skuCount;

  // @dev Maps sku numbers to their associated item
  mapping (uint => Item) public items;

  // @dev Represents the possible states of an item
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

  /* Add a keyword so the function can be paid. This function should transfer money
    to the seller, set the buyer as the person who called this transaction, and set the state
    to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent. Remember to call the event associated with this function!*/

  function buyItem(uint sku)
    public
  {}

  /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
  is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
  function shipItem(uint sku)
    public
  {}

  /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
  is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
  function receiveItem(uint sku)
    public
  {}

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
