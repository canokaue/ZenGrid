compile;
migrate;

addr1 = web3.eth.accounts[0];
addr2 = web3.eth.accounts[1];
addr3 = web3.eth.accounts[2];
whitelist = [addr1,addr2,addr3];

var agg; 
Aggregator.deployed().then(function(instance){agg=instance;})

// Get waiting status: either of these:
agg.whitelist(0).then(function(addr){agg.waiting(addr).then(function(iswaiting){console.log(iswaiting)})})
agg.waiting(addr1).then(function(iswaiting){console.log(iswaiting);})

agg.whitelistLength.call().then(function(a){console.log(a)})

agg.getAverage.call(1).then(function(a){console.log(a)})

var iteration;
agg.iteration().then(function(result){iteration = result;})
iteration = iteration.toNumber();
agg.submitValue(12, iteration, {from: addr1}).then(function(i){})
agg.submitValue(12, iteration, {from: addr2}).then(function(i){})
agg.submitValue(13, iteration, {from: addr3}).then(function(i){})

