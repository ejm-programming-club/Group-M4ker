import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:googleapis/drive/v3.dart";
import "package:googleapis_auth/auth_io.dart";
import 'package:group_m4ker/frontend/dialogs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

String id =
    "608822766724-pi3a8252ffqhfarou58q5tmk90lq217r.apps.googleusercontent.com";

var scopes = [DriveApi.DriveReadonlyScope];

/// Get secrets before the sign in
void beforeDriveSignIn(BuildContext context, dynamic doneCallback) {
  rootBundle.loadStructuredData("secrets.json", (jsonStr) async {
    driveSignIn(
      ClientId(id, json.decode(jsonStr)["key"]),
      context,
      doneCallback,
    );
  });
}

/// 1. Make user sign in through browser
/// 2. Launch the searching dialog
void driveSignIn(ClientId id, BuildContext context, dynamic doneCallback) {
  clientViaUserConsent(id, scopes, (url) => launch(url))
      .then((AuthClient client) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => DriveFileSearcher(
            context: context,
            client: client,
            doneCallback: doneCallback,
          ),
    );
  });
}

/// Popup that allows searching for spreadsheets and download in CSV format
class DriveFileSearcher extends StatefulWidget {
  final BuildContext context;
  final AuthClient client;
  final dynamic doneCallback;

  const DriveFileSearcher(
      {Key key, this.context, this.client, this.doneCallback})
      : super(key: key);

  @override
  State<DriveFileSearcher> createState() => _DriveFileSearcher(client);
}

class _DriveFileSearcher extends State<DriveFileSearcher> {
  List<File> results = [];
  String selectedId;
  final AuthClient client;
  final driveApi;

  static const String queryPrefix =
      "mimeType = 'application/vnd.google-apps.spreadsheet' and";

  _DriveFileSearcher(this.client) : driveApi = DriveApi(client) {
    // Display all spreadsheets
    onQueryChanged("");
  }

  void onQueryChanged(String query) {
    driveApi.files
        .list(q: "$queryPrefix name contains '$query'")
        .then((FileList fileList) {
      setState(() {
        results = fileList.files;
        print(results.map((f) => f.name));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Search Googe Drive"),
      content: new Column(
        children: <Widget>[
          TextField(
            onChanged: onQueryChanged,
            decoration: new InputDecoration(
              hintText: 'Name of spreadsheet',
            ),
          ),
          new Padding(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.6,
              child: results.length != 0
                  ? ListView(
                      physics: new AlwaysScrollableScrollPhysics(),
                      children: results
                          .map((File f) => new FlatButton(
                                child: new Row(
                                  children: <Widget>[
                                    Icon(Icons.insert_drive_file),
                                    SizedBox(width: 10.0),
                                    Text(f.name),
                                  ],
                                ),
                                color: f.id == selectedId
                                    ? Colors.lightBlue[100]
                                    : Color(0xFAFAFA),
                                onPressed: () =>
                                    setState(() => selectedId = f.id),
                              ))
                          .toList(),
                    )
                  : Text(
                      "No results",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14.0,
                      ),
                    ),
            ),
            padding: new EdgeInsets.only(top: 20.0),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("CANCEL"),
          textColor: Colors.red,
        ),
        new FlatButton(
          onPressed: selectedId == null
              ? null
              : () {
                  driveApi.files
                      .export(
                    selectedId,
                    "text/csv",
                    downloadOptions: DownloadOptions.FullMedia,
                  )
                      .then((response) {
                    // decode csv
                    String csv = "";
                    response.stream
                        .transform(utf8.decoder)
                        .listen((line) => csv += line)
                        .onDone(() async {
                      final dir = await getApplicationDocumentsDirectory();
                      io.Directory("${dir.path}/state").createSync();
                      String path = dir.path;
                      final file = new io.File("$path/state/promo.csv");
                      file.writeAsStringSync(csv);
                      widget.doneCallback((List<String> msg) async {
                        await infoDialog(msg.join("\n"), context);
                        Navigator.of(context).pop();
                      });
                    });
                  });
                },
          child: Text("LOAD FILE"),
        )
      ],
    );
  }
}
