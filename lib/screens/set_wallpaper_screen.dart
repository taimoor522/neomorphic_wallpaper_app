import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/wallpaper_cubit.dart';
import '../extra/constants.dart';
import '../extra/location_enum.dart';
import '../extra/snackbar.dart';
import '../extra/wallpaper_model.dart';
import '../widgets/loading_indicator.dart';

class SetWallpaperScreen extends StatefulWidget {
  final WallpaperModel wallpaper;
  const SetWallpaperScreen({Key? key, required this.wallpaper}) : super(key: key);

  @override
  State<SetWallpaperScreen> createState() => _SetWallpaperScreenState();
}

class _SetWallpaperScreenState extends State<SetWallpaperScreen> {
  File? wallpaperFile;

  @override
  void initState() {
    super.initState();
    context.read<WallpaperCubit>().downloadWallpaper(widget.wallpaper.original).then(
          (value) => setState(() => wallpaperFile = value),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocListener<WallpaperCubit, WallpaperState>(
          listener: (context, state) {
            if (state is WallpaperAppliedSuccess) {
              Snackbar.show(context, 'Wallpaper applied successfully', ContentType.success);
            } else if (state is WallpaperAppliedFailed) {
              Snackbar.show(context, 'Failed to apply wallpaper', ContentType.failure );
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              wallpaperFile == null
                  ? const LoadingIndicator()
                  : Image.file(wallpaperFile!, fit: BoxFit.cover),
              if (wallpaperFile != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: white,
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
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: white,
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: black,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
