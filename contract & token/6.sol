//! DappReg is a Dapp Registry 


pragma solidity ^0.4.17;

import "Owned.sol";

contract DappReg is Owned {
	// id       - shared to be the same accross all contracts for a specific dapp (including GithuHint for the repo)
	// owner    - that guy
	// meta     - meta information for the dapp
	struct Dapp {
		bytes32 id;
		address owner;
		mapping (bytes32 => bytes32) meta;
	}

	modifier when_fee_paid {
		require (msg.value >= fee);
		_;
	}

	modifier only_dapp_owner(bytes32 _id) {
		require (dapps[_id].owner == msg.sender);
		_;
	}

	modifier either_owner(bytes32 _id) {
		require (dapps[_id].owner == msg.sender || owner == msg.sender);
		_;
	}

	modifier when_id_free(bytes32 _id) {
		require (dapps[_id].id == 0);
		_;
	}

	event MetaChanged(bytes32 indexed id, bytes32 indexed key, bytes32 value);
	event OwnerChanged(bytes32 indexed id, address indexed owner);
	event Registered(bytes32 indexed id, address indexed owner);
	event Unregistered(bytes32 indexed id);

	mapping (bytes32 => Dapp) dapps;
	bytes32[] ids;

	uint public fee = 1 ether;

	// returns the count of the dapps we have
	function count() constant public returns (uint) {
		return ids.length;
	}

	// a dapp from the list
	function at(uint _index) constant public returns (bytes32 id, address owner) {
		Dapp storage d = dapps[ids[_index]];
		id = d.id;
		owner = d.owner;
	}

	// get with the id
	function get(bytes32 _id) constant public returns (bytes32 id, address owner) {
		Dapp storage d = dapps[_id];
		id = d.id;
		owner = d.owner;
	}

	// add apps
	function register(bytes32 _id) payable when_fee_paid when_id_free(_id) public {
		ids.push(_id);
		dapps[_id] = Dapp(_id, msg.sender);
		Registered(_id, msg.sender);
	}

	// remove apps
	function unregister(bytes32 _id) either_owner(_id) public {
		delete dapps[_id];
		Unregistered(_id);
	}

	// get meta information
	function meta(bytes32 _id, bytes32 _key) constant public returns (bytes32) {
		return dapps[_id].meta[_key];
	}

	// set meta information
	function setMeta(bytes32 _id, bytes32 _key, bytes32 _value) only_dapp_owner(_id) public {
		dapps[_id].meta[_key] = _value;
		MetaChanged(_id, _key, _value);
	}

	// set the dapp owner
	function setDappOwner(bytes32 _id, address _owner) only_dapp_owner(_id) public {
		dapps[_id].owner = _owner;
		OwnerChanged(_id, _owner);
	}

	// set the registration fee
	function setFee(uint _fee) only_owner public {
		fee = _fee;
	}

	// retrieve funds paid
	function drain() only_owner public {
		msg.sender.transfer(this.balance);
	}
}
