import 'dart:convert';
import 'dart:io';

import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_app/loaction_enum.dart';
import 'package:wallpaper_app/wallpaper_model.dart';

part 'wallpaper_state.dart';

class WallpaperCubit extends Cubit<WallpaperState> {
  WallpaperCubit() : super(WallpaperLoading());
  List<WallpaperModel> wallpapers = [];

  Future<void> getWallpapers(String query) async {
    try {
      emit(WallpaperLoading());
      wallpapers = await _getWallpaper(query);
      emit(WallpaperLoaded(wallpapers));
    } catch (e) {
      emit(WallpaperError(e.toString()));
    }
  }

  Future<File?> downloadWallpaper(String url) async {
    try {
      var response = await get(Uri.parse(url));
      var documentDirectory = await getApplicationDocumentsDirectory();
      var filePath = '${documentDirectory.path}/${DateTime.now().toIso8601String()}.jpg';
      File file = File(filePath);
      file.writeAsBytesSync(response.bodyBytes);
      return file;
    } catch (e) {
      return null;
    }
  }

  Future<void> setWallpaper(String wallpaperFile, WallpaperLocation location) async {
    try {
      if (location == WallpaperLocation.both) {
        await _setWallpaper(wallpaperFile, WallpaperLocation.home);
        await _setWallpaper(wallpaperFile, WallpaperLocation.lock);
      } else {
        await _setWallpaper(wallpaperFile, location);
      }
      emit(WallpaperAppliedSuccess());
    } catch (_) {
      debugPrint('LOG : Failed to set wallpaper $_');

      emit(WallpaperAppliedFailed());
    }
  }

  Future<void> _setWallpaper(String file, WallpaperLocation location) async {
    debugPrint('LOG : Setting wallpaper $file on $location');

    await AsyncWallpaper.setWallpaperFromFile(
      filePath: file,
      wallpaperLocation: location.value,
      goToHome: false,
    );
    debugPrint('LOG : wallpaper set');
  }

  Future<List<WallpaperModel>> _getWallpaper(String query) async {
    final Response response =
        await get(Uri.parse('https://api.pexels.com/v1/search?query=$query&per_page=60'), headers: {
      'Authorization': '563492ad6f91700001000001b3ae24f441c044c28f417864a1aff69b',
    });
    if (response.statusCode == 200) {
      final List<WallpaperModel> wallpapers = [];
      final Map<String, dynamic> data = jsonDecode(response.body);
      data['photos'].forEach((element) {
        wallpapers.add(WallpaperModel.fromJson(element['src']));
      });
      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}
