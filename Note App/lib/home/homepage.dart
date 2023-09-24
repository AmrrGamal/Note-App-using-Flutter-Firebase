import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_flutter/crud/editnotes.dart';
import 'package:course_flutter/crud/viewnotes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference notesCollectionRef =
      FirebaseFirestore.instance.collection("notes");

  getUser() {
    var user = FirebaseAuth.instance.currentUser;
    print(user.email);
  }

/*
  var fbm = FirebaseMessaging.instance;


 initalMessage() async {
    
   var message =   await FirebaseMessaging.instance.getInitialMessage() ;

   if (message != null){
     
     Navigator.of(context).pushNamed("addnotes") ; 

   } 

 }


 requestPermssion() async {
    
    FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

 }

 
  @override
  void initState() {
     requestPermssion() ; 
     initalMessage() ; 
    fbm.getToken().then((token) {
      print("=================== Token ==================");
      print(token);
      print("====================================");
    });


   
    
    FirebaseMessaging.onMessage.listen((event) {
      print("===================== data Notification ==============================") ; 
      
      //  AwesomeDialog(context: context , title: "title" , body: Text("${event.notification.body}"))..show() ; 
      
      Navigator.of(context).pushNamed("addnotes") ; 

    }) ; 
  

    getUser();
    super.initState();
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
        actions: [
          ///////
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed("login");
              }) // pushReplacementNamed  لازم دي
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed("addnotes");
          }),
      body: Container(
        //////
        ////////
        //////
        /// firebase with future builder
        child: FutureBuilder(
            future: notesCollectionRef
                .where("userid",
                    isEqualTo: FirebaseAuth.instance.currentUser.uid)
                .get(),
            /*
للاتيان بمعلومات المستخدم اللي عامل لوجين مثلا تريد عرضها في التطبيق وتقوله ازيك وكده 
FirebaseAuth.instance.currentUser.uid
FirebaseAuth.instance.currentUser.email
فيه حاجات تانيه ضع نقطه وجرب كده 
 */

            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, i) {
                      return Dismissible(
                          onDismissed: (diretion) async {
                            await notesCollectionRef
                                .doc(snapshot.data.docs[i].id)
                                .delete();
                            print("Delete the doc from store");
                            await FirebaseStorage.instance
                                .refFromURL(snapshot.data.docs[i]['imageurl'])
                                .delete()
                                .then((value) {
                              //  collection الذي في ال  imageurl عرض وحزف الصورة عن طريق رابطها
                              print("=================================");
                              print("Delete image from storage");
                            });
                            /////////////////////////////////////////
                            //onDismissed not nees set state
                            /////////////////////////////////////////
                          },
                          key: UniqueKey(),
                          child: ListNotes(
                            note: snapshot.data.docs[i],
                            // one document to display in the home and the edit page
                            docid: snapshot.data.docs[i].id,
                            // id of document to give it to update function to know which doc he update in the edit page
                          ));
                    });
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}

class ListNotes extends StatelessWidget {
  final note;
  final docid;
  ListNotes({this.note, this.docid});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ViewNote(notes: note);
        }));
      },
      child: Card(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Image.network(
                "${note['imageurl']}",
                //  collection الذي في ال  imageurl عرض وحزف الصورة عن طريق رابطها
                fit: BoxFit.fill,
                height: 80,
              ),
            ),
            Expanded(
              flex: 3,
              child: ListTile(
                title: Text("${note['title']}"),
                subtitle: Text(
                  "${note['note']}",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditNotes(docid: docid, list: note);
                    }));
                  },
                  icon: Icon(Icons.edit),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
