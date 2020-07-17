import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:la_roue_du_forcage/SharedPreferences.dart';
import 'package:la_roue_du_forcage/static_classes/Common.dart';
import 'package:smart_select/smart_select.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferencesDevice _prefs = SharedPreferencesDevice.instance;

  List<int> _selectedSmart = [];
  List<SmartSelectOption<int>> _itemsSmart = [];
  List<dynamic> _items;

  bool _showAddContainer = false;
  File _image;
  final picker = ImagePicker();

  final quarterNameController = TextEditingController();

  void saveNewQuarter() async {
    if (_image == null ||
        quarterNameController.text == null ||
        quarterNameController.text.length < 1) {
      return showSnackbar(context, "Sorry, il manque des infos");
    }

    int index =
        _items.indexWhere((e) => e['label'] == quarterNameController.text);
    if (index != -1)
      return showSnackbar(context, "Sorry, tu as déjà utilisé ce nom");

    await Permission.storage.request().isGranted;

    String quarterName = quarterNameController.text;

    _items.add({
      "label": quarterName,
      "image": _image.path,
      "active": true,
      "custom": true
    });

    await _prefs.saveItems(_items);
    await setItemsList();

    setState(() {
      _showAddContainer = false;
      _image = null;
      quarterNameController.clear();
      FocusScope.of(context).requestFocus(new FocusNode());
    });

    showSnackbar(context, "La roue est prête !");
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File croppedFile = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      cropStyle: CropStyle.circle,
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true),
    );

    if (croppedFile == null) return;

    String localPath = await generateImagePath(path.basename(croppedFile.path));

    final File newImage = await File(croppedFile.path).copy(localPath);

    setState(() {
      _image = newImage;
    });
  }

  Future<void> setItemsList() async {
    await _prefs.loadPrefs();
    _items = _prefs.getItems();
    _itemsSmart = [];
    _selectedSmart = [];

    for (var i = 0; i < _items.length; i++) {
      _itemsSmart
          .add(SmartSelectOption<int>(value: i, title: _items[i]['label']));
      if (_items[i]['active']) _selectedSmart.add(i);
    }

    setState(() {
      _itemsSmart = _itemsSmart;
      _selectedSmart = _selectedSmart;
    });
  }

  void onChange(List<int> val) {
    if (val.length < 2) {
      showSnackbar(context, "Sorry, pas moins de 2 réseaux");
    } else if (val.length > 10) {
      showSnackbar(context, "Sorry, pas plus de 10 réseaux");
    } else {
      setState(() => _selectedSmart = val);

      for (var i = 0; i < _items.length; i++) {
        _items[i]['active'] = false;
      }
      for (int index in val) {
        _items[index]['active'] = true;
      }

      _prefs.saveItems(_items);
      showSnackbar(context, "La roue est prête !");
    }
  }

  void showConfirmationReset() {
    showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: Text("Confirmer la réinitialisation"),
        content: Text("Cette action enlève tous les réseaux personnals"),
        actions: <Widget>[
          BasicDialogAction(
            title: Text("Annuler"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          BasicDialogAction(
            title: Text("Confimer"),
            onPressed: () async {
              await _prefs.resetListItems();
              await setItemsList();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    setItemsList();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    quarterNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 10),
              child: SmartSelect<int>.multiple(
                title: 'Réseaux sociaux',
                value: _selectedSmart,
                options: _itemsSmart,
                onChange: onChange,
              ),
            ),
            new Divider(
              color: Colors.grey,
              height: 20,
            ),
            _showAddContainer
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          maxLines: 1,
                          maxLength: 25,
                          controller: quarterNameController,
                          decoration: InputDecoration(
                            hintText: 'Nom du réseau',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Container(height: 10),
                        Center(
                          child: GestureDetector(
                            onTap: getImage,
                            child: _image == null
                                ? Image.asset(
                                    "assets/images/upload.png",
                                    height: 200,
                                    width: 200,
                                  )
                                : CircleAvatar(
                                    radius: 100,
                                    backgroundImage: Image.file(_image,
                                            height: 200, width: 200)
                                        .image),
                          ),
                        ),
                        Container(height: 10),
                        RaisedButton(
                          child: Text("Enregistrer"),
                          onPressed: saveNewQuarter,
                        ),
                      ],
                    ),
                  )
                : Container(
                    child: FlatButton(
                      child: Text("Ajouter un réseau personnel"),
                      onPressed: () =>
                          {setState(() => _showAddContainer = true)},
                    ),
                  ),
            new Divider(
              color: Colors.grey,
              height: 20,
            ),
            Container(
              child: FlatButton(
                child: Text(
                  "Réinitialiser les paramètres",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onPressed: () async {
                  showConfirmationReset();
                },
              ),
            ),
            new Divider(
              color: Colors.grey,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
