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
    uint rent;
    uint period;
    address landlord;
    address tenant;
    State state;
  }

  Apartment public apartment = Apartment("Bazel 50/2", 10000000000000000, 12, 0x05ecf7828f8AC1f438A0c27641E696a448b86B7B, 0xea53bCA6e4e3FAd60820B427EE4426071c92a00F, State.Created);
  mapping(uint256 => MonthlyRentalPayment) public paidrents;

  uint public createdTimestamp;

  event contractCreated();
  event agreementConfirmed();
  event paidRent();
  event contractTerminated();

  function RentalAgreement()
  public
  {
    for(uint i = 0; i < apartment.period; i++) {
      paidrents[i] = (MonthlyRentalPayment({ id: i + 1, value: 0 }));
    }
    emit contractCreated();
    createdTimestamp = block.timestamp;
  } 
  modifier inState(State _state) {
    require(apartment.state == _state);
    _;
  }

  /* We also have some getters so that we can read the values
  from the blockchain at any time */
  function getCurrentPeriod() public view returns (uint) {
    if(currentPeriod == 0){
      return 1;
    }
    return currentPeriod;
  }
  

  /* Confirm the lease agreement as tenant*/
  function confirmAgreement()
  public
  payable
  inState(State.Created)
  {
    require(msg.sender != apartment.landlord);
    apartment.state = State.Started;
    emit agreementConfirmed();
    apartment.tenant = msg.sender; //update the tenant to be the one who confirmed the agreement
  }

  function payRent()
  public
  payable
  // onlyTenant
  inState(State.Started)
  {
    require(msg.sender == apartment.tenant);
    require(msg.value == apartment.rent);
    require(currentPeriod < apartment.period);
    emit paidRent();
    if(msg.value == apartment.rent)
    {
      apartment.landlord.transfer(msg.value);
    } else {
      apartment.landlord.transfer(1);
    }
    if(paidrents[currentPeriod].value == 0){
      paidrents[currentPeriod].value = msg.value;
    }
    currentPeriod++;
  }

  /* Terminate the contract so the tenant can’t pay rent anymore,
  and the contract is terminated */
  function terminateContract()
  public
  payable
  {
    require(msg.sender == apartment.landlord);
    apartment.state = State.Terminated;
    emit contractTerminated();
    apartment.landlord.transfer(address(this).balance);
    /* If there is any value on the
    contract send it to the landlord*/
  }
}