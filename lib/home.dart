import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:private_domain/app.dart';
import 'package:private_domain/applications.dart';
import 'package:private_domain/approved_candidates.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  Future<int> _noOfApplications(String collection) async {
    QuerySnapshot applications =
        await FirebaseFirestore.instance.collection(collection).get();
    int totalApplications = applications.size;
    return totalApplications;
  }

  Future<int> _noOfApprovedCandidates(bool isApproved) async {
    final CollectionReference ref =
        FirebaseFirestore.instance.collection("verified_candidates");
    QuerySnapshot querySnapshot =
        await ref.where('approved', isEqualTo: isApproved).get();

    return querySnapshot.size;
  }

  Future<void> enableFeatures(String docId, String field) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection("features").doc(docId);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot documentSnapshot = await transaction.get(docRef);
      Map<String, dynamic> data =
          documentSnapshot.data()! as Map<String, dynamic>;
      transaction.update(docRef, {field: !data[field]});
    });
  }

  Future<void> uploadFile() async {
    final CollectionReference reference =
        FirebaseFirestore.instance.collection("uploads");
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: ['pdf']);
      Reference ref =
          FirebaseStorage.instance.ref().child("signature/signatures.pdf");
      if (result != null && result.files.isNotEmpty) {
        final fileBytes = result.files.first.bytes;

        await ref.putData(fileBytes!);
        ref.getDownloadURL().then((value) async {
          await reference
              .doc("signature")
              .set({"signatureUrl": value, "type": "signature"});
        });
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Admin Home",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("TUSA Nomination Portal"),
          actions: [
            IconButton(
              onPressed: (() {
                uploadFile().then((value) => showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        content: Text("File uploaded successfully"),
                      );
                    }));
              }),
              icon: const Icon(Icons.upload_sharp),
              tooltip: 'Upload Signature Form',
            ),
            IconButton(
                onPressed: (() => Navigator.of(context).pushAndRemoveUntil(
                    const AdminSide().route(const AdminHome()),
                    (route) => false)),
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: SizedBox(
                    width: 230,
                    child: Container(
                      color: Colors.blueGrey.shade900,
                      child: Column(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(
                                top: 50.0, left: 20.0, right: 20.0),
                            child: CircleAvatar(
                                backgroundImage: AssetImage("assets/admin.png"),
                                radius: 40),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              "Admin",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.indigo),
                            ),
                          ),
                          ListTile(
                            title: const Text(
                              "Dashboard",
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            onTap: (() {}),
                          ),
                          ListTile(
                            title: const Text(
                              "Congress",
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ),
                            onTap: (() => Navigator.of(context).push(
                                const AdminSide().route(
                                    const Applications(type: "congress")))),
                          ),
                          ListTile(
                              title: const Text(
                                "Governing Council",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white60,
                                    fontWeight: FontWeight.w500),
                              ),
                              onTap: (() => Navigator.of(context).push(
                                  const AdminSide().route(const Applications(
                                      type: "govCouncil"))))),
                          ListTile(
                              title: const Text(
                                "Disqualified Candidates",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white60,
                                    fontWeight: FontWeight.w500),
                              ),
                              trailing: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.amber,
                                ),
                                child: FutureBuilder(
                                  future: _noOfApprovedCandidates(false),
                                  builder: (_, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    int value = 0;
                                    if (snapshot.hasData) {
                                      value = snapshot.data!;
                                    }
                                    return Center(
                                      child: Text(
                                        value.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              onTap: (() => Navigator.of(context).push(
                                  const AdminSide()
                                      .route(const DisqualifiedCandidates())))),
                          ListTile(
                            title: const Text(
                              "Logout",
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.w500),
                            ),
                            onTap: (() => Navigator.of(context)
                                .pushAndRemoveUntil(
                                    const AdminSide().route(const AdminLogin()),
                                    (route) => false)),
                          ),
                        ],
                      ),
                    ),
                  )),
              const Positioned(
                left: 50.0,
                bottom: 20.0,
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Image(image: AssetImage("assets/index.png")),
                ),
              ),
              Positioned(
                top: 200,
                left: 400,
                child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("features")
                      .doc("enable_verification")
                      .get(),
                  builder: ((context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text("No available Data!",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    Map<String, dynamic> data = {};
                    if (snapshot.hasData) {
                      data = snapshot.data!.data()!;
                    }
                    return ElevatedButton(
                      onPressed: (() {
                        enableFeatures("enable_verification", 'isVerification')
                            .then((value) => Navigator.of(context)
                                .pushAndRemoveUntil(
                                    const AdminSide().route(const AdminHome()),
                                    (route) => false));
                      }),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          minimumSize: const Size(150, 45),
                          backgroundColor: data['isVerification']
                              ? Colors.red
                              : Colors.blueGrey.shade400),
                      child: Text(data['isVerification']
                          ? "Disable Verification"
                          : "Enable Verification"),
                    );
                  }),
                ),
              ),
              Positioned(
                top: 200,
                left: 600,
                child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("features")
                      .doc("enable_application")
                      .get(),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Text("No available Data!",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500));
                    }
                    Map<String, dynamic> data = {};
                    if (snapshot.hasData) {
                      data = snapshot.data!.data()!;
                    }
                    return ElevatedButton(
                      onPressed: (() {
                        enableFeatures("enable_application", 'isApplication')
                            .then((value) => Navigator.of(context)
                                .pushAndRemoveUntil(
                                    const AdminSide().route(const AdminHome()),
                                    (route) => false));
                      }),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          minimumSize: const Size(150, 45),
                          backgroundColor: data['isApplication']
                              ? Colors.green
                              : Colors.blueGrey.shade400),
                      child: Text(data['isApplication']
                          ? "Disable Application"
                          : "Enable Application"),
                    );
                  }),
                ),
              ),
              Positioned(
                top: 20.0,
                left: 400.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: 150,
                        width: 250,
                        child: InkWell(
                          onTap: (() => Navigator.of(context).push(
                              const AdminSide().route(
                                  const Applications(type: "congress")))),
                          child: Card(
                            color: Colors.indigo,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Stack(
                              children: <Widget>[
                                const Positioned(
                                  top: 20,
                                  left: 20,
                                  child: Text(
                                    "Congress",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20),
                                  ),
                                ),
                                Positioned(
                                    top: 70.0,
                                    right: 20.0,
                                    child: FutureBuilder(
                                      future: _noOfApplications("congress"),
                                      builder: (_, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        int value = 0;
                                        if (snapshot.hasData) {
                                          value = snapshot.data!;
                                        }
                                        return Text(
                                          value.toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20),
                                        );
                                      },
                                    )),
                                const Positioned(
                                    top: 70.0,
                                    left: 20.0,
                                    child: Text(
                                      "Applications",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0),
                      child: SizedBox(
                        height: 150,
                        width: 250,
                        child: InkWell(
                          onTap: (() => Navigator.of(context).push(
                              const AdminSide().route(
                                  const Applications(type: "govCouncil")))),
                          child: Card(
                            color: Colors.indigo,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.0)),
                            child: Stack(
                              children: <Widget>[
                                const Positioned(
                                  top: 20,
                                  left: 20,
                                  child: Text(
                                    "Gov-Council",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20),
                                  ),
                                ),
                                Positioned(
                                    top: 70.0,
                                    right: 20.0,
                                    child: FutureBuilder(
                                      future: _noOfApplications("govCouncil"),
                                      builder: (_, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        int value = 0;
                                        if (snapshot.hasData) {
                                          value = snapshot.data!;
                                        }
                                        return Text(
                                          value.toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20),
                                        );
                                      },
                                    )),
                                const Positioned(
                                    top: 70.0,
                                    left: 20.0,
                                    child: Text("Applications",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0),
                      child: SizedBox(
                          height: 150,
                          width: 250,
                          child: InkWell(
                            onTap: (() => Navigator.of(context).push(
                                const AdminSide()
                                    .route(const ApprovedCongress()))),
                            child: Card(
                              color: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0)),
                              child: Stack(
                                children: <Widget>[
                                  const Positioned(
                                    top: 20,
                                    left: 20,
                                    child: Text(
                                      "Approved Candidates",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20),
                                    ),
                                  ),
                                  Positioned(
                                      top: 70.0,
                                      right: 20.0,
                                      child: FutureBuilder(
                                        future: _noOfApprovedCandidates(true),
                                        builder: (_, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          int value = 0;
                                          if (snapshot.hasData) {
                                            value = snapshot.data!;
                                          }
                                          return Text(
                                            value.toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 20),
                                          );
                                        },
                                      )),
                                  const Positioned(
                                      top: 70.0,
                                      left: 20.0,
                                      child: Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VisitsData {
  VisitsData(this.date, this.visits);

  final DateTime date;
  final int visits;
}
