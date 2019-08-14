pragma solidity ^0.4.4;

/* 
Eric Munsing - e.munsing@berkeley.edu
MIT license    2017

GOAL: 
- Accept estimates of state variables from each devices
- Publish an updated aggregator aggregator variable when all state estimates have been recieved
- Once the error between estimates is small, stop computing iterations
- Save the schedule for all nodes on the network

PSEUDOCODE:
- Store a set of whitelisted devices (this may be changed later)

- Initialize at iteration zero
- For each iteration, accept one estimate from each device
  - Check to make sure that the device hasn't submitted an estimate yet
  - Check to make sure that the estimate is for the current iteration
  - Check to make sure we haven't already generated a schedule
- Once estimates from all devices have been submitted for the iteration,
  - Compute and save the aggregator average
  - Compute the error
  - If the error is below the threshhold, save the schedule and flag that the schedule is complete
  - Otherwise, 
    - Increment the iteration
    - Begin accepting estimates from all devices
- Once the schedule is saved, don't do anything (in the future, this should reset on each market clearing block)
*/ 

/* TO-DO:

- Turn variables into vectors
- Include all consensus variables
- Compute full aggregator averaging step
- 

*/

contract Aggregator {
	// ADMM aggregator step
	struct Estimate{
		int256 P;   // There are no fixed-point or floating-point variables in Ethereum. Multiply by 1e9 instead
	}

	address   owner;
	uint16    public iteration;
	uint256   public tolerance;
	uint256   public iterationError;
	address[] public whitelist;
	mapping (address => bool) public waiting;
	mapping (address => Estimate) public allEstimates;
	Estimate  public average;
	bool      public scheduleComplete;
	Estimate  public schedule;

    /* CONSTRUCTOR */
    function Aggregator(address[] _whitelist) public{
    	scheduleComplete = false;
    	owner = msg.sender;
    	whitelist = _whitelist;
        iteration = 0;
        resetWaiting();  // Set the waiting flag to 1 for everybody
    }
     
    function whitelistLength () returns (uint256){
    	return whitelist.length;
    }

    function stillWaiting () returns (bool) {
        for (uint8 i=0; i<whitelist.length; i++){
            if (waiting[whitelist[i]]){ return true; }
        }
        return false;
    }

    function submitValue (int256 myGuess, uint16 myiteration) {
    	if (scheduleComplete)        { throw; }
    	if (myiteration != iteration){ throw; }

    	if (waiting[msg.sender]){
    		waiting[msg.sender] = false;
    		allEstimates[msg.sender].P = myGuess;	
    	} else {
    		throw;
    	}

    	if (! stillWaiting() ){
    		computeAverage();
    		resetWaiting();
    		iteration += 1;
    	}
    }

    function computeAverage (){
    	int256 sum;

    	for (uint8 i=0; i<whitelist.length; i++){
    		sum += allEstimates[whitelist[i]].P;
    	}
    	average.P = sum / int(whitelist.length);
    }

    function getAverage(int256 i) returns(int256){
    	i = 2;
    	return average.P;
    }
    
    function getWaiting (uint8 i) returns(bool){
    	return waiting[whitelist[i]];
    }

    function resetWaiting () {
        // Reset the flag for each address        
        for(uint8 i=0; i<whitelist.length; i++){
           waiting[ whitelist[i] ] = true;
        }
    }
}

