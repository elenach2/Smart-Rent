pragma solidity ^0.4.25;

contract RentalContract {

  struct MonthlyRentalPayment {
    uint id;
    uint value; /* The amount of rent that is paid*/
  }

  MonthlyRentalPayment[] public paidrents;

  uint public rentPeriod; /*period = number of months*/
  uint public rent;
  uint public currentPeriod;

  uint public createdTimestamp;

  string public propertyAddress;

  address public landlord;
  address public tenant;

  enum State { Created, Started, Terminated }
  State public state;

  function RentalAgreement(uint _rentPeriod, uint _rent, string _propertyAddress) 
  public
  {
    rentPeriod = _rentPeriod;
    rent = _rent;
    propertyAddress = _propertyAddress;
    landlord = msg.sender;
    createdTimestamp = block.timestamp;
    currentPeriod = 1;

    for(uint i = 0; i < rentPeriod; i++) {
      paidrents.push(MonthlyRentalPayment({
        id: i + 1,
        value: 0
      }));
    }
  }
  modifier onlyLandlord() {
    require(msg.sender == landlord);
    _;
  }
  modifier onlyTenant() {
    require(msg.sender == tenant);
    _;
  }
  modifier inState(State _state) {
    require(state == _state);
    _;
  }

  /* We also have some getters so that we can read the values
  from the blockchain at any time */
  function getPaidRents() internal view returns (MonthlyRentalPayment[]) {
    return paidrents;
  }

  function getpropertyAddress() public view returns (string) {
    return propertyAddress;
  }

  function getLandlord() public view returns (address) {
    return landlord;
  }

  function getTenant() public view returns (address) {
    return tenant;
  }

  function getRentPeriod() public view returns (uint) {
    return rentPeriod;
  }

  function getRent() public view returns (uint) {
    return rent;
  }

  function getContractCreationTime() public view returns (uint) {
    return createdTimestamp;
  }

  function getContractAddress() public view returns (address) {
    return this;
  }

  function getState() public view returns (State) {
    return state;
  }

  event agreementConfirmed();

  event paidRent();

  /*When the leas is properly terminated*/
  event contractTerminated();

  /* Confirm the lease agreement as tenant*/
  function confirmAgreement()
  public
  inState(State.Created)
  {
    require(msg.sender != landlord);
    emit agreementConfirmed();
    tenant = msg.sender;
    state = State.Started;
  }

  function payRent()
  public
  payable
  onlyTenant
  inState(State.Started)
  {
    require(msg.value == rent);
    emit paidRent();
    landlord.transfer(msg.value);
    paidrents[currentPeriod].value = msg.value;
  }

  /* Terminate the contract so the tenant can’t pay rent anymore,
  and the contract is terminated */
  function terminateContract()
  public
  onlyLandlord
  {
    emit contractTerminated();
    landlord.transfer(address(this).balance);
    /* If there is any value on the
    contract send it to the landlord*/
    state = State.Terminated;
  }
}