import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

class Blockchain {
  String? contractAddr;
  String? secondContractAddr;  // Added for second contract
  late Client httpClient;
  late Web3Client ethClient;
  late Credentials creds;
  late DeployedContract contract;
  late DeployedContract secondContract;  // Added for second contract

  Blockchain() {
    SharedPreferences.getInstance().then((prefs) async {
      String? key = prefs.getString('key');
      String? contractAddress = prefs.getString("contract");
      String? secondContractAddress = prefs.getString("second_contract");  // New line for second contract address

      if (key != null && contractAddress != null && secondContractAddress != null) {  // Check for second contract address
        creds = EthPrivateKey.fromHex(key);
        contractAddr = contractAddress;
        secondContractAddr = secondContractAddress;  // Assign the second contract address

        httpClient = Client();
        String apiUrl = "http://192.168.1.2:7545";
        ethClient = Web3Client(apiUrl, httpClient);

        // Load the ABI for the first contract
        String abi = await rootBundle.loadString("assets/president.json");
        contract = loadContract(abi, contractAddr!);

        // Load the ABI for the second contract
        String secondAbi = await rootBundle.loadString("assets/deputies.json");
        secondContract = loadContract(secondAbi, secondContractAddr!);

        print("First Contract: $contractAddr");
        print("Second Contract: $secondContractAddr");
      } else {
        throw Exception("Private key or contract address is not set in SharedPreferences");
      }
    });
  }

  DeployedContract loadContract(String abi, String contractAddress) {
    return DeployedContract(ContractAbi.fromJson(abi, "ContractName"), EthereumAddress.fromHex(contractAddress));
  }

  Future<List<dynamic>> queryView(String fun, List<dynamic> args) async {
    print("Calling blockchain function: " + fun);
    return ethClient.call(
      sender: await creds.address,
      contract: contract,
      function: contract.function(fun),
      params: args,
    );
  }

  Future<Future<String>> query(String fun, List<dynamic> args, {BigInt? wei}) async {
    wei ??= BigInt.zero;
    return ethClient.sendTransaction(
      creds,
      Transaction.callContract(
        contract: contract,
        function: contract.function(fun),
        parameters: args,
        value: EtherAmount.inWei(wei),
        maxGas: 999999,
      ),
      chainId: 1337,
      fetchChainIdFromNetworkId: false,
    );
  }

  Future<List<dynamic>> queryViewSecond(String fun, List<dynamic> args) async {
    print("Calling second blockchain function: " + fun);
    return ethClient.call(
      sender: await creds.address,
      contract: secondContract,
      function: secondContract.function(fun),
      params: args,
    );
  }

  Future<Future<String>> querySecond(String fun, List<dynamic> args, {BigInt? wei}) async {
    wei ??= BigInt.zero;
    return ethClient.sendTransaction(
      creds,
      Transaction.callContract(
        contract: secondContract,
        function: secondContract.function(fun),
        parameters: args,
        value: EtherAmount.inWei(wei),
        maxGas: 999999,
      ),
      chainId: 1337,
      fetchChainIdFromNetworkId: false,
    );
  }

  String translateError(RPCError error) {
    String errorMessage = error.message;

    if (errorMessage.contains("revert")) {
      List<String> parts = errorMessage.split("revert");
      if (parts.length > 1) {
        return parts[1].trim().replaceAll(RegExp(r'[."]+$'), "");
      }
    }
    return errorMessage;
  }

  Future<bool> check() async {
    try {
      var blockNumber = await ethClient.getBlockNumber();
      print("Current block number: $blockNumber");
      return true;
    } catch (error) {
      print("Blockchain connection failed: $error");
      return false;
    }
  }

  void logout() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('key');
      prefs.remove('contract');
      prefs.remove('second_contract');  // Added for second contract
    });
  }

  Future<EthereumAddress> myAddr() async {
    return await creds.address;
  }

  Uint8List encodeVote2(BigInt secret, EthereumAddress addr) {
    List<dynamic> parameters = [secret, addr];
    AbiType type = const TupleType([UintType(), AddressType()]);
    final sink = LengthTrackingByteSink();
    type.encode(parameters, sink);
    return keccak256(sink.asBytes());
  }

  Uint8List encodeVote(BigInt secret, EthereumAddress addr) {
    List<dynamic> parameters = [secret, addr];
    AbiType type = const TupleType([UintType(), AddressType()]);
    final sink = LengthTrackingByteSink();
    type.encode(parameters, sink);
    return keccak256(sink.asBytes());
  }

  Uint8List encodeVoteDeputies(BigInt secret, EthereumAddress groupAddress) {
    List<dynamic> parameters = [secret, groupAddress];
    AbiType type = const TupleType([UintType(), AddressType()]);
    final sink = LengthTrackingByteSink();
    type.encode(parameters, sink);
    return keccak256(sink.asBytes());
  }
}
