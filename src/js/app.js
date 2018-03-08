App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // Initialize web3 and set the provider to the testRPC.
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // set the provider you want from Web3.providers
      App.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:9545');
      web3 = new Web3(App.web3Provider);
    }

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('MainCoin.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      var MainCoinArtifact = data;
      App.contracts.MainCoin = TruffleContract(MainCoinArtifact);

      // Set the provider for our contract.
      App.contracts.MainCoin.setProvider(App.web3Provider);

      // Use our contract to retieve and mark the adopted pets.
      return App.getBalances();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '#transferButton', App.handleTransfer);
  },

  handleTransfer: function(event) {
    event.preventDefault();

    var amount = parseInt($('#TransferAmount').val());
    var toAddress = $('#TransferAddress').val();

    console.log('Transfer ' + amount + ' MAIN to ' + toAddress);

    var mainCoinInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.MainCoin.deployed().then(function(instance) {
        mainCoinInstance = instance;

        return mainCoinInstance.transfer(toAddress, amount, {from: account});
      }).then(function(result) {
        alert('Transfer erfolgreich!');
        return App.getBalances();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  getBalances: function() {
    console.log('Getting balances...');

    var mainCoinInstance;

    switch (web3.version.network) {
      case "1":
        $('#network').text('Main');
        console.log('This is mainnet')
        break
      case "2":
        $('#network').text('Morden Test');
        console.log('This is the deprecated Morden test network.')
        break
      case "3":
        $('#network').text('Ropsten');
        console.log('This is the ropsten test network.')
        break
      default:
        $('#network').text('Unbekannt');
        console.log('This is an unknown network')
    }

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.MainCoin.deployed().then(function(instance) {
        mainCoinInstance = instance;

        return mainCoinInstance.balanceOf(account);
      }).then(function(result) {
        balance = result.c[0];

        $('#Balance').text(balance);
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
