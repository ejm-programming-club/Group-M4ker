///*
//import 'package:flutter/material.dart';
//import 'package:group_m4ker/backend/utils.dart';
//import 'package:group_m4ker/frontend/dialogs.dart';
//
//class ProfileView extends StatelessWidget {
//  final Student student;
//  final ArgCallback<Student> onChanged;
//
//  // Consider moving colours in a common file? (good idea or not, idk)
//  static final maleColor = Colors.blueAccent[200];
//  static final femaleColor = Colors.pinkAccent[200];
//  static final bioColor = Colors.redAccent[200];
//  static final chmColor = Colors.amberAccent[400];
//  static final phyColor = Colors.green[400];
//  static final slColor = Colors.blue[400];
//  static final hlColor = Colors.blueGrey[400];
//  static final textColor = Colors.white;
//
//  const ProfileView({Key key, this.student, this.onChanged}) : super(key: key);
//
//  Widget build(BuildContext context) {
//    List<ProfileField> fields = [
//      ProfileField(
//        header: "Name",
//        child: Chip(
//          label: Text(name),
//        ),
//      ),
//      ProfileField(
//        header: "Gender",
//        child: Chip(
//            label: Text(
//              profile.gender.toString().split('.').last,
//              style: TextStyle(
//                color: textColor,
//              ),
//            ),
//            backgroundColor: {
//              Gender.M: maleColor,
//              Gender.F: femaleColor,
//            }[profile.gender]),
//      ),
//    ];
//
//    for (Subject subject in Subject.values) {
//      Level level;
//      if (subject == Subject.BIO) level = profile.bioLevel;
//      if (subject == Subject.CHM) level = profile.chmLevel;
//      if (subject == Subject.PHY) level = profile.phyLevel;
//      if (level == null) continue;
//
//      fields.add(
//        ProfileField(
//          header: "Subject",
//          child: Row(
//            children: <Widget>[
//              Chip(
//                label: Text(
//                  subject.toString().split('.').last,
//                  style: TextStyle(
//                    color: textColor,
//                  ),
//                ),
//                backgroundColor: {
//                  Subject.BIO: bioColor,
//                  Subject.CHM: chmColor,
//                  Subject.PHY: phyColor,
//                }[subject],
//              ),
//              SizedBox(
//                width: 8.0,
//              ),
//              Chip(
//                label: Text(
//                  level.toString().split('.').last,
//                  style: TextStyle(
//                    color: textColor,
//                  ),
//                ),
//                backgroundColor: {
//                  Level.SL: slColor,
//                  Level.HL: hlColor,
//                }[level],
//              ),
//            ],
//          ),
//        ),
//      );
//    }
//
//    if (profile.isStrongLeader) {
//      fields.add(ProfileField(
//          header: "Strong leader",
//          child: Chip(
//            label: Icon(
//              Icons.check,
//              color: Colors.green,
//            ),
//            backgroundColor: Colors.white,
//          )));
//    }
//
//    return Row(
//      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//      children: fields,
//    );
//  }
//}
//*/
