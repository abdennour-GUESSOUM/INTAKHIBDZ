import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import '../../../blockchain_back/blockchain/blockachain.dart';


class ConfirmVoteView extends StatefulWidget {
  @override
  _ConfirmVoteViewState createState() => _ConfirmVoteViewState();
}

class _ConfirmVoteViewState extends State<ConfirmVoteView> {
  final _formKey = GlobalKey<FormState>();
  final _sigilController = TextEditingController();
  final _signController = TextEditingController();
  Blockchain blockchain = Blockchain();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Envelope'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _sigilController,
                decoration: const InputDecoration(labelText: 'Sigil'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the sigil';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _signController,
                decoration: const InputDecoration(labelText: 'Sign'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the sign';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    blockchain.query('open_envelope', [
                      BigInt.parse(_sigilController.text),
                      EthereumAddress.fromHex(_signController.text)
                    ]);
                  }
                },
                child: const Text('Open Envelope'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
