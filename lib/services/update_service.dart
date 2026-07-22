import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const String owner = "woorog";
  static const String repo = "viewer";

  static const releasePage =
      "https://github.com/woorog/viewer/releases/latest";

  static Future<bool> hasUpdate() async {
    final package = await PackageInfo.fromPlatform();

    final currentVersion = package.version;

    final response = await http.get(
      Uri.parse(
        "https://api.github.com/repos/$owner/$repo/releases/latest",
      ),
    );

    if (response.statusCode != 200) {
      return false;
    }

    final json = jsonDecode(response.body);

    final latestVersion =
    (json["tag_name"] as String).replaceFirst("v", "");

    return latestVersion != currentVersion;
  }

  static Future<String?> getDownloadUrl() async {
    final response = await http.get(
      Uri.parse(
        "https://api.github.com/repos/$owner/$repo/releases/latest",
      ),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body);

    final assets = json["assets"];

    if (assets == null || assets.isEmpty) {
      return null;
    }

    return assets.first["browser_download_url"];
  }


  static Future<String?> getLatestVersion() async {
    final response = await http.get(
      Uri.parse(
        "https://api.github.com/repos/$owner/$repo/releases/latest",
      ),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body);

    return (json["tag_name"] as String).replaceFirst("v", "");
  }


}