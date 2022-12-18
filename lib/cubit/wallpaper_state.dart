part of 'wallpaper_cubit.dart';

abstract class WallpaperState {}

class WallpaperLoading extends WallpaperState {}

class WallpaperLoaded extends WallpaperState {
  final List<WallpaperModel> wallpapers;
  WallpaperLoaded(this.wallpapers);
}

class WallpaperError extends WallpaperState {
  final String message;
  WallpaperError(this.message);
}

class WallpaperAppliedSuccess extends WallpaperState {
  WallpaperAppliedSuccess();
}

class WallpaperAppliedFailed extends WallpaperState {
  WallpaperAppliedFailed();
}
