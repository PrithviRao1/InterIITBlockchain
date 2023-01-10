// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BankRupee is ERC20 {
    
    uint LoanNo; //Keeps track of the last loan number given
    uint Time ; // The time of the bank server 
    uint TimeStart ;
    constructor() ERC20("BankRupee", "BR") {
        //_mint(address(this), 10**4 * 10**18); // minting 10,000 BR 
        Time = 0;
        LoanNo = 0;
    }
    struct Loan{
        address User; // Adress of the person who takes the loan
        uint StartTime; // Time at which the loan started
        uint BR; // The amount of BR given as principal in this loan
        bool Cleared;
    }
    function PassTime(uint T) public { // A function which increases the server time by T hours
        Time += T;
    }
    Loan[] public Loans;

    receive() external payable {}
    function TakeLoan() public payable returns (uint,uint){ // Function to take loan by giving ETH
        bool success = payable(address(this)).send(msg.value);
        require(success == true,"Transaction Failed");
        _mint(msg.sender,msg.value*100); // mints 100 times the number of ETH deposied into the User's account
        LoanNo += 1;
        Loans.push(Loan({
            User : msg.sender,
            StartTime : Time,
            BR : (msg.value)/(10**16), // Conversion to of ETH to BR 
            Cleared : false
        }));
        return (Loans[LoanNo-1].BR,LoanNo); // Returning the number of BR given as loan and the Loan Number
    }
    function CheckOwe(uint _LoanNo) public view returns (uint){ // Function to check how much you owe
        Loan storage L = Loans[_LoanNo-1];
        require(msg.sender == L.User,"Cannot Access details of another User's Loan");
        require(L.Cleared == false,"Loan has already been cleared");
        return ((10*L.BR)+(Time -L.StartTime)*L.BR)/10;
    }
    function ClearLoan(uint x , uint _LoanNumber) public payable {
        Loan storage L = Loans[_LoanNumber-1];
        require(L.Cleared == false);
        require(L.User == msg.sender);
        require(x == ((10*L.BR)+(Time -L.StartTime)*L.BR)/10,"Please pay the right amount of BR tokens to clear this Loan");
        bool success2 = transfer(address(this),((10*L.BR)+(Time -L.StartTime)*L.BR)*10**17);
        require(success2 = true,"Transaction Failed");
        bool success = payable(msg.sender).send(L.BR*10**16);
        require(success == true,"Transaction Failed");
        
        L.BR = L.BR*(Time -L.StartTime)/10; // Stores the Profit 
        L.Cleared = true;
    }
    // A function for the User to get extra BR , so that he can repay the loan with interest
    // won't exist in a practical implementation
    function Generate(uint x) public {
        _mint(msg.sender , x*10**18);
    }
}
