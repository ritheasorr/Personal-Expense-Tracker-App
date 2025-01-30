import 'package:flutter/material.dart';

class MenuButton extends StatefulWidget {
  const MenuButton({super.key});

  @override
  State<MenuButton> createState() => _MenuButton();
}

class _MenuButton extends State<MenuButton> {
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: new ListView(
        children: <Widget>[
          InkWell(
            onTap: () {
              // Handle navigation to Home page
              Navigator.pushNamed(context, '/homescreen');
            },
            child: ListTile(
              title: Text('Home page'),
              leading: Icon(Icons.home),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () {
              // Handle navigation to Contact Us page
              Navigator.pushNamed(context, '/contact');
            },
            child: ListTile(
              title: Text('Contact Us'),
              leading: Icon(Icons.phone),
            ),
          ),
          InkWell(
            onTap: () async {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout),
            ),
          ),
        ],
      ),
    );
  }
}
