import 'package:flutter/material.dart';
import 'package:jam/config/routes.dart';
import 'package:jam/config/valid_chat_languages.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/get_languages.dart';
import 'package:jam/network/set_languages.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/form_widgets.dart';
import 'package:jam/widgets/goBackDialog.dart';
import 'package:jam/widgets/show_snackbar.dart';
import 'package:language_picker/language_picker_dialog.dart';
import 'package:language_picker/languages.dart';
import 'package:provider/provider.dart';

class ChatLanguage extends StatefulWidget {
  @override
  _ChatLanguageState createState() => _ChatLanguageState();
}

bool okVisible = false;

class _ChatLanguageState extends State<ChatLanguage> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;
    List<dynamic>? languages = user.chatLanguages;

    if (!ModalRoute.of(context)!.isFirst) {
      okVisible = false;
    }

    void _callAddLanguageApi(String iso) async {
      setLanguages(user, [iso], true, context).then((success) async {
        if (success == 1) {
          setState(() {
            if (ModalRoute.of(context)!.isFirst) {
              okVisible = true;
            }
            Provider.of<UserProvider>(context, listen: false).addLanguage(iso);
          });
        } else if (success == 2) {
          showSnackBar(
              context, "It looks like you have already selected your languages");
          List<String>? langs = await getLanguagesCall(user.id!, user.token!, user.id!);
          if (langs != null) {
            setState(() {
              if (ModalRoute.of(context)!.isFirst) {
                okVisible = true;
              }
              Provider.of<UserProvider>(context, listen: false).overrideLanguages(langs);
            });
          }
        }
        else {
          showSnackBar(
              context, "Could not add language, check your connection");
        }
      }, onError: (error) {
        showSnackBar(context, "Could not add language");
      });
    }

    void _callRemoveLanguageApi(String iso) async {
      setLanguages(user, [iso], false, context).then((success) {
        if (success == 1) {
          setState(() {
            Provider.of<UserProvider>(context, listen: false)
                .removeLanguage(iso);
            if (ModalRoute.of(context)!.isFirst &&
                user.chatLanguages?.length == 0) {
              okVisible = false;
            }
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
              languages: supportedLanguages,
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

    Future<bool> _goBack(BuildContext context) async {
      if (languages == null || languages.length == 0) {
        showDialog(
          context: context,
          builder: (context) => goBackDialog(context),
        );
      }
      return true;
    }

    return WillPopScope(
      onWillPop: () => _goBack(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: const Text("Chat Language Preference"),
          elevation: 0.1,
        ),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
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
                          margin: EdgeInsets.only(bottom: okVisible ? 80 : 40),
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
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    child: Column(
                      children: [
                        longButtons(
                          "OK",
                          () =>
                              Navigator.pushReplacementNamed(context, homepage),
                          color: Colors.green,
                        ),
                        SizedBox(
                          height: 10,
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    visible: okVisible,
                  ),
                  longButtons(
                    "Add a language",
                    _openLanguagePickerDialog,
                    color: Colors.pink,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
