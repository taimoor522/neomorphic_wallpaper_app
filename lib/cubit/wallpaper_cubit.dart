import 'dart:convert';
import 'dart:io';

import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_app/extra/constants.dart';
import 'package:wallpaper_app/extra/location_enum.dart';
import 'package:wallpaper_app/extra/wallpaper_model.dart';

part 'wallpaper_state.dart';

class WallpaperCubit extends Cubit<WallpaperState> {
  WallpaperCubit() : super(WallpaperLoading());
  List<WallpaperModel> wallpapers = [];
  String _lastQuery = 'abstract art';

  Future<void> getWallpapers([String? query]) async {
    query == null || query.isEmpty ? query = _lastQuery : _lastQuery = query;
    try {
      emit(WallpaperLoading());
      wallpapers = await _getWallpapers(query);
      emit(WallpaperLoaded(wallpapers));
    } catch (e) {
      emit(WallpaperError(e.toString()));
    }
  }

  Future<File?> downloadWallpaper(String url) async {
    try {
      Directory dir = await getTemporaryDirectory();
      var response = await get(Uri.parse(url));
      var filePath = '${dir.path}/${DateTime.now().toIso8601String()}.jpg';
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
      emit(WallpaperAppliedFailed());
    } finally {
      _removeTemporaryFiles();
    }
  }

  void _removeTemporaryFiles() async {
    final Directory tempDir = await getTemporaryDirectory();
    tempDir.existsSync() ? tempDir.deleteSync(recursive: true) : null;
  }

  Future<void> _setWallpaper(String file, WallpaperLocation location) async {
    await AsyncWallpaper.setWallpaperFromFile(
      filePath: file,
      wallpaperLocation: location.value,
      goToHome: false,
    );
  }

  Future<List<WallpaperModel>> _getWallpapers(String query) async {
    query = query.replaceAll(' ', '+');
    final Response response = await get(
      Uri.parse('https://api.pexels.com/v1/search?query=$query&per_page=60'),
      headers: {'Authorization': key},
    );
    if (response.statusCode == 200) {
      final List<WallpaperModel> wallpapers = [];
      final Map<String, dynamic> data = jsonDecode(response.body);
      data['photos'].forEach((element) {
        wallpapers.add(WallpaperModel.fromJson(element['src']));
      });
      return wallpapers;
    } else {
      throw Exception();
    }
  }
}
