import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

class Blockchain {
  String? contractAddr;
  late Client httpClient;
  late Web3Client ethClient;
  late Credentials creds;
  late DeployedContract contract;

  Blockchain() {
    SharedPreferences.getInstance().then((prefs) async {
      String? key = prefs.getString('key');
      String? contractAddress = prefs.getString("contract");

      if (key != null && contractAddress != null) {
        creds = EthPrivateKey.fromHex(key);
        contractAddr = contractAddress;
      } else {
        throw Exception("Private key or contract address is not set in SharedPreferences");
      }

      httpClient = Client();
      String apiUrl = "http://192.168.1.2:7545";
      ethClient = Web3Client(apiUrl, httpClient);
      String abi = await rootBundle.loadString("assets/abi.json");
      contract = loadContract(abi);
      print("Contract: $contractAddr");
    });
  }

  DeployedContract loadContract(String abi) {
    return DeployedContract(ContractAbi.fromJson(abi, "Deputies"), EthereumAddress.fromHex(contractAddr!));
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
