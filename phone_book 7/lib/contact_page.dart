import 'package:flutter/material.dart';
import 'package:phone_book/add_contact_page.dart';
import 'package:phone_book/database/db_helper.dart';
import 'package:phone_book/model/contact.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  DbHelper _dbHelper;

  @override
  void initState() {
    _dbHelper = DbHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Book"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddContactPage(contact: Contact())));
        },
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _dbHelper.getContacts(),
        builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data.isEmpty) return Text("Your contact list empty");
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = snapshot.data[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddContactPage(contact: contact,)));
                  },
                  child: Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Colors.red,
                    ),
                    onDismissed: (direction) async {
                      _dbHelper.removeContact(contact.id);

                      setState(() {});

                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("${contact.name} has been deleted"),
                        action: SnackBarAction(
                          label: "UNDO",
                          onPressed: () async {
                            await _dbHelper.insertContact(contact);

                            setState(() {});
                          },
                        ),
                      ));
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                          contact.avatar == null ? "assets/img/person.jpg" : contact.avatar,
                        ),
                        child: Text(
                          contact.name[0].toUpperCase(),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(contact.phoneNumber),
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
