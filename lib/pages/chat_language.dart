import 'package:flutter/material.dart';
import 'package:language_picker/language_picker_dialog.dart';
import 'package:language_picker/languages.dart';

class ChatLanguage extends StatefulWidget {
  @override
  _ChatLanguageState createState() => _ChatLanguageState();
}

class _ChatLanguageState extends State<ChatLanguage> {

// It's sample code of Dialog Item.
  Widget _buildDialogItem(Language language) => Row(
        children: <Widget>[
          Text(language.name),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text("Chat Language Preference"),
        elevation: 0.1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: LanguagePickerDialog(
              titlePadding: EdgeInsets.all(8.0),
              searchCursorColor: Colors.pinkAccent,
              searchInputDecoration: InputDecoration(hintText: 'Search...'),
              isSearchable: true,
              title: Text('Add a language'),
              onValuePicked: (Language language) => setState(() {
                    Language _selectedDialogLanguage = language;
                    print(_selectedDialogLanguage.name);
                    print(_selectedDialogLanguage.isoCode);
                  }),
              itemBuilder: _buildDialogItem,
          ),
        ),
      ),
    );
  }
}
