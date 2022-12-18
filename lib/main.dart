import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallpaper_app/constants.dart';
import 'package:wallpaper_app/cubit/wallpaper_cubit.dart';
import 'package:wallpaper_app/utils.dart';
import 'package:wallpaper_app/wallpaper_model.dart';

import 'loaction_enum.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WallpaperCubit()..getWallpapers('abstract+art'),
      child: MaterialApp(
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
      ),
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
  final TextEditingController _controller = TextEditingController();
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
          const Text('Wallpaper App', style: TextStyle(fontSize: 40, fontFamily: handlee)),
          Neumorphic(
            margin: const EdgeInsets.all(10),
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: InputBorder.none,
                hintText: 'Search Wallpaper',
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: ElevatedButton(
                  child: const Icon(Icons.search),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.read<WallpaperCubit>().getWallpapers(_controller.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                context.read<WallpaperCubit>().getWallpapers(value);
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<WallpaperCubit, WallpaperState>(
              listener: (context, state) {
                if (state is WallpaperAppliedFailed) {
                  Utils.showSnackBar(context, ContentType.failure);
                } else if (state is WallpaperAppliedFailed) {
                  Utils.showSnackBar(context, ContentType.success);
                }
              },
              builder: (context, state) {
                if (state is WallpaperLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is WallpaperError) {
                  return const Center(child: Text('Error loading images'));
                }
                List<WallpaperModel> wallpapers = [];
                if (state is WallpaperLoaded) {
                  wallpapers = state.wallpapers;
                } else {
                  wallpapers = context.read<WallpaperCubit>().wallpapers;
                }

                return MasonryGridView.count(
                  padding: const EdgeInsets.only(top: 10),
                  physics: const BouncingScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  itemBuilder: (context, index) {
                    return ImageCard(wallpaper: wallpapers[index]);
                  },
                  itemCount: wallpapers.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  const ImageCard({
    Key? key,
    required this.wallpaper,
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
                builder: (context) => SetWallpaperScreen(wallpaper: wallpaper),
              ),
            );
          },
          child: Image.network(
            wallpaper.thumbnail,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class SetWallpaperScreen extends StatefulWidget {
  final WallpaperModel wallpaper;
  const SetWallpaperScreen({
    Key? key,
    required this.wallpaper,
  }) : super(key: key);

  @override
  State<SetWallpaperScreen> createState() => _SetWallpaperScreenState();
}

class _SetWallpaperScreenState extends State<SetWallpaperScreen>
    with AutomaticKeepAliveClientMixin {
  File? wallpaperFile;

  @override
  void initState() {
    super.initState();
    context.read<WallpaperCubit>().downloadWallpaper(widget.wallpaper.original).then((value) {
      setState(() {
        wallpaperFile = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            wallpaperFile == null
                ? const LoadingIndicator()
                : Image.file(
                    wallpaperFile!,
                    fit: BoxFit.cover,
                  ),
            if (wallpaperFile != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await context
                              .read<WallpaperCubit>()
                              .setWallpaper(wallpaperFile!.path, WallpaperLocation.home);
                        },
                        child: const Text('Home Screen'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await context
                              .read<WallpaperCubit>()
                              .setWallpaper(wallpaperFile!.path, WallpaperLocation.both);
                        },
                        child: const Text('Both'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await context
                              .read<WallpaperCubit>()
                              .setWallpaper(wallpaperFile!.path, WallpaperLocation.lock);
                        },
                        child: const Text('Lock Screen'),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 50,
              left: 0,
              child: BlocListener<WallpaperCubit, WallpaperState>(
                listener: (context, state) {
                  if (state is WallpaperAppliedSuccess) {
                    Utils.showSnackBar(context, ContentType.success);
                  } else if (state is WallpaperAppliedFailed) {
                    Utils.showSnackBar(context, ContentType.failure);
                  }
                },
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
