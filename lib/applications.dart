import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:private_domain/app.dart';
import 'package:private_domain/candidate.dart';
import 'package:private_domain/home.dart';
import 'package:url_launcher/url_launcher.dart';

class Applications extends StatefulWidget {
  const Applications({super.key, required this.type});

  final String type;
  @override
  State<Applications> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications> {
  List<String> filters = [
    "None",
    "Faculty of Business",
    "Faculty of Life Sciences",
    "Faculty of Humanities",
    "Faculty of Education",
    "Faculty of Science & Engineering"
  ];

  String firstValue = "None";
  String verification = "";

  @override
  Widget build(BuildContext context) {
    Candidate candidate = Candidate('', '', '', '', '', '', '', '');
    return MaterialApp(
      title: "${widget.type} applications",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("${widget.type} applications"),
          leading: InkWell(
            onTap: (() => Navigator.pop(context)),
            child: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              onPressed: (() {
                setState(() {
                  verification = "No";
                });
              }),
              icon: const Icon(Icons.wifi_tethering_error_rounded_sharp),
              tooltip: 'Not verified',
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
            )
          ],
        ),
        body: verification.isEmpty
            ? StreamBuilder(
                stream: (firstValue == "None")
                    ? FirebaseFirestore.instance
                        .collection(widget.type)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection(widget.type)
                        .where("faculty", isEqualTo: firstValue)
                        .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                  backgroundImage:
                                      AssetImage("assets/eligible.png"),
                                  radius: 40,
                                ),
                                title: Text(
                                    "${data.docs[index]['fullnames'].toString().split(' ').first} ${data.docs[index]['fullnames'].toString().split(' ').last}"),
                                subtitle: Text(
                                    "Position:  ${data.docs[index]['position']}"),
                                trailing: Text(
                                  "Verified: ${data.docs[index]['verification']}",
                                  style:
                                      const TextStyle(color: Colors.blueGrey),
                                ),
                                onTap: data.docs[index]['verification'] == 'Yes'
                                    ? null
                                    : (() {
                                        candidate.fullnames =
                                            data.docs[index]['fullnames'];
                                        candidate.regNo =
                                            data.docs[index]['regNo'];
                                        candidate.phoneNo =
                                            data.docs[index]['phoneNo'];
                                        candidate.faculty =
                                            data.docs[index]['faculty'];
                                        candidate.position =
                                            data.docs[index]['position'];
                                        candidate.category = widget.type;
                                        candidate.transcript =
                                            data.docs[index]['transcriptUrl'];
                                        candidate.signature =
                                            data.docs[index]['signatureUrl'];
                                        Navigator.of(context).push(
                                            const AdminSide().route(
                                                ApplicantVerification(
                                                    candidate: candidate)));
                                      }),
                              ),
                            ),
                          ));
                    }),
                  );
                },
              )
            : StreamBuilder(
                stream: (firstValue == "None")
                    ? FirebaseFirestore.instance
                        .collection(widget.type)
                        .where('verification', isEqualTo: 'No')
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection(widget.type)
                        .where("faculty", isEqualTo: firstValue)
                        .where("verification", isEqualTo: 'No')
                        .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                backgroundImage:
                                    AssetImage("assets/eligible.png"),
                                radius: 40,
                              ),
                              title: Text(
                                  "${data.docs[index]['fullnames'].toString().split(' ').first} ${data.docs[index]['fullnames'].toString().split(' ').last}"),
                              subtitle: Text(
                                  "Position ${data.docs[index]['position']}"),
                              trailing: Text(
                                "Verified: ${data.docs[index]['verification']}",
                                style: const TextStyle(color: Colors.blueGrey),
                              ),
                              onTap: (() {
                                candidate.fullnames =
                                    data.docs[index]['fullnames'];
                                candidate.regNo = data.docs[index]['regNo'];
                                candidate.phoneNo = data.docs[index]['phoneNo'];
                                candidate.faculty = data.docs[index]['faculty'];
                                candidate.position =
                                    data.docs[index]['position'];
                                candidate.category = widget.type;
                                candidate.transcript =
                                    data.docs[index]['transcriptUrl'];
                                candidate.signature =
                                    data.docs[index]['signatureUrl'];
                                Navigator.of(context).push(const AdminSide()
                                    .route(ApplicantVerification(
                                        candidate: candidate)));
                              }),
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

