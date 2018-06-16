import 'package:flutter/material.dart';

typedef void ArgCallback<T>(T arg);

class RedistributeGroupsDialog extends StatefulWidget {
  final VoidCallback generateGroups;
  final BuildContext context;

  const RedistributeGroupsDialog({Key key, this.generateGroups, this.context})
      : super(key: key);

  @override
  State<RedistributeGroupsDialog> createState() =>
      _RedistributeGroupsDialogState();
}

class _RedistributeGroupsDialogState extends State<RedistributeGroupsDialog> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        loading
            ? "Making groups ..."
            : "Groups will be lost.\n Confirm action?",
      ),
      content: loading ? LinearProgressIndicator() : null,
      actions: <Widget>[
        FlatButton(
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          onPressed: loading
              ? null
              : () {
                  Navigator.of(widget.context).pop();
                },
        ),
        FlatButton(
          child: Text("Redistribute groups"),
          onPressed: loading
              ? null
              : () {
                  setState(() {
                    loading = true;
                  });
                  widget.generateGroups();
                  Navigator.of(widget.context).pop();
                },
        )
      ],
    );
  }
}

class LoadDialog extends StatefulWidget {
  final List<String> filenames;
  final BuildContext context;
  final ArgCallback<String> onConfirm;
  final ArgCallback<String> onDelete;

  const LoadDialog({
    Key key,
    this.filenames,
    this.context,
    this.onConfirm,
    this.onDelete,
  }) : super(key: key);

  @override
  State<LoadDialog> createState() => _LoadDialogState();
}

class _LoadDialogState extends State<LoadDialog> {
  String filename;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Load groups from saved"),
      content: DropdownButton<String>(
        value: filename,
        items:
            [DropdownMenuItem<String>(value: null, child: Text("Choose ..."))] +
                widget.filenames
                    .map((String filename) => DropdownMenuItem<String>(
                          value: filename,
                          child: Text(filename),
                        ))
                    .toList(),
        onChanged: (String filename) {
          setState(() {
            this.filename = filename;
          });
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text(
            "OK",
          ),
          onPressed: filename != null
              ? () {
                  widget.onConfirm(filename);
                  Navigator.of(context).pop();
                }
              : null,
        ),
        FlatButton(
          child: Text(
            "Delete",
          ),
          textColor: Colors.red,
          onPressed: filename != null
              ? () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm deletion"),
                          content: Text("This action can not be undone."),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("Cancel"),
                              textColor: Colors.blue,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                              child: Text("Delete"),
                              textColor: Colors.red,
                              onPressed: () {
                                widget.onDelete(filename);
                                setState(() {
                                  widget.filenames.remove(filename);
                                  filename = null;
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                }
              : null,
        ),
      ],
    );
  }
}

class SaveDialog extends StatefulWidget {
  final BuildContext context;
  final String defaultName;
  final ArgCallback<String> onConfirm;

  const SaveDialog({Key key, this.context, this.defaultName, this.onConfirm})
      : super(key: key);

  @override
  State<SaveDialog> createState() => _SaveDialogState(defaultName);
}

class _SaveDialogState extends State<SaveDialog> {
  String filename;
  TextEditingController controller;

  _SaveDialogState(this.filename) {
    controller = TextEditingController(text: filename);
  }

  static bool validate(String s) {
    if (s == null) return false;
//    if (!s.contains(r"/\S/")) return false;
    if (s.contains("/")) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Save groups as ..."),
      content: TextField(
        autocorrect: false,
        controller: controller,
        onChanged: (String s) {
          setState(() {
            filename = s;
          });
        },
        autofocus: true,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text(
            "OK",
          ),
          onPressed: validate(filename)
              ? () {
                  widget.onConfirm(filename);
                  Navigator.of(context).pop();
                }
              : null,
        ),
      ],
    );
  }
}
