import 'package:flutter/material.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/set_languages.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/form_widgets.dart';
import 'package:jam/widgets/show_snackbar.dart';
import 'package:language_picker/language_picker_dialog.dart';
import 'package:language_picker/languages.dart';
import 'package:provider/provider.dart';

class ChatLanguage extends StatefulWidget {
  @override
  _ChatLanguageState createState() => _ChatLanguageState();
}

class _ChatLanguageState extends State<ChatLanguage> {
  Widget _buildDialogItem(Language language) => Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(language.name),
          ),
        ],
      );

  void _openLanguagePickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.pink),
          child: LanguagePickerDialog(
            titlePadding: const EdgeInsets.all(8.0),
            searchCursorColor: Colors.pinkAccent,
            searchInputDecoration: InputDecoration(hintText: 'Search...'),
            isSearchable: true,
            title: const Text('Add a language'),
            onValuePicked: (Language language) {
              _callApi(language.isoCode);
            },
            itemBuilder: _buildDialogItem,
          ),
        ),
      );

  void _callApi(String iso) {
    setLanguages([iso], true).then((success) {
      if (success) {
        Provider.of<UserProvider>(context, listen: false)
            .addLanguage(iso);
      }
      else {
        showSnackBar(context, "Could not add language, check your connection");
      }
    }, onError: (error) {
      showSnackBar(context, "Could not add language");
    });
  }

  Container _languageCircle(String iso) => Container(
        margin: const EdgeInsets.all(10.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: (Color(0x88FF4081)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Language.fromIsoCode(iso).name,
                style: TextStyle(color: Colors.white),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                splashRadius: 25,
                onPressed: () {
                  print("delete $iso");
                },
                icon: Icon(
                  Icons.cancel,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;
    List<String>? languages = user.chatLanguages;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text("Chat Language Preference"),
        elevation: 0.1,
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                "Your Languages:",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              languages == null || languages.length == 0
                  ? Column(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.pinkAccent,
                        ),
                        SizedBox(height: 10),
                        const Text("You don't have any language preference."
                            "You have to select at least one language in order to match with other people."),
                      ],
                    )
                  : Container(
                      height: 500,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: languages.length,
                        itemBuilder: (context, index) {
                          return _languageCircle(languages[index]);
                        },
                      ),
                    ),
              SizedBox(height: 20),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: longButtons(
              "Add a language",
              _openLanguagePickerDialog,
              color: Colors.pink,
            ),
          ),
        ),
      ]),
    );
  }
}
