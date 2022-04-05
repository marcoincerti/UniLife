import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:line_icons/line_icons.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';

class paginaSingolaEvento extends StatefulWidget {
  final DocumentSnapshot documentoeReference;
  final int tipo;
  final String idDocumento;

  const paginaSingolaEvento({Key key, this.documentoeReference, this.idDocumento, this.tipo}) : super(key: key);

  @override
  _paginaSingolaEventoState createState() => _paginaSingolaEventoState();
}

class _paginaSingolaEventoState extends State<paginaSingolaEvento> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Map<String, dynamic> documento;
  Map<String, dynamic> userData;
  String tipoEvento;
  String idDocumentoBottone;
  var myGroup = AutoSizeGroup();

  @override
  void initState() {
    // TODO: implement initState
    documento = widget.documentoeReference.data();
    switch (widget.tipo) {
      case 1:
        tipoEvento = 'seminari';
        break;
      case 2:
        tipoEvento = 'corsi';
        break;
      case 3:
        tipoEvento = 'competizioni';
        break;
      case 4:
        tipoEvento = 'sportivi';
        break;
      case 5:
        tipoEvento = 'social';
        break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: <Widget>[
          NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  iconTheme: IconThemeData(
                    color: Colors.black, //change your color here
                  ),
                  floating: true,
                  backgroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      "Scheda evento",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      documento["titolo"],
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: EdgeInsets.only(top: 10, right: 10),
                      padding: EdgeInsets.only(top: 10),
                      child: FutureBuilder<QuerySnapshot>(
                          future: users.doc(auth.currentUser.uid).collection(tipoEvento).where('id', isEqualTo: widget.idDocumento).get(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text("Something went wrong");
                            }

                            if (snapshot.connectionState == ConnectionState.done) {
                              userData = snapshot.data.docs.isEmpty ? {} : snapshot.data.docs.first.data();
                              idDocumentoBottone = snapshot.data.docs.isEmpty ? "" : snapshot.data.docs.first.id;
                              return StreamBuilder<DocumentSnapshot>(
                                  stream: null,
                                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot2) {
                                    if (snapshot2.hasError) {
                                      return Text('Something went wrong');
                                    }

                                    if (snapshot2.connectionState == ConnectionState.waiting) {
                                      RawMaterialButton(
                                        onPressed: () {  },
                                        child: Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: CupertinoActivityIndicator(),
                                        ),
                                      );
                                    }

                                    Color stella = userData.isNotEmpty ? Colors.amber : Colors.blueGrey;

                                    return RawMaterialButton(
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Icon(
                                          Icons.star,
                                          color: stella,
                                          size: 40,
                                        ),
                                      ),
                                      onPressed: () {
                                        userData.isNotEmpty ? removePreferito() : addPreferito();
                                        setState(() {
                                          stella = userData.isNotEmpty ? Colors.amber : Colors.blueGrey;
                                        });
                                      },
                                    );
                                  });
                            }
                            return RawMaterialButton(
                              elevation: 6,
                              shape: const CircleBorder(),
                              onPressed: () {  },
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.star,
                                  size: 40,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                  documento.containsKey("data_inizio")
                      ? Container(
                          margin: EdgeInsets.only(left: 8, right: 8, top: 20),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      LineIcons.calendarCheck,
                                      color: Colors.green,
                                      size: 50,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    documento.containsKey('data_inizio')
                                        ? DataConvertitore(documento['data_inizio'])
                                        : Align(
                                            alignment: Alignment.centerLeft,
                                            child: Icon(
                                              LineIcons.timesCircle,
                                              color: Colors.deepOrangeAccent,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  children: [
                                    documento.containsKey('data_fine')
                                        ? DataConvertitoreFine(documento['data_fine'])
                                        : Align(
                                            alignment: Alignment.centerRight,
                                            child: Icon(
                                              LineIcons.timesCircle,
                                              color: Colors.deepOrangeAccent,
                                            ),
                                          ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      LineIcons.calendarTimesAlt,
                                      color: Colors.red,
                                      size: 50,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  documento.containsKey("data_inizio")
                      ? SizedBox(
                          height: 15,
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  documento.containsKey("sport")
                      ? /*StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('universita').doc(documento['riservato_universita']).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 15, right: 15),
                                margin: EdgeInsets.all(
                                  15.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Center(
                                  child: Text("Riservato:\n caricamento...", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                                ),
                              );
                            }
                            Map<String, dynamic> universita = snapshot.data.data();

                            return*/
                  Container(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 15, right: 15),
                    margin: EdgeInsets.all(
                      15.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.redAccent),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Center(
                      child: Text("${documento['sport']}", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                    ),
                  )
                  /*})*/
                      : SizedBox(
                    height: 0,
                  ),
                  documento.containsKey("prezzo")
                      ? /*StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('universita').doc(documento['riservato_universita']).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 15, right: 15),
                                margin: EdgeInsets.all(
                                  15.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Center(
                                  child: Text("Riservato:\n caricamento...", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                                ),
                              );
                            }
                            Map<String, dynamic> universita = snapshot.data.data();

                            return*/
                  Container(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 15, right: 15),
                    margin: EdgeInsets.all(
                      15.0,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.redAccent),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Center(
                      child: Text("Prezzo: ${documento['prezzo']}", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                    ),
                  )
                  /*})*/
                      : SizedBox(
                    height: 0,
                  ),
                  documento.containsKey("offerto")
                      ? /*StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('universita').doc(documento['riservato_universita']).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 15, right: 15),
                                margin: EdgeInsets.all(
                                  15.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Center(
                                  child: Text("Riservato:\n caricamento...", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                                ),
                              );
                            }
                            Map<String, dynamic> universita = snapshot.data.data();

                            return*/
                      Container(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 15, right: 15),
                          margin: EdgeInsets.all(
                            15.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Center(
                            child: Text("Offerto da:\n ${documento['offerto']}", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                          ),
                        )
                      /*})*/
                      : SizedBox(
                          height: 0,
                        ),
                  documento.containsKey("ospite")
                      ? Container(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 15, right: 15),
                          margin: EdgeInsets.all(
                            15.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.lightGreen,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Center(
                            child: Text(
                              "Ospite:\n ${documento['ospite']}",
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(left: 15, right: 15, top: 15),
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
                    child: Column(
                      children: [
                        Text(
                          "Descrizione:",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          child: Column(
                            children: [
                              Text(
                                documento["descrizione"],
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                margin: EdgeInsets.all(15),
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
                                      "Tags",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6.0,
                                      children: List<Widget>.generate(documento["tags"].length, (int index) {
                                        return Chip(
                                          label: Text(
                                            documento["tags"][index],
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          labelPadding: EdgeInsets.all(0.5),
                                          elevation: 6,
                                          backgroundColor: Colors.white,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  documento.containsKey("luogo")
                      ? Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(left: 15, right: 15, top: 15),
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
                          child: Column(
                            children: [
                              Text(
                                "L'Evento verrà svolto:",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(8),
                                    itemCount: documento["luogo"].length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Container(
                                        margin: EdgeInsets.all(3),
                                        child: SelectableText(
                                          '${documento["luogo"][index].toString()}',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(left: 15, right: 15, top: 15),
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
                    child: Column(
                      children: [
                        Text(
                          "Informazioni:",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(8),
                              itemCount: documento["informazioni"].length,
                              itemBuilder: (BuildContext context, int index) {
                                String key = documento["informazioni"].keys.elementAt(index);
                                return new Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 10, bottom: 10),
                                      child: Column(
                                        children: [
                                          Text(
                                            "$key:",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          SelectableText(
                                            "${documento["informazioni"][key]}",
                                            style: TextStyle(fontSize: 20),
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
                                      ),
                                    ),
                                    new Divider(
                                      height: 2.0,
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 95,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
                /* boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],*/
              ),
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: documento.containsKey("link") ? MaterialStateProperty.all(Colors.lightBlue) : MaterialStateProperty.all(Colors.redAccent),
                      ),
                      onPressed: () {
                        if(documento.containsKey("link")){
                          launch(documento["link"]);
                        }
                      },
                      child: Text(
                        documento.containsKey("link") ? "LINK" : 'Link non disponibile',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ButtonTheme(
                    minWidth: 70.0,
                    height: 60.0,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: documento.containsKey("email") ? MaterialStateProperty.all(Colors.lightGreen) : MaterialStateProperty.all(Colors.redAccent),
                      ),
                      onPressed: () {
                        if(documento.containsKey("email")){
                          Uri _emailLaunchUri = Uri(scheme: 'mailto', path: documento["email"].toString());
                          launch(_emailLaunchUri.toString());
                        }
                      },
                      child: Icon(Icons.email_outlined),
                    ),
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }

  Future<void> addPreferito() {
    Map<String, dynamic> map = widget.documentoeReference.data();
    map['id'] = widget.idDocumento;
    switch (widget.tipo) {
      case 1:
        return users.doc(auth.currentUser.uid).collection('seminari').add(map);
        break;
      case 2:
        return users.doc(auth.currentUser.uid).collection('corsi').add(map).then((value) => print(value.toString()));
        break;
      case 3:
        return users
            .doc(auth.currentUser.uid)
            .collection('competizioni')
            .add(map);
        break;
      case 4:
        return users
            .doc(auth.currentUser.uid)
            .collection('sportivi')
            .add(map);
        break;
      case 5:
        return users
            .doc(auth.currentUser.uid)
            .collection('social')
            .add(map);
        break;
    }
  }

  Future<void> removePreferito() {
    switch (widget.tipo) {
      case 1:
        return users.doc(auth.currentUser.uid).collection('seminari').doc(idDocumentoBottone).delete();
        break;
      case 2:
        return users.doc(auth.currentUser.uid).collection('corsi').doc(idDocumentoBottone).delete();
        break;
      case 3:
        return users.doc(auth.currentUser.uid).collection('sportivi').doc(idDocumentoBottone).delete();
        break;
      case 4:
        return users.doc(auth.currentUser.uid).collection('competizioni').doc(idDocumentoBottone).delete();
        break;
      case 5:
        return users.doc(auth.currentUser.uid).collection('social').doc(idDocumentoBottone).delete();
        break;
    }
  }

  Widget DataConvertitore(Timestamp data) {
    DateTime d = data.toDate();
    String formatDate = DateFormat('EE dd/MM/yy').format(d);
    String formatOra = DateFormat('kk:mm').format(d);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          formatDate,
          maxLines: 1,
          group: myGroup,
        ),
        AutoSizeText(formatOra, maxLines: 1, group: myGroup)
      ],
    );
  }

  Widget DataConvertitoreFine(Timestamp data) {
    DateTime d = data.toDate();
    String formatDate = DateFormat('EE dd/MM/yy').format(d);
    String formatOra = DateFormat('kk:mm').format(d);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [AutoSizeText(formatDate, maxLines: 1, group: myGroup), AutoSizeText(formatOra, maxLines: 1, group: myGroup)],
    );
  }
}
