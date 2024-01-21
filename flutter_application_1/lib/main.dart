import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String _friendCode = '';
List<String> _friendCodes = [
  '{"uid": "20406080", "username": "bbpatel", "where": "Ford Dining Court", "since": "6:00pm", "status": "both"}',
  '{"uid": "10305070", "username": "canineL", "where": "Wiley Dining Court", "since": "9:00pm", "status": "both"}',
  '{"uid": "12345678", "username": "jackthe", "where": "Hillenbrand Dining Court", "since": "7:00pm", "status": "other"}',
  '{"uid": "87654321", "username": "andrewB", "where": "Windsor Dining Court", "since": "10:00am", "status": "you"}',
];

class UserData {
  String uid;
  String username;
  String where;
  String since; // how long there (can change to ISO class later)
  String status;

  UserData(
      {required this.uid,
      required this.username,
      required this.where,
      required this.since,
      required this.status});

  // Factory method to create a User instance from a Map
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'],
      username: json['username'],
      where: json['where'],
      since: json['since'],
      status: json['status'],
    );

    // to convert UserData into a string
  }

  String toJson() {
    return jsonEncode({
      'uid': uid,
      'username': username,
      'where': where,
      'since': since,
      'status': status
    });
  }
} // user Data class
// Map<String, dynamic> jsonMap = json.decode("string");
// UserData user = UserData.fromJson(jsonMap);

class FriendList {
  List<UserData> friends = [];
  int get length => friends.length;
  UserData operator [](int index) => friends[index];
  List<UserData> where(bool Function(UserData) test) =>
      friends.where(test).toList();

  void addFriendToList(UserData user) {
    friends.add(user);
  }

  void removeFriendFromList(UserData user) {
    friends.removeWhere((friend) => friend.uid == user.uid);
  }

  void stopBroadCasting(UserData user) {
    for (var friend in friends) {
      if (friend.uid == user.uid)
        friend.status = 'other';
    }
  }

  void startFriend(UserData user) {
    for (var friend in friends) {
      if (friend.uid == user.uid)
        friend.status = 'both';
    }
  }

  void stopRecieving(UserData user) {
    for (var friend in friends) {
      if (friend.uid == user.uid)
        friend.status = 'you';
    }
  }


  FriendList(List<String> friendCodes)
      : friends = friendCodes
            .map((friendCode) => UserData.fromJson(jsonDecode(friendCode)))
            .toList();
  FriendList.fromUsers(List<UserData> users) {
    friends = users;
  }

  // ...
}

void main() {
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _MyHomePage(),
      routes: {
        '/addFriend': (context) =>
            const AddFriendPage(), // screen to enter a friend code
        //'/viewFriend': (context) => const ViewFriendPage(user:user), // options remove, see dining court
        '/viewDiningCourt': (context) =>
            const ViewDiningCourt(), // options to see dining court times (maybe menu)
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
          importance: Importance.max, priority: Priority.high, showWhen: false);
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

class ImageSection extends StatelessWidget {
  const ImageSection({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      width: 600,
      height: 240,
      fit: BoxFit.cover,
    );
  }
}

class _MyHomePageState extends State<_MyHomePage> {
  FriendList friendList = FriendList(_friendCodes);

  void _navigateToAddFriend() async {
    try {
      final result =
          await Navigator.pushNamed(context, '/addFriend').then((value) {
        if (value != null) {
          setState(() {
            friendList.addFriendToList(
                UserData.fromJson(json.decode(value.toString())));
          });
        }
      });
    } catch (e) {
      // Handle any exceptions here
    }
  }

  void _navigateToViewFriend(UserData user) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewFriendPage(user: user)),
      ).then((value) {
        if (value != null) {
          setState(() {
            friendList.removeFriendFromList(
                UserData.fromJson(json.decode(value.toString())));
          });
        }
      });

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

  Widget _buildFriendCard(UserData friend) {
    return Card(
      child: ListTile(
        leading: Column(
          children: <Widget>[
            Text(friend.username),
            if (friend.status == 'other')
              Container(
                height: 20,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      friendList.startFriend(friend);
                    });
                  },
                  child: const Text('Broadcast'),
                )
              ),
              if (friend.status == 'you')
                Container(
                  height: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        friendList.startFriend(friend);
                      });
                    },
                    child: const Text('Recieve'),
                  )
                )
          ]
        ),
        trailing: Text(friend.where),
        onTap: () {
          _friendCode = friend.toJson();
          _navigateToViewFriend(friend);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FriendList bothFriends = FriendList.fromUsers(
        friendList.where((friend) => friend.status == 'both').toList());
    FriendList otherFriends = FriendList.fromUsers(
        friendList.where((friend) => friend.status == 'other').toList());
    FriendList youFriends = FriendList.fromUsers(
        friendList.where((friend) => friend.status == 'you').toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Home Page'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_1.png'),                    
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: <Widget>[
            const Text('Mutual Friends',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ...bothFriends.friends.map((friend) => _buildFriendCard(friend)),
            const Text('Recieving Friends',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ...youFriends.friends.map((friend) => _buildFriendCard(friend)),
            const Text('Broadcasting Friends',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ...otherFriends.friends.map((friend) => _buildFriendCard(friend)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddFriend,
        child: const Icon(Icons.person_add),
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
  final _controller = TextEditingController(); // for text field
  String _friendCode = ""; // for what use enteres as username

  void _addFriendCode() {
    setState(() {
      if (_friendCode.length == 8) {
        // replace with call to server when available
        String defaultOption =
            '{"uid": "20406080", "username": "bbpatel", "where": "Ford Dining Court", "since": "6:00pm", "status": "both"}';
        Navigator.pop(context,
            defaultOption); // send message back to main to refresh list.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error: Friend code invalid or already added.')), // notification
        );
        _controller.clear(); // reset text field
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // clean up the controller
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
                  _friendCode = value;
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
class ViewFriendPage extends StatefulWidget {
  UserData user;
  ViewFriendPage({super.key, required this.user});

  @override
  _ViewFriendPageState createState() => _ViewFriendPageState(user: user);
}

class _ViewFriendPageState extends State<ViewFriendPage> {
  UserData user;
  _ViewFriendPageState({required this.user});

  void _removeFriendCode() {
    setState(() {
      // prevent duplicates ...
      // prevent shorty
      Navigator.pop(context, user.toJson());
    });
  }

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
              user.username,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              user.where,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              user.since,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _removeFriendCode();
              },
              child: const Text('REMOVE FRIEND'),
            ),
          ],
        ),
      ),
    );
  }
}

// start for dining court page
class ViewDiningCourt extends StatefulWidget {
  const ViewDiningCourt({Key? key}) : super(key: key);

  @override
  _ViewDiningCourtState createState() => _ViewDiningCourtState();
}

class _ViewDiningCourtState extends State<ViewDiningCourt> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
