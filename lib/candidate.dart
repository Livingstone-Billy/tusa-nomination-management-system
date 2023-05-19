class Candidate {
  String fullnames;
  String regNo;
  String phoneNo;
  String faculty;
  String category;
  String position;
  String transcript;
  String signature;

  Candidate(this.fullnames, this.regNo, this.phoneNo, this.faculty,
      this.category, this.position, this.transcript, this.signature);

  Map<String, dynamic> toMap() {
    return {
      "fullnames": fullnames,
      "regNo": regNo,
      "phoneNo": phoneNo,
      "faculty": faculty,
      "category": category,
      "position": position,
      "transcript": transcript,
      "signature": signature
    };
  }
}
