pragma solidity ^0.4.17;

import "./ERC20Token.sol";
import "./SafeMath.sol";

contract MainCoin is ERC20Token {
  using SafeMath for uint256;

  // Hier werden die Kontostände aller Adressen gespeichert
  mapping(address => uint256) balances;

  // in dieser Variable wird gespeichert, wie viele Coins es insgesamt gibt
  uint256 totalSupply_;

  // Hier legen wir die grundlegenden Eigenschaften unseres Coins fest
  string public constant name = 'MainCoin';
  string public constant symbol = 'MAIN';

  // Hier können wir die Dezimalstellen unseres Coins festlegen. Der Euro hat z.B. 2 Dezimalstellen, um Beträge wie 12,99€ möglich zu machen.
  // Der Einfachheit halber nutzen wir für unseren Coin aber keine Dezimalstellen, so dass es nur ganze Einheiten gibt
  //uint8 public constant decimals = 2;
  //uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));
  uint256 public constant INITIAL_SUPPLY = 10000;

  // Der Konstruktor unseres Coins. Er wird genau ein mal beim "Deploy" auf die Blockchain ausgeführt
  function MainCoin() public {
    totalSupply_ = INITIAL_SUPPLY;

    // Der gesamte Bestand an MainCoins wird dem Ersteller des Smart Contracts zugeschrieben
    balances[msg.sender] = INITIAL_SUPPLY;

    // Der Transfer Event wird für den initialen Transfer getriggert.
    // Dabei deklarieren wir, dass von der "Genesis" Adresse alle Tokens auf die Adresse des Contract Erstellers transferiert wurden.
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

  // Diese Getter Funktion gibt den Gesamtbestand an Coins zurück
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  // Diese Getter Funktion gibt den Kontostand einer Adresse zurück
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  // Mit dieser Funktion werden MainCoins von einem Konto zum anderen transferiert
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  ////////////////////////////////
  // Die unten folgenden Variablen und Funktionen werden benötigt, um anderen Smart Contracts zu ermöglichen in eurem Namen MainCoins zu transferieren.
  // Dies wird zum Beispiel wichtig, wenn ihr MainTokens auf einer dezentralen Handelsbörse verkaufen möchtet. Ihr könnt dem Smart Contract
  // der Handelsbörse erlauben, einen gewissen Betrag an Coins (allowance) in eurem Namen zu transferieren.
  ///////////////////////////////

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}
