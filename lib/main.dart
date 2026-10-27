import 'dart:io' show Platform;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/openkey_app.dart';
import 'package:openkey_app/src/src.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  final authBloc = sl<AuthBloc>()..add(const AuthStarted());

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
        BlocProvider<CollectionBloc>.value(value: sl<CollectionBloc>()),
        BlocProvider<EntryBloc>.value(value: sl<EntryBloc>()),
        BlocProvider<WalletBloc>.value(value: sl<WalletBloc>()),
        BlocProvider<CryptoBloc>.value(value: sl<CryptoBloc>()),
        BlocProvider<SecretsBloc>.value(value: sl<SecretsBloc>()),
        BlocProvider<VaultSelectionCubit>(create: (_) => VaultSelectionCubit()),
      ],
      child: const OpenKeyApp(),
    ),
  );

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      final win = appWindow;
      win.minSize = const Size(400, 500);
      win.size = const Size(1000, 700);
      win.alignment = Alignment.center;
      win.title = 'OpenKey';
      win.show();
    });
  }
}