enum Cumulative { yes, no }

enum Signature { yes, no }

enum Ethical { yes, no }

enum Programme { yes, no }

class ApplicantVerification extends StatefulWidget {
  const ApplicantVerification({super.key, required this.candidate});

  final Candidate candidate;
  @override
  State<ApplicantVerification> createState() => _VerificationState();
}

class _VerificationState extends State<ApplicantVerification> {
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text(
                "Error launching url",
                style: TextStyle(color: Colors.red),
              ),
            );
          });
    }
  }

  Future<void> verifiedCandidates(bool isApproved, String status) async {
    final CollectionReference candidates =
        FirebaseFirestore.instance.collection("verified_candidates");
    return candidates.doc(widget.candidate.regNo.replaceAll("/", ".")).set({
      "fullnames": widget.candidate.fullnames,
      "regNo": widget.candidate.regNo,
      "phoneNo": widget.candidate.phoneNo,
      "faculty": widget.candidate.faculty,
      "category": widget.candidate.category,
      "position": widget.candidate.position,
      "approved": isApproved,
      "reason": status,
    });
  }

  Future<void> verificationStatus(String regNo, String type) async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection(type)
        .doc(regNo.replaceAll("/", "."));

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(documentReference, {'verification': 'Yes'});
    });
  }

  bool _isCumulative = false;
  bool _isEthical = false;
  bool _isNominated = false;
  bool _isProgramme = false;

  Cumulative cumulative = Cumulative.no;
  Ethical ethical = Ethical.no;
  Signature signature = Signature.no;
  Programme programme = Programme.no;

  List<String> disqualifiers = [
    "Below 60 points",
    "Wrong academic year",
    "Not morally sound",
    "Inadequate nominations by members",
    "Other"
  ];

  String disqualifier = "Below 60 points";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "${widget.candidate.fullnames.split(' ').first} verification",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.candidate.fullnames),
          leading: InkWell(
            onTap: (() => Navigator.pop(context)),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Table(
                  defaultColumnWidth: const FixedColumnWidth(120.0),
                  border: TableBorder.all(
                    color: Colors.black,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  children: [
                    TableRow(children: [
                      Column(
                        children: const [
                          Text(
                            "Fullnames",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18.0),
                          )
                        ],
                      ),
                      Column(
                        children: const [
                          Text(
                            "RegNo",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18.0),
                          )
                        ],
                      ),
                      Column(
                        children: const [
                          Text(
                            "Phone No",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18.0),
                          )
                        ],
                      ),
                      Column(
                        children: const [
                          Text(
                            "Faculty",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18.0),
                          )
                        ],
                      ),
                      Column(
                        children: const [
                          Text(
                            "Position",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18.0),
                          )
                        ],
                      ),
                      Column(
                        children: const [
                          Text(
                            "Transcript",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18.0),
                          )
                        ],
                      ),
                      Column(
                        children: const [
                          Text(
                            "Signatures",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18.0),
                          )
                        ],
                      )
                    ]),
                    TableRow(children: [
                      Column(
                        children: [Text(widget.candidate.fullnames)],
                      ),
                      Column(
                        children: [Text(widget.candidate.regNo)],
                      ),
                      Column(
                        children: [Text(widget.candidate.phoneNo)],
                      ),
                      Column(
                        children: [Text(widget.candidate.faculty)],
                      ),
                      Column(
                        children: [Text(widget.candidate.position)],
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: (() =>
                                _launchUrl(widget.candidate.transcript)),
                            icon: const Icon(
                              Icons.download,
                              size: 17,
                            ),
                            tooltip: 'Download transcript',
                          )
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: (() =>
                                _launchUrl(widget.candidate.signature)),
                            icon: const Icon(
                              Icons.download,
                              size: 17,
                            ),
                            tooltip: 'Download signatures',
                          )
                        ],
                      ),
                    ])
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
                child: Text(
                  "Does ${widget.candidate.fullnames.split(' ').first} have a minimum of 60 points?",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                title: const Text("Yes"),
                leading: Radio(
                  value: Cumulative.yes,
                  groupValue: cumulative,
                  onChanged: (value) {
                    setState(() {
                      cumulative = value!;
                      _isCumulative = true;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("No"),
                leading: Radio(
                  value: Cumulative.no,
                  groupValue: cumulative,
                  onChanged: (value) {
                    setState(() {
                      cumulative = value!;
                      _isCumulative = false;
                    });
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
                child: Text(
                  "Is ${widget.candidate.fullnames.split(' ').first} in the right programe and has more than 2 semesters left and has stayed in school for more than 2 semesters?",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                title: const Text("Yes"),
                leading: Radio(
                  value: Programme.yes,
                  groupValue: programme,
                  onChanged: (value) {
                    setState(() {
                      programme = value!;
                      _isProgramme = true;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("No"),
                leading: Radio(
                  value: Programme.no,
                  groupValue: programme,
                  onChanged: (value) {
                    setState(() {
                      programme = value!;
                      _isProgramme = false;
                    });
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
                child: Text(
                  "Is ${widget.candidate.fullnames.split(' ').first} morally sound?",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                title: const Text("Yes"),
                leading: Radio(
                  value: Ethical.yes,
                  groupValue: ethical,
                  onChanged: (value) {
                    setState(() {
                      ethical = value!;
                      _isEthical = true;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("No"),
                leading: Radio(
                  value: Ethical.no,
                  groupValue: ethical,
                  onChanged: (value) {
                    setState(() {
                      ethical = value!;
                      _isEthical = false;
                    });
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
                child: Text(
                  "Does ${widget.candidate.fullnames.split(' ').first} have the required signatures?",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                title: const Text("Yes"),
                leading: Radio(
                  value: Signature.yes,
                  groupValue: signature,
                  onChanged: (value) {
                    setState(() {
                      signature = value!;
                      _isNominated = true;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("No"),
                leading: Radio(
                  value: Signature.no,
                  groupValue: signature,
                  onChanged: (value) {
                    setState(() {
                      signature = value!;
                      _isNominated = false;
                    });
                  },
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: (_isCumulative &&
                            _isProgramme &&
                            _isEthical &&
                            _isNominated)
                        ? (() {
                            verificationStatus(widget.candidate.regNo,
                                    widget.candidate.category)
                                .then((value) => verifiedCandidates(
                                    true, "Qualification, Successful!"))
                                .then((value) => Navigator.of(context)
                                    .pushAndRemoveUntil(
                                        const AdminSide()
                                            .route(const AdminHome()),
                                        (route) => false));
                          })
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        minimumSize: const Size(120, 45)),
                    child: const Text("Approve"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: ElevatedButton(
                      onPressed: (!(_isCumulative &&
                              _isProgramme &&
                              _isEthical &&
                              _isNominated))
                          ? (() {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (BuildContext context,
                                          StateSetter setState) {
                                        return AlertDialog(
                                          content: SizedBox(
                                            height: 150,
                                            width: 400,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                DropdownButton(
                                                  isExpanded: true,
                                                  icon: const Icon(Icons
                                                      .arrow_drop_down_circle_sharp),
                                                  value: disqualifier,
                                                  items: disqualifiers.map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 16),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      disqualifier = value!;
                                                    });
                                                  },
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: TextButton(
                                                      onPressed: (() {
                                                        verificationStatus(
                                                                widget.candidate
                                                                    .regNo,
                                                                widget.candidate
                                                                    .category)
                                                            .then((value) =>
                                                                verifiedCandidates(
                                                                    false,
                                                                    disqualifier))
                                                            .then((value) => Navigator
                                                                    .of(context)
                                                                .pushAndRemoveUntil(
                                                                    const AdminSide()
                                                                        .route(
                                                                            const AdminHome()),
                                                                    (route) =>
                                                                        false));
                                                      }),
                                                      child:
                                                          const Text("Submit")),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  });
                            })
                          : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          minimumSize: const Size(120, 45)),
                      child: const Text("Disqualify"),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
