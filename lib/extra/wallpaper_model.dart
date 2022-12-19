class WallpaperModel {
  late String thumbnail;
  late String original;

  WallpaperModel.fromJson(Map<String, dynamic> json) {
    thumbnail = json['medium'];
    original = json['large2x'];
  }
}
