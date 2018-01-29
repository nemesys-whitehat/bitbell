//! Certifier contract, taken from ethcore/sms-verification


pragma solidity ^0.4.17;

contract Certifier {
	event Confirmed(address indexed who);
	event Revoked(address indexed who);
	function certified(address _who) constant public returns (bool);
	function getData(address _who, string _field) constant public returns (bytes32) {}
	function getAddress(address _who, string _field) constant public returns (address) {}
	function getUint(address _who, string _field) constant public returns (uint) {}
}
