import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

List<Map<String, dynamic>> defaultItems = [
  {
    "label": "Instagram",
    "image": "instagram-dreamstale43",
    "active": true,
    "custom": false
  },
  {
    "label": "Twitter",
    "image": "twitter-dreamstale71",
    "active": true,
    "custom": false
  },
  {
    "label": "YouTube",
    "image": "youtube2-dreamstale87",
    "active": true,
    "custom": false
  },
  {
    "label": "Facebook",
    "image": "facebook-dreamstale25",
    "active": true,
    "custom": false
  },
  {
    "label": "Snapchat",
    "image": "snapchat-dreamstale62",
    "active": true,
    "custom": false
  },
  {
    "label": "LinkedIn",
    "image": "linkedin-dreamstale45",
    "active": false,
    "custom": false
  },
  {"label": "Discord", "image": "discord", "active": false, "custom": false},
  {
    "label": "Pinterest",
    "image": "pinterest-dreamstale57",
    "active": false,
    "custom": false
  },
  {
    "label": "Blogger",
    "image": "blogger-dreamstale12",
    "active": false,
    "custom": false
  },
  {
    "label": "Soundcloud",
    "image": "soundcloud-dreamstale63",
    "active": false,
    "custom": false
  },
  {
    "label": "Podcast",
    "image": "feed-dreamstale27",
    "active": false,
    "custom": false
  },
  {
    "label": "Paypal",
    "image": "paypal-dreamstale54",
    "active": false,
    "custom": false
  },
  {
    "label": "Steam",
    "image": "steam-dreamstale65",
    "active": false,
    "custom": false
  },
  {
    "label": "GitHub",
    "image": "github2-dreamstale35",
    "active": false,
    "custom": false
  },
  {
    "label": "Fiverr",
    "image": "fiverr-dreamstale29",
    "active": false,
    "custom": false
  }
];

void showSnackbar(context, text) {
  Flushbar(
    message: text,
    duration: Duration(seconds: 3),
  )..show(context);
}

Future<String> generateImagePath(String imageName) async {
  var uuid = Uuid();
  Directory tempDir = await getApplicationDocumentsDirectory();
  String tempPath = tempDir.path;

  return (tempPath + "/" + uuid.v4() + imageName);
}
