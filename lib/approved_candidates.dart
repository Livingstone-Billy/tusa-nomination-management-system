import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:private_domain/app.dart';

class ApprovedCongress extends StatefulWidget {
  const ApprovedCongress({super.key});

  @override
  State<ApprovedCongress> createState() => _ApprovedCongressState();
}

class _ApprovedCongressState extends State<ApprovedCongress> {
  static List<String> filters = [
    "Faculty Rep",
    "Male Hostel Rep",
    "Female Hostel Rep",
    "Non Resident Male Rep",
    "Non Resident Femal Rep",
    "Games & Sports Male Rep",
    "Games & Sports Female Rep"
  ];

  String firstValue = "Faculty Rep";

  Future<void> _createExcel(String type) async {
    final CollectionReference ref =
        FirebaseFirestore.instance.collection("verified_candidates");
    var excel = Excel.createExcel();
    Sheet sheetObject = excel[type];

    QuerySnapshot querySnapshot = await ref
        .where('position', isEqualTo: type)
        .where('approved', isEqualTo: true)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var fullnames = sheetObject.cell(CellIndex.indexByString('A${1 + i}'));
      var data = querySnapshot.docs[i].data() as Map<String, dynamic>;
      fullnames.value = data['fullnames'];

      var regNo = sheetObject.cell(CellIndex.indexByString('B${1 + i}'));
      regNo.value = data['regNo'];

      var phoneNo = sheetObject.cell(CellIndex.indexByString('C${1 + i}'));
      phoneNo.value = data['phoneNo'];
      var faculty = sheetObject.cell(CellIndex.indexByString('D${1 + i}'));
      faculty.value = data['faculty'];
      var position = sheetObject.cell(CellIndex.indexByString('E${1 + i}'));
      position.value = data['position'];
      var status = sheetObject.cell(CellIndex.indexByString('F${1 + i}'));
      status.value = data['status'];
    }
    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      await FirebaseStorage.instance
          .ref('uploads/$type.xlsx')
          .putData(fileBytes as Uint8List);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Approved Candidates",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Approved Candidates [Congress]"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: IconButton(
                onPressed: (() => _createExcel(firstValue)),
                icon: const Icon(Icons.print),
                tooltip: 'Generate Excel',
              ),
            ),
            DropdownButton(
              value: firstValue,
              onChanged: (String? value) {
                setState(() {
                  firstValue = value!;
                });
              },
              icon: const Icon(Icons.arrow_drop_down_circle),
              items: filters.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
          leading: InkWell(
            onTap: (() => Navigator.of(context).pop()),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("verified_candidates")
                .where('category', isEqualTo: 'congress')
                .where('position', isEqualTo: firstValue)
                .where('approved', isEqualTo: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  "Error retrieving data!",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                );
              }
              if (!snapshot.hasData) {
                return const Text(
                  "No available data!",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: DataTable(
                  dividerThickness: 2,
                  decoration: BoxDecoration(border: Border.all()),
                  columns: const [
                    DataColumn(
                        label: Text(
                      "Fullnames",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                    )),
                    DataColumn(
                        label: Text(
                      "RegNo",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                    )),
                    DataColumn(
                        label: Text(
                      "Phone No",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                    )),
                    DataColumn(
                        label: Text(
                      "Faculty",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                    )),
                    DataColumn(
                        label: Text(
                      "Position",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                    )),
                    DataColumn(
                        label: Text(
                      "Status",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                    )),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot doc) {
                    Map<String, dynamic> data =
                        doc.data()! as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text(data['fullnames'])),
                      DataCell(Text(data['regNo'])),
                      DataCell(Text(data['phoneNo'])),
                      DataCell(Text(data['faculty'])),
                      DataCell(Text(data['position'])),
                      DataCell(Text(data['reason']))
                    ]);
                  }).toList(),
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: (() => Navigator.of(context)
              .push(const AdminSide().route(const ApprovedGovCouncil()))),
          label: const Text('GovCouncil'),
          icon: const Icon(
            Icons.arrow_forward,
            size: 16,
          ),
        ),
      ),
    );
  }
}

class ApprovedGovCouncil extends StatefulWidget {
  const ApprovedGovCouncil({super.key});

  @override
  State<ApprovedGovCouncil> createState() => _ApprovedGovCouncilState();
}

class _ApprovedGovCouncilState extends State<ApprovedGovCouncil> {
  static List<String> filters = [
    "President",
    "Vice President",
    "Secretary General",
    "Organising Secretary",
    "Treasurer",
    "Director of Academic Affairs",
    "Director of Students Werlfare",
  ];

  String firstValue = "President";

