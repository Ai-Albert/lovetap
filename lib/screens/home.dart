import 'package:flutter/material.dart';
import 'package:lovetap/custom_widgets/show_alert_dialogue.dart';
import 'package:lovetap/custom_widgets/show_exception_alert_dialogue.dart';
import 'package:lovetap/services/auth.dart';
import 'package:lovetap/services/database.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // Controls variable elements of the basic structure of the app
  int _currentIndex = 0;
  List<Widget> _children = [];
  final List<String> _appBarTitles = ['Fireplace', 'Time Machine'];

  @override
  void initState() {
    super.initState();
    _children = [];
  }

  // Signs out using Firebase
  Future _signOut() async {
    try {
      await Provider.of<AuthBase>(context, listen: false).signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  // Asks user to sign out
  Future _confirmSignOut(BuildContext context) async {
    final request = await showAlertDialog(
      context,
      title: 'Logout',
      content: 'Are you sure you want to log out?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Log out',
    );
    if (request) {
      _signOut();
    }
  }

  // Deletes account and associated data
  Future _accountDelete() async {
    try {
      await Provider.of<Database>(context, listen: false).deleteData();
      await Provider.of<AuthBase>(context, listen: false).deleteAccount();
      Navigator.of(context).pop();
    } catch (e) {
      showExceptionAlertDialog(
        context,
        title: "Operation failed",
        exception: new Exception("Try signing out and in again to do this."),
      );
    }
  }

  // Asks user to confirm account and data deletion
  Future _confirmAccountDelete(BuildContext context) async {
    final request = await showAlertDialog(
      context,
      title: 'Delete Account',
      content: 'Are you sure you want to delete your account and data?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Delete',
    );
    if (request) {
      _accountDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],

      body: _children[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[850],
        selectedItemColor: Colors.grey[350],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        iconSize: 30,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            label: '',
          ),
        ],
      ),
    );
  }
}
