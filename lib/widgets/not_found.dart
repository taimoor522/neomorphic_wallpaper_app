import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallpaper_app/extra/constants.dart';

import '../cubit/wallpaper_cubit.dart';

class NotFoundIllustration extends StatelessWidget {
  const NotFoundIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          height: 300,
          child: SvgPicture.asset(notFoundIllustration),
        ),
        ElevatedButton(
          onPressed: () => context.read<WallpaperCubit>().getWallpapers(),
          child: const Text('Retry'),
        )
      ],
    );
  }
}
