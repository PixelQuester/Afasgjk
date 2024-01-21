import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String _friendCode = '';
List<String> _friendCodes = [
  "12345678",
  "87654321",
];

class UserData {
  String uid;
  String username;
  String where;
  String since; // how long there (can change to ISO class later)

  UserData({required this.uid, required this.username, required this.where, required this.since});

  // Factory method to create a User instance from a Map
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'],
      username: json['username'],
      where: json['where'],
      since:json['since']
    );
  }

  String getUID() {
    return uid;
  }
  String getUsername() {
    return username;
  }
  String getWhere() {
    return where;
  }
  String getSince() {
    return since;
  }
} // user Data class 
// Map<String, dynamic> jsonMap = json.decode("string");
// UserData user = UserData.fromJson(jsonMap);


void main() {
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _MyHomePage(),
      routes: {
        '/addFriend': (context) => const AddFriendPage(), // screen to enter a friend code
        '/viewFriend': (context) => const ViewFriendPage(), // options remove, see dining court
        '/viewDiningCourt': (context) => const ViewDiningCourt(), // options to see dining court times (maybe menu)
      },
    );
  }
}


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> _showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, 'plain title', 'plain body', platformChannelSpecifics,
      payload: 'item x');
}

// start of my home page
class _MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {

  void _navigateToAddFriend() async {
    try {
      final result = await Navigator.pushNamed(context, '/addFriend').then((value) {
        if (value != null) {
          setState(() {
            _friendCodes.add(value.toString());
          });
        }
      });
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

  void _navigateToViewFriend() async {
    try {
      final result = await Navigator.pushNamed(context, '/viewFriend');
      if (result == true) {
        setState(() async {
          // Rebuild page here
          await _showNotification();
          _friendCodes.add(result.toString());
        });
      }
    } catch (e) {
      // handle any exceptions here
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
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _friendCodes.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () {
                      // navigate to the view friend profile for that friend
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => ViewFriendPage()),
                      );
                    },
                    child: Text(_friendCodes[index]),
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



// start for view friend page
class AddFriendPage extends StatefulWidget {
  const AddFriendPage({Key? key}) : super(key: key);

  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
 
  final _controller = TextEditingController();

  void _setFriendCode(String code) {
    setState(() {
      _friendCode = code;
    });
  }

  void _addFriendCode() {
    setState(() {

      // prevent duplicates ... 
      // prevent shorty
      if (_friendCode.length == 8 && RegExp(r'^[0-9]+$').hasMatch(_friendCode) && !_friendCodes.contains(_friendCode)) { // replace with call to server when available
        Navigator.pop(context, _friendCode);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Friend code invalid or already added.')),
        );
        _controller.clear();
      }
      //Navigator.pop(context, _friendCode);
    });
  }

  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                controller: _controller,
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


// start for view friend page
class ViewFriendPage extends StatefulWidget{
  const ViewFriendPage({Key? key}) : super(key: key);

  @override
  _ViewFriendPageState createState() => _ViewFriendPageState();
}

class _ViewFriendPageState extends State<ViewFriendPage> {
  
  // get user info 
  //void getUserInfo()
  //Map<String, dynamic> jsonMap = json.decode("string");
  /*String uid;
  String username;
  String where;
  String since;*/
  UserData user = UserData.fromJson(json.decode(
    '{"uid": "20406080", "username": "bbpatel", "where": "Ford Dining Court", "since": "7:00pm"}')
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Friend Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              user.getUsername(),
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              user.getUID(),
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              user.getWhere(),
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              user.getSince(),
              style: TextStyle(fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}


// start for dining court page
class ViewDiningCourt extends StatefulWidget{
  const ViewDiningCourt({Key? key}) : super(key: key);

  @override
  _ViewDiningCourtState createState() => _ViewDiningCourtState();
}

class _ViewDiningCourtState extends State<ViewDiningCourt> {

  @override 
  Widget build(BuildContext context){
    return Scaffold();
  }
}
