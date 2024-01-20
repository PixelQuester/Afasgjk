import 'package:flutter/material.dart';

String _friendCode = '';
List<String> _friendCodes = [
  "12345678",
];
void main() {
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _MyHomePage(),
      routes: {
        '/addFriend': (context) => const AddFriendPage(),
      },
    );
  }
}

class _MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {

  void _navigateToAddFriend() async {
    try {
      final result = await Navigator.pushNamed(context, '/addFriend');
      if (result == true) {
        setState(() {
          print(_friendCodes);
          // Rebuild the page here
        });
      }
    } catch (e) {
      // Handle any exceptions here
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _friendCodes.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_friendCodes[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: _navigateToAddFriend,
              child: const Icon(Icons.person_add),
            ),
          ],
        ),
      ),
    );
  }
}

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({Key? key}) : super(key: key);

  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {

  void _setFriendCode(String code) {
    setState(() {
      _friendCode = code;
    });
  }

  void _addFriendCode() {
    setState(() {
      _friendCodes.add(_friendCode);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter Friend Code:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Friend Code',
                ),
                maxLength: 8, // Add this line to accept exactly an 8-digit code
                onChanged: (value) {
                  // Store the entered code in a variable
                  // Call the function to add the code to the friend list
                  _setFriendCode(value);
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add the code to the friend list
                _addFriendCode();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}