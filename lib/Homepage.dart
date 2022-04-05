import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app4/TabPages/CompetizioniPage.dart';
import 'package:flutter_app4/TabPages/CorsiPage.dart';
import 'package:flutter_app4/feste/pagina_feste.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'TabPages/SeminariPage.dart';
import 'TabPages/SocialPage.dart';
import 'TabPages/Sportivi.dart';
import 'account_manager/account_persona.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String universita;
  String titolo = "Seminari e Webinair";

  _HomePageState();

  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.w600);

  final Uri _emailLaunchUri = Uri(scheme: 'mailto', path: 'info.dawey@gmail.com', queryParameters: {'subject': 'Richiesta pubblicazione evento!'});

  List<Widget> _widgetOptions = <Widget>[
    SeminariPage(auth: _auth),
    CorsiPage(auth: _auth),
    CompetizioniPage(auth: _auth),
    SportiviPage(auth: _auth),
    SocialPage(auth: _auth),
  ];
  TextEditingController editingController = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> updateUser() {
    return users
        .doc(_auth.currentUser.uid)
        .update({'attiva_filtri': true})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> updateAttivaFiltri(bool attivo) {
    return users
        .doc(_auth.currentUser.uid)
        .update({'attiva_filtri': attivo})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  @override
  void initState() {
    //FirebaseAuth.instance.signOut();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leading: IconButton(
                padding: EdgeInsets.symmetric(horizontal: 20),
                icon: Icon(
                  LineIcons.infoCircle,
                  color: Colors.white,
                ),
                onPressed: () {
                  _displayTextInputDialog(context);
                },
              ),
              expandedHeight: 230.0,
              floating: false,
              pinned: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0))),
              elevation: 8,
              backgroundColor: Colors.lightBlue,
              actions: <Widget>[
                IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  icon: Icon(
                    LineIcons.glassCheers,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FestePagina()));
                  },
                ),
                IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  icon: Icon(
                    LineIcons.userCircle,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => accountPersona()));
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(bottom: 20.0),
                            padding: EdgeInsets.only(left: 16.0, right: 16.0),
                            child: Text(
                              titolo,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25.0),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('users').doc(_auth.currentUser.uid).snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Something went wrong');
                                    }
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return SizedBox();
                                    }

                                    Map<String, dynamic> data = snapshot.data.data();
                                    return List.from(data["tags_interesse"]).isNotEmpty
                                        ? Expanded(
                                            child: Container(
                                            padding: EdgeInsets.only(right: 10),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 50,
                                                    child: ListView.builder(
                                                      physics: NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: List.from(data["tags_interesse"]).length,
                                                      itemBuilder: (context, index) {
                                                        return index.isEven
                                                            ? _buildChip(data["tags_interesse"][index],
                                                                data['attiva_filtri'] ? Colors.orangeAccent : Colors.grey, index)
                                                            : Container();
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 50,
                                                    child: ListView.builder(
                                                      physics: NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: List.from(data["tags_interesse"]).length,
                                                      itemBuilder: (context, index) {
                                                        return index.isOdd
                                                            ? _buildChip(data["tags_interesse"][index],
                                                                data['attiva_filtri'] ? Colors.orangeAccent : Colors.grey, index)
                                                            : Container();
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ))
                                        : Expanded(
                                            child: Text(
                                              "Aggiungi i tuoi interessi",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white),
                                            ),
                                          );
                                  }),
                              Column(
                                children: <Widget>[
                                  Container(
                                    height: 40,
                                    width: 40,
                                    margin: EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        showCupertinoModalBottomSheet(
                                          context: context,
                                          elevation: 8,
                                          builder: (context) => PageTags(),
                                        );
                                      },
                                      child: Icon(
                                        LineIcons.plus,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance.collection('users').doc(_auth.currentUser.uid).snapshots(),
                                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                        if (snapshot.hasError) {
                                          return Text('Something went wrong');
                                        }
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Container(
                                            height: 40,
                                            width: 40,
                                            margin: EdgeInsets.only(right: 10, top: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            child: Icon(
                                              LineIcons.checkCircle,
                                              color: Colors.white,
                                            ),
                                          );
                                        }
                                        Map<String, dynamic> data = snapshot.data.data();

                                        data.containsKey('attiva_filtri') ? null : updateUser();

                                        return Container(
                                          height: 40,
                                          width: 40,
                                          margin: EdgeInsets.only(right: 10, top: 10),
                                          decoration: BoxDecoration(
                                            color: data['attiva_filtri'] ? Colors.lightGreen : Colors.grey,
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                          ),
                                          child: TextButton(
                                            onPressed: () async {
                                              bool attivo;
                                              data['attiva_filtri'] ? attivo = false : attivo = true;
                                              await updateAttivaFiltri(attivo);
                                            },
                                            child: Icon(
                                              LineIcons.checkCircle,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LineIcons.book),
            label: 'Seminari',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.rocket),
            label: 'Corsi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_late_outlined),
            label: 'Competizioni',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.footballBall),
            label: 'Sport',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.at),
            label: 'Social',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildChip(String label, Color color, int index) {
    if (index > 4) {
      return Container();
    } else {
      return Container(
        padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
        child: Chip(
          labelPadding: EdgeInsets.all(1.0),
          label: Text(
            label,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: color,
          elevation: 6.0,
          shadowColor: Colors.grey[60],
          padding: EdgeInsets.all(8.0),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          titolo = "Seminari e Webinair";
          break;
        case 1:
          titolo = "Corsi";
          break;
        case 2:
          titolo = "Competizioni e concorsi";
          break;
        case 3:
          titolo = "Eventi sportivi";
          break;
        case 4:
          titolo = "Eventi social";
          break;
      }
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return new CupertinoAlertDialog(
          title: new Text('Inserisci anche tu il tuo evento'),
          content: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  "Pubblica il tuo evento a migliaia di giovani. Inviaci una email a info.dawey@gmail.com con il tuo indirizzo email, verrai poi contatta per le informazioni neccessarie! "),
              SizedBox(
                height: 20,
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("Invia Email"),
              onPressed: () async {
                await launch(_emailLaunchUri.toString());
              },
            ),
            CupertinoDialogAction(
              child: Text("Chiudi"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}

class PageTags extends StatefulWidget {
  @override
  _PageTagsState createState() => _PageTagsState();
}

class _PageTagsState extends State<PageTags> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream collectionStream;
  Stream tags_account;

  Map<String, dynamic> user_doc;
  List<String> _dynamicChips;
  List<dynamic> _tags = [];

  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    collectionStream = FirebaseFirestore.instance.collection('tags').snapshots();
    tags_account = FirebaseFirestore.instance.collection('users').doc(_auth.currentUser.uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 150.0,
                floating: false,
                pinned: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0))),
                elevation: 8,
                backgroundColor: Colors.lightBlue,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Scegli i tuoi tags",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Theme(
                              data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {});
                                },
                                textCapitalization: TextCapitalization.sentences,
                                controller: editingController,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: "Search",
                                    hintText: "Search",
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "In questa sezione scegli con cura i tuoi tags che ti interessano.\nSaranno fondamentali per visualizzare gli eventi più interessanti per te",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                editingController.text.isEmpty
                    ? StreamBuilder<DocumentSnapshot>(
                        stream: tags_account,
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              child: Center(
                                child: Loading(indicator: BallPulseIndicator(), size: 100.0, color: Colors.lightBlue),
                              ),
                            );
                          }

                          user_doc = snapshot.data.data();

                          _dynamicChips = List.from(user_doc["tags_interesse"]);

                          return Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Sono i tuoi Tags di interesse:",
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6.0,
                                  children: List<Widget>.generate(_dynamicChips.length, (int index) {
                                    return Chip(
                                      label: Text(
                                        _dynamicChips[index],
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      labelPadding: EdgeInsets.all(2.0),
                                      onDeleted: () async {
                                        int numero;
                                        String categoria;
                                        await FirebaseFirestore.instance
                                            .collection('tags')
                                            .where('tags', arrayContainsAny: [_dynamicChips[index]])
                                            .get()
                                            .then((value) => categoria = value.docs.first.data()['categoria']);

                                        user_doc['grafico'].containsKey(categoria)
                                            ? numero = user_doc['grafico'][categoria] - 1
                                            : numero = 0;
                                        FirebaseFirestore.instance.collection("users").doc(_auth.currentUser.uid).update({
                                          "tags_interesse": FieldValue.arrayRemove([_dynamicChips[index]]),
                                          "grafico.${categoria}": numero,
                                        });
                                        setState(() {
                                          _tags.add(_dynamicChips[index]);
                                        });
                                      },
                                      elevation: 6,
                                      backgroundColor: Colors.white,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Container(),
                StreamBuilder<QuerySnapshot>(
                  stream: collectionStream,
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        child: Center(
                          child: Loading(indicator: BallPulseIndicator(), size: 100.0, color: Colors.lightBlue),
                        ),
                      );
                    }

                    return Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: snapshot.data.docs.map((DocumentSnapshot document) {
                          _tags = _tags + List.from(document.data()['tags']);
                          List<dynamic> lista = List.from(document.data()['tags']);
                          _dynamicChips.forEach((element) {
                            lista.remove(element);
                          });

                          return Column(
                            children: <Widget>[
                              (editingController.text.isEmpty && lista.isNotEmpty)
                                  ? Text(
                                      document.data()['categoria'],
                                      style: TextStyle(fontSize: 25, color: Colors.black),
                                    )
                                  : Container(
                                      height: 0,
                                    ),
                              (editingController.text.isEmpty && lista.isNotEmpty)
                                  ? SizedBox(
                                      height: 10,
                                    )
                                  : Container(
                                      height: 0,
                                    ),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6.0,
                                children: List<Widget>.generate(lista.length, (int index) {
                                  if (editingController.text.isEmpty && lista.isNotEmpty) {
                                    return ActionChip(
                                      label: Text(
                                        lista[index],
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      labelPadding: EdgeInsets.all(2.0),
                                      elevation: 6,
                                      onPressed: () {
                                        int numero;
                                        user_doc['grafico'].containsKey(document.data()['categoria'])
                                            ? numero = user_doc['grafico'][document.data()['categoria']] + 1
                                            : numero = 1;
                                        FirebaseFirestore.instance.collection("users").doc(_auth.currentUser.uid).update({
                                          "tags_interesse": FieldValue.arrayUnion([lista[index]]),
                                          "grafico.${document.data()['categoria']}": numero,
                                        }).then((value) => ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                duration: const Duration(seconds: 1),
                                                content: Text('Tag aggiunto!'),
                                              ),
                                            ));
                                        setState(() {
                                          lista.remove(lista[index]);
                                        });
                                      },
                                      backgroundColor: Colors.white,
                                    );
                                  } else if (lista[index].toLowerCase().contains(editingController.text.toLowerCase())) {
                                    return ActionChip(
                                      label: Text(
                                        lista[index],
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      labelPadding: EdgeInsets.all(2.0),
                                      elevation: 4,
                                      onPressed: () {
                                        int numero;

                                        user_doc['grafico'].containsKey(document.data()['categoria'])
                                            ? numero = user_doc['grafico'][document.data()['categoria']] + 1
                                            : numero = 1;
                                        FirebaseFirestore.instance.collection("users").doc(_auth.currentUser.uid).update({
                                          "tags_interesse": FieldValue.arrayUnion([lista[index]]),
                                          "grafico.${document.data()['categoria']}": numero,
                                        }).then((value) => ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            duration: const Duration(seconds: 1),
                                            content: Text('Tag aggiunto!'),
                                          ),
                                        ));
                                        setState(() {
                                          lista.remove(lista[index]);
                                          editingController.clear();
                                        });
                                      },
                                      backgroundColor: Colors.white,
                                      shape: StadiumBorder(side: BorderSide()),
                                    );
                                  } else {
                                    return Container(
                                      height: 0,
                                    );
                                  }
                                }),
                              ),
                              (editingController.text.isEmpty && lista.isNotEmpty)
                                  ? SizedBox(
                                      height: 20,
                                    )
                                  : Container(
                                      height: 0,
                                    ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