  Future<void> _createExcel(String type) async {
    final CollectionReference ref =
        FirebaseFirestore.instance.collection("verified_candidates");
    var excel = Excel.createExcel();
    Sheet sheetObject = excel[type];

    QuerySnapshot querySnapshot = await ref
        .where('position', isEqualTo: type)
        .where('approved', isEqualTo: true)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var fullnames = sheetObject.cell(CellIndex.indexByString('A${1 + i}'));
      var data = querySnapshot.docs[i].data() as Map<String, dynamic>;
      fullnames.value = data['fullnames'];

      var regNo = sheetObject.cell(CellIndex.indexByString('B${1 + i}'));
      regNo.value = data['regNo'];

      var phoneNo = sheetObject.cell(CellIndex.indexByString('C${1 + i}'));
      phoneNo.value = data['phoneNo'];
      var faculty = sheetObject.cell(CellIndex.indexByString('D${1 + i}'));
      faculty.value = data['faculty'];
      var position = sheetObject.cell(CellIndex.indexByString('E${1 + i}'));
      position.value = data['position'];
      var status = sheetObject.cell(CellIndex.indexByString('F${1 + i}'));
      status.value = data['status'];
    }
    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      await FirebaseStorage.instance
          .ref('uploads/$type.xlsx')
          .putData(fileBytes as Uint8List);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Approved Candidates",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text("Approved Candidates [GovCouncil]"),
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: IconButton(
                  onPressed: (() => _createExcel(firstValue)),
                  icon: const Icon(Icons.print),
                  tooltip: 'Generate Excel',
                ),
              ),
              DropdownButton(
                value: firstValue,
                onChanged: (String? value) {
                  setState(() {
                    firstValue = value!;
                  });
                },
                icon: const Icon(Icons.arrow_drop_down_circle),
                items: filters.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
            leading: InkWell(
              onTap: (() => Navigator.of(context).pop()),
              child: const Icon(Icons.arrow_back),
            ),
          ),
          body: SingleChildScrollView(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("verified_candidates")
                  .where('category', isEqualTo: 'govCouncil')
                  .where('position', isEqualTo: firstValue)
                  .where('approved', isEqualTo: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Error retrieving data!",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500),
                  );
                }
                if (!snapshot.hasData) {
                  return const Text(
                    "No available data!",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: DataTable(
                    dividerThickness: 2,
                    decoration: BoxDecoration(border: Border.all()),
                    columns: const [
                      DataColumn(
                          label: Text(
                        "Fullnames",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17),
                      )),
                      DataColumn(
                          label: Text(
                        "RegNo",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17),
                      )),
                      DataColumn(
                          label: Text(
                        "Phone No",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17),
                      )),
                      DataColumn(
                          label: Text(
                        "Faculty",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17),
                      )),
                      DataColumn(
                          label: Text(
                        "Position",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17),
                      )),
                      DataColumn(
                          label: Text(
                        "Status",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17),
                      )),
                    ],
                    rows: snapshot.data!.docs.map((DocumentSnapshot doc) {
                      Map<String, dynamic> data =
                          doc.data()! as Map<String, dynamic>;
                      return DataRow(cells: [
                        DataCell(Text(data['fullnames'])),
                        DataCell(Text(data['regNo'])),
                        DataCell(Text(data['phoneNo'])),
                        DataCell(Text(data['faculty'])),
                        DataCell(Text(data['position'])),
                        DataCell(Text(data['reason']))
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          )),
    );
  }
}

class DisqualifiedCandidates extends StatefulWidget {
  const DisqualifiedCandidates({super.key});

  @override
  State<DisqualifiedCandidates> createState() => _DisqualifiedCandidatesState();
}

class _DisqualifiedCandidatesState extends State<DisqualifiedCandidates> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Disqualified Candidates",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Disqualified Candidates"),
          leading: InkWell(
            onTap: (() => Navigator.pop(context)),
            child: const Icon(Icons.arrow_back),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                right: 20.0,
              ),
              child: SizedBox(
                width: 170,
                child: TextField(
                  onChanged: ((value) {
                    setState(() {
                      search = value;
                    });
                  }),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                      labelText: 'RegNo',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
        body: StreamBuilder(
          stream: search.isEmpty
              ? FirebaseFirestore.instance
                  .collection("verified_candidates")
                  .where('approved', isEqualTo: false)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection("verified_candidates")
                  .where('regNo', isEqualTo: search)
                  .where('approved', isEqualTo: false)
                  .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text(
                "Error while retrieving data!",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              );
            }
            if (!snapshot.hasData) {
              return const Text(
                "No available data!",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final data = snapshot.requireData;
            return ListView.builder(
              itemCount: data.size,
              itemBuilder: ((context, index) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage("assets/eligible.png"),
                          radius: 40,
                        ),
                        title: Text(
                            "${data.docs[index]['fullnames'].toString().split(' ').first} ${data.docs[index]['fullnames'].toString().split(' ').last}"),
                        subtitle: Text(
                          "Reason: ${data.docs[index]['reason']}",
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
