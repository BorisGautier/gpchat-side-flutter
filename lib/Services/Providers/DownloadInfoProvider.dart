import 'package:flutter/foundation.dart';

class DownloadInfoprovider with ChangeNotifier {
  int totalsize = 0;
  double downloadedpercentage = 0.0;
  calculatedownloaded(
    double newdownloadedpercentage,
    int newtotal,
  ) {
    totalsize = newtotal;
    downloadedpercentage = newdownloadedpercentage;
    notifyListeners();
  }
}
