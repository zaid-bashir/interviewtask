import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:interviewtask/chat/chatscreen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  UserListScreenState createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Users List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(snapshot.data![index]["email"]),
                    subtitle: Text(snapshot.data![index]["uid"]),
                    leading: const FlutterLogo(),
                    onTap: (){
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>const ChatScreen(),),);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    List<Map<String, dynamic>> users = [];
    for (var doc in querySnapshot.docs) {
      users.add(doc.data());
    }
    return users;
  }
}

class User {
  final String uid;
  final String? email;

  User({required this.uid, this.email});
}
