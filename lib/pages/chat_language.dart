import 'package:flutter/material.dart';
import 'package:jam/config/routes.dart';
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
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;
    List<dynamic>? languages = user.chatLanguages;
    bool okVisible = false;

    void _callAddLanguageApi(String iso) async {
      setLanguages(user, [iso], true).then((success) {
        if (success) {
          setState(() {
            Provider.of<UserProvider>(context, listen: false).addLanguage(iso);
            if (ModalRoute.of(context)!.isFirst) {
              okVisible = true;
            }
          });
        } else {
          showSnackBar(
              context, "Could not add language, check your connection");
        }
      }, onError: (error) {
        showSnackBar(context, "Could not add language");
      });
    }

    void _callRemoveLanguageApi(String iso) async {
      setLanguages(user, [iso], false).then((success) {
        if (success) {
          setState(() {
            Provider.of<UserProvider>(context, listen: false)
                .removeLanguage(iso);
          });
        } else {
          showSnackBar(
              context, "Could not remove language, check your connection");
        }
      }, onError: (error) {
        showSnackBar(context, "Could not remove language");
      });
    }

    Container _circleListItem(String iso) => Container(
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
                  onPressed: () => _callRemoveLanguageApi(iso),
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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
                // don't add same language twice
                if (languages != null && languages.contains(language.isoCode)) {
                  showSnackBar(context, "You already selected this language!");
                  return;
                }
                _callAddLanguageApi(language.isoCode);
              },
              itemBuilder: (Language language) => Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(language.name),
                  ),
                ],
              ),
            ),
          ),
        );

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
                          return _circleListItem(languages[index]);
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                longButtons(
                  "Add a language",
                  _openLanguagePickerDialog,
                  color: Colors.pink,
                ),
                okVisible
                    ? longButtons(
                        "OK",
                        () => Navigator.pushReplacementNamed(context, homepage),
                        color: Colors.green,
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
