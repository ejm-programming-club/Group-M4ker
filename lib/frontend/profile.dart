import 'package:flutter/material.dart';
import 'package:correze_grouper/backend/utils.dart';

class ProfileField extends StatelessWidget {
  final String header;
  final Widget child;

  const ProfileField({Key key, this.header, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          header,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Divider(),
        child,
      ],
    );
  }
}

class ProfileChip extends StatelessWidget {
  final Color chipColor;
  final Color textColor;
  final String text;
  final double chipElevation;

  const ProfileChip({
    Key key,
    this.chipColor = const Color(0xFFFAFAFA),
    this.textColor = Colors.black,
    this.chipElevation = 1.0,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: new Padding(
        padding: new EdgeInsets.all(4.0),
        child: new Text(
            text, style: new TextStyle(color: textColor),
        ),
      ),
      color: chipColor,
      elevation: chipElevation,
    );
  }
}

class ProfilePreview extends StatelessWidget {
  final Profile profile;
  final String name;

  // Consider moving colours in a common file? (good idea or not, idk)
  static final maleColor = Colors.blueAccent[200];
  static final femaleColor = Colors.pinkAccent[200];
  static final bioColor = Colors.redAccent[200];
  static final chmColor = Colors.amber[400];
  static final phyColor = Colors.green[400];
  static final slColor = Colors.blue[400];
  static final hlColor = Colors.blueGrey[400];
  static final textColor = Colors.grey[100];

  const ProfilePreview({Key key, this.profile, this.name}) : super(key: key);

  Widget build(BuildContext context) {
    List<ProfileField> fields = [
      ProfileField(
        header: "Name",
        child: ProfileChip(
          text: name,
          chipElevation: 0.0,
        ),
      ),
      ProfileField(
        header: "Gender",
        child: ProfileChip(
          text: profile.gender.toString(),
          textColor: textColor,
          chipColor: {
            Gender.M: maleColor,
            Gender.F: femaleColor,
          }[profile.gender],
        ),
      ),
      ProfileField(
        header: "Group 4",
        child: Row(
          children: <Widget>[
            ProfileChip(
              text: profile.group4Subject.toString(),
              textColor: textColor,
              chipColor: {
                Subject.BIO: bioColor,
                Subject.PHY: phyColor,
              }[profile.group4Subject],
            ),
            ProfileChip(
              text: profile.group4Level.toString(),
              textColor: textColor,
              chipColor: {
                Level.SL: slColor,
                Level.HL: hlColor,
              }[profile.group4Level],
            ),
          ],
        ),
      ),
    ];

    if (profile.group6Subject != null) {
      fields.add(
        ProfileField(
          header: "Group 6",
          child: Row(
            children: <Widget>[
              Card(
                child: Text(
                  profile.group6Subject.toString(),
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
                color: chmColor,
              ),
              Card(
                child: Text(
                  profile.group6Level.toString(),
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
                color: {
                  Level.SL: slColor,
                  Level.HL: hlColor,
                }[profile.group6Level],
              ),
            ],
          ),
        ),
      );
    }

    if (profile.isStrongLeader) {
      fields.add(ProfileField(
        header: "Strong leader",
        child: Icon(
          Icons.check,
          color: Colors.green,
        ),
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: fields,
    );
  }
}
