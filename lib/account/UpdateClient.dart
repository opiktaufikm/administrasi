import 'package:flutter/material.dart';

class UpdateClient extends StatefulWidget {
  UpdateClient({required this.clientId});
  final String clientId; 

  @override
  State<UpdateClient> createState() => _UpdateClientState();
}

class _UpdateClientState extends State<UpdateClient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Client'),
      ),
      
    );
  }
}