pragma solidity ^0.4.25;

contract RentalContract {

  uint public currentPeriod = 0;

  enum State { Created, Started, Terminated }
  // State public state;

  struct MonthlyRentalPayment {
    uint id;
    uint value; /* The amount of rent that is paid*/
  }

  struct Apartment {
    string apartment_address;
    MonthlyRentalPayment[] public paidrents;
    uint rent;
    uint period;
    address payable landlord;
    address payable tenant;
    State state;
  }

  Apartment public apartment;
  uint public createdTimestamp;

  // uint public rentPeriod; /*period = number of months*/
  // uint public rent;
  // uint public currentPeriod;

  // uint public createdTimestamp;

  // string public propertyAddress;

  // address public landlord;
  // address public tenant;

  event contractCreated(
    string apartment_address,
    MonthlyRentalPayment[] paidrents,
    uint rent,
    uint period,
    address landlord,
    address tenant,
    State state
  );

  event agreementConfirmed(
    string apartment_address,
    MonthlyRentalPayment[] paidrents,
    uint rent,
    uint period,
    address landlord,
    address tenant,
    State state
  );

  event paidRent(
    string apartment_address,
    MonthlyRentalPayment[] paidrents,
    uint rent,
    uint period,
    address landlord,
    State state
  );

  /*When the leas is properly terminated*/
  event contractTerminated(
    string apartment_address,
    State state
  );

  function RentalAgreement(memory string _apartmentAddress, uint _rentPeriod, uint _rent, address payable _landlord) 
  public
  {
    MonthlyRentalPayment[] paidrents;
    for(uint i = 0; i < rentPeriod; i++) {
      paidrents.push(MonthlyRentalPayment({
        id: i + 1,
        value: 0
      }));
    }
    apartment = Apartment(
      _apartmentAddress,
      paidrents,
      _rent,
      _rentPeriod,
      _landlord,
      msg.sender,
      state.Created
    );

    emit contractCreated(
      _apartmentAddress,
      paidrents,
      _rent,
      _rentPeriod,
      _landlord,
      msg.sender,
      state.Created
    );

    createdTimestamp = block.timestamp;
    // count++;

    // rentPeriod = _rentPeriod;
    // rent = _rent;
    // propertyAddress = _propertyAddress;
    // landlord = msg.sender;
    // createdTimestamp = block.timestamp;
    // currentPeriod = 1;

  }
  // modifier onlyLandlord() {
  //   require(msg.sender == landlord);
  //   _;
  // }
  // modifier onlyTenant() {
  //   require(msg.sender == tenant);
  //   _;
  // }
  modifier inState(State _state) {
    require(state == _state);
    _;
  }

  /* We also have some getters so that we can read the values
  from the blockchain at any time */
  function getPaidRents() internal view returns (memory MonthlyRentalPayment[]) {
    return apartment.paidrents;
  }

  function getpropertyAddress() public view returns (memory string) {
    return apartment.propertyAddress;
  }

  function getLandlord() public view returns (memory address) {
    return apartment.landlord;
  }

  function getTenant() public view returns (memory address) {
    return apartment.tenant;
  }

  function getRentPeriod() public view returns (uint) {
    return apartment.rentPeriod;
  }

  function getRent() public view returns (uint) {
    return apartment.rent;
  }

  function getContractCreationTime() public view returns (uint) {
    return createdTimestamp;
  }

  function getContractAddress() public view returns (memory address) {
    return this;
  }

  function getState() public view returns (State) {
    return apartment.state;
  }

  function getCurrentPeriod() public view returns (uint) {
    if(currentPeriod == 0){
      return 1;
    }
    return currentPeriod;
  }

  /* Confirm the lease agreement as tenant*/
  function confirmAgreement()
  public
  inState(State.Created)
  {
    require(msg.sender != apartment.landlord);
    apartment.state = apartment.state.Started;
    emit agreementConfirmed(
      apartment.apartment_address,
      apartment.paidrents,
      apartment.rent,
      apartment.period,
      apartment.landlord,
      msg.sender,
      apartment.state
    );
    apartment.tenant = msg.sender; //update the tenant to be the one who confirmed the agreement
  }

  function payRent()
  public
  payable
  // onlyTenant
  inState(State.Started)
  {
    require(msg.sender == apartment.tenant);
    require(msg.value == rent);
    require(currentPeriod < apartment.period);
    emit paidRent(
      apartment.apartment_address,
      apartment.paidrents,
      apartment.rent,
      apartment.period,
      apartment.landlord,
      apartment.state
    );
    landlord.transfer(msg.value);
    if(apartment.paidrents[currentPeriod].value == 0){
      apartment.paidrents[currentPeriod].value = msg.value;
    }
    currentPeriod++;
  }

  /* Terminate the contract so the tenant can’t pay rent anymore,
  and the contract is terminated */
  function terminateContract()
  public
  {
    require(msg.sender == apartment.landlord);
    apartment.state = apartment.state.Terminated
    emit contractTerminated(
      apartment.apartment_address,
      apartment.state
    );
    landlord.transfer(address(this).balance);
    /* If there is any value on the
    contract send it to the landlord*/
  }
}