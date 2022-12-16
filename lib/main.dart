// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_app/constants.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.black,
        colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.black,
          secondary: Colors.black,
        ),
      ),
      title: 'Wallaper App',
      home: const WallpaperScreen(),
    );
  }
}

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  final List<File> imageFiles = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    loadImages().then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  Future<void> loadImages() async {
    for (var i = 0; i < images.length; i++) {
      final byteData = await rootBundle.load(images[i]);

      final file = File('${(await getApplicationDocumentsDirectory()).path}/$i.jpeg');
      await file.writeAsBytes(
          byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      imageFiles.add(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color.fromARGB(255, 236, 236, 236),
      body: Column(
        children: [
          Neumorphic(
            margin: const EdgeInsets.all(10),
            child: const TextField(
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: InputBorder.none,
                hintText: 'Search Wallpaper',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : MasonryGridView.count(
                    padding: const EdgeInsets.only(top: 10),
                    crossAxisCount: 2,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    itemBuilder: (context, index) {
                      return ImageCard(image: imageFiles[index]);
                    },
                    itemCount: images.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  final File image;
  const ImageCard({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: const NeumorphicStyle(
        depth: 5,
        color: creamWhite,
        shadowLightColor: Colors.white,
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SetWallpaperScreen(image: image),
              ),
            );
          },
          child: Hero(
            tag: image.path,
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class SetWallpaperScreen extends StatelessWidget {
  final File image;
  const SetWallpaperScreen({
    Key? key,
    required this.image,
  }) : super(key: key);

  void showSnackBar(BuildContext context, ContentType type) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: type == ContentType.success ? 'Success' : 'Error',
        message:
            type == ContentType.success ? 'Wallpaper set successfully' : 'Error setting wallpaper',
        contentType: type,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Hero(
                tag: image.path,
                child: Image.file(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async => setWallpaper(context, Location.home),
                  child: const Text('Wallpaper Screen'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Future.wait([
                      setWallpaper(context, Location.home),
                      setWallpaper(context, Location.lock),
                    ]);
                  },
                  child: const Text('Both'),
                ),
                ElevatedButton(
                  onPressed: () async => setWallpaper(context, Location.lock),
                  child: const Text('Lock Screen'),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> setWallpaper(BuildContext context, Location location) async {
    try {
      await AsyncWallpaper.setWallpaperFromFile(
        filePath: image.path,
        wallpaperLocation: location.value,
        goToHome: false,
      );
      // ignore: use_build_context_synchronously
      showSnackBar(context, ContentType.success);
    } catch (_) {
      showSnackBar(context, ContentType.failure);
    }
  }
}

enum Location {
  home(1),
  lock(2);

  final int value;
  const Location(this.value);
}
