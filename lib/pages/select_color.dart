import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:jam/network/update_color_prefs.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../util/util_functions.dart';
import '../widgets/form_widgets.dart';
import '../widgets/goBackDialog.dart';
import '../widgets/show_snackbar.dart';

class SelectColor extends StatefulWidget {
  final List<dynamic> userColors;
  final List<dynamic> availableColors;

  SelectColor(this.userColors, this.availableColors);

  @override
  _SelectColorState createState() => _SelectColorState();
}

bool okVisible = true;
bool isLoading = false;

class _SelectColorState extends State<SelectColor> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;

    if (!ModalRoute.of(context)!.isFirst && widget.userColors.length == 0) {
      okVisible = false;
    }

    Container _circleListItem(String hex) => Container(
          margin: const EdgeInsets.all(10.0),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (fromHex(hex.substring(1))),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: 25,
                  onPressed: () {
                    setState(() {
                      widget.userColors.remove(hex);
                      if (ModalRoute.of(context)!.isFirst &&
                          widget.userColors.length == 0) {
                        okVisible = false;
                      }
                    });
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

    Future<bool> _goBack(BuildContext context) async {
      if (widget.userColors.length == 0) {
        showDialog(
          context: context,
          builder: (context) => goBackDialog(context),
        );
      }
      return true;
    }

    void done() async {
      setState(() {
        isLoading = true;
      });
      int success = await updateColorPrefs(user, widget.userColors.cast());
      setState(() {
        isLoading = false;
      });
      if (success != 1) {
        showSnackBar(context, "Could not update colors, check your connection");
        return;
      }
      Navigator.pushReplacementNamed(context, homepage);
    }

    return WillPopScope(
      onWillPop: () => _goBack(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: const Text("Select Your Favorite Colors"),
          elevation: 0.1,
        ),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Your Colors:",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  widget.userColors.length == 0
                      ? Column(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.pinkAccent,
                            ),
                            SizedBox(height: 10),
                            const Text(
                              "Please select some colors\n\n"
                              "Start from your most favorite to your least favorite.",
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : Container(
                          margin: EdgeInsets.only(bottom: okVisible ? 80 : 40),
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: widget.userColors.length,
                            itemBuilder: (context, index) {
                              return _circleListItem(widget.userColors[index]);
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
                          isLoading ? "Please Wait..." : "OK",
                          done,
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
                    "Select Color",
                    () => showMaterialSwatchPicker(
                      context: context,
                      title: 'Select Color',
                      selectedColor: Colors.white,
                      onChanged: (value) {
                        String hexString =
                            '#${(value.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
                        print(hexString);
                        if (widget.userColors.contains(hexString)) {
                          showSnackBar(
                              context, "You already selected this color");
                          return;
                        }
                        setState(() {
                          widget.userColors.add(hexString);
                          okVisible = true;
                        });
                      },
                      headerColor: Colors.pinkAccent,
                    ),
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
