import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:la_roue_du_forcage/SettingsPage.dart';
import 'package:la_roue_du_forcage/SharedPreferences.dart';
import 'package:soundpool/soundpool.dart';

import 'wheel_classes/BoardView.dart';
import 'wheel_classes/Quarter.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  SharedPreferencesDevice _prefs = SharedPreferencesDevice.instance;

  double _angle = 0;
  double _current = 0;
  AnimationController _ctrl;
  Animation _ani;
  List<Quarter> _itemsList = [];
  bool _listMade = false;

  String _mainText = "";

  Soundpool pool = Soundpool(streamType: StreamType.music);
  int _wheelSoundId;
  int _successSoundId;

  ConfettiController _controllerBottomCenter;

  final _random = new Random();
  int next(int min, int max) => min + _random.nextInt(max - min);

  Future<void> setItemsList() async {
    _itemsList = [];
    await _prefs.loadPrefs();
    List<dynamic> items = _prefs.getItems();
    int cptColor = 0;
    for (var i = 0; i < items.length; i++) {
      if (items[i]["active"]) {
        _itemsList.add(Quarter(
            items[i]["image"], Colors.accents[cptColor], items[i]["custom"]));
        cptColor++;
      }
    }

    setState(() {
      _listMade = true;
    });
  }

  String getRandownSentence() {
    List<String> sentences = [
      'IL EST TEMPS\nDE FORCER !',
      'QUE LE FORÇAGE\nSOIT AVEC TOI !',
      'BALANCE TON BLAZE\nSANS PRESSION',
      'SAH QUEL PLAISIR\nDE FORCER',
      'JE FORCE TU\nFORCES IL FOLLOW',
      'MULTI-PLATEFORME\nMULTI-TALENTS TMTC',
      'FOLLOW POUR\nMANGÉ SVP MERSI',
      'LA ROUE DE\nLA LÈCHE SLURP',
      'ALLEZ VIENS\nON EST BIEN...',
      '#OMNIPRÉSENCE\nSI SI'
    ];

    int randomIndex = next(0, sentences.length);
    return sentences[randomIndex];
  }

  Future navigateToSettings(context) async {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsPage()))
        .then((value) {
      setState(() {
        setItemsList();
      });
    });
  }

  Future<void> loadSounds() async {
    _wheelSoundId = await rootBundle
        .load("assets/sounds/wheel-sound-single.mp3")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });

    _successSoundId = await rootBundle
        .load("assets/sounds/success.mp3")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
  }

  Future<void> playSound(id) async {
    if (id != null) await pool.play(id);
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _mainText = getRandownSentence();
    });

    _controllerBottomCenter =
        ConfettiController(duration: const Duration(milliseconds: 500));

    var _duration = Duration(milliseconds: 7000);
    _ctrl = AnimationController(vsync: this, duration: _duration);
    _ani = CurvedAnimation(parent: _ctrl, curve: Curves.fastLinearToSlowEaseIn);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setItemsList();
      loadSounds();

      _ctrl.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controllerBottomCenter.play();
          playSound(_successSoundId);
        }
      });
    });
  }

  @override
  void dispose() {
    _controllerBottomCenter.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    var heightScreen = MediaQuery.of(context).size.height;
    var widthScreen = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green, Colors.blue.withOpacity(0.2)])),
          child: AnimatedBuilder(
              animation: _ani,
              builder: (context, child) {
                if (!_listMade) return Container();

                final _value = _ani.value;
                final _angle = _value * this._angle;
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                          icon: Icon(
                            Icons.settings,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () => {navigateToSettings(context)}),
                    ),
                    Positioned(
                      top: heightScreen / 2 - (widthScreen / 2 / 0.75),
                      left: 0,
                      width: widthScreen,
                      child: Center(
                        child: Text(
                          _mainText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'LilitaOne',
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    BoardView(
                        items: _itemsList, current: _current, angle: _angle),
                    _buildGo(),
                    _buildResult(_value),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ConfettiWidget(
                        confettiController: _controllerBottomCenter,
                        blastDirection: -pi / 2,
                        emissionFrequency: 1,
                        numberOfParticles: 7,
                        gravity: 0.1,
                        maxBlastForce: 120,
                        minBlastForce: 60,
                        blastDirectionality: BlastDirectionality.explosive,
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  _buildGo() {
    return Material(
      color: Colors.white,
      shape: CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(),
        child: Container(
          alignment: Alignment.center,
          height: 72,
          width: 72,
          child: Text(
            "GO",
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: _animation,
      ),
    );
  }

  _animation() async {
    if (!_ctrl.isAnimating) {
      var _random = Random().nextDouble();
      _angle = 20 + Random().nextInt(5) + _random;
      _ctrl.forward(from: 0.0).then((_) {
        _current = (_current + _random);
        _current = _current - _current ~/ 1;
        _ctrl.reset();
      });
    }
  }

  int _calIndex(value) {
    var _base = (2 * pi / _itemsList.length / 2) / (2 * pi);
    return (((_base + value) % 1) * _itemsList.length).floor();
  }

  dynamic _lastAsset;

  _buildResult(_value) {
    var _index = _calIndex(_value * _angle + _current);
    dynamic _asset = _itemsList[_index].asset;
    if (_lastAsset != _asset) {
      _lastAsset = _asset;
      playSound(_wheelSoundId);
    }

    bool _iscustom = _itemsList[_index].iscustom;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _iscustom
            ? CircleAvatar(
                radius: 50,
                backgroundImage:
                    Image.file(_asset, height: 100, width: 100).image,
              )
            : Image.asset(_asset, height: 100, width: 100),
      ),
    );
  }
}
