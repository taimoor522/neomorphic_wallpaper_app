import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:wallpaper_app/cubit/wallpaper_cubit.dart';
import 'package:wallpaper_app/screens/wallpaper_screen.dart';
import 'package:wallpaper_app/extra/constants.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WallpaperCubit()..getWallpapers(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        title: 'Wall Print',
        home: const WallpaperScreen(),
      ),
    );
  }
}
