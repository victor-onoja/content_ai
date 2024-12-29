import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:content_ai/auth/auth_repo.dart';
import 'package:content_ai/home/calendar_bloc.dart';
import 'package:content_ai/profile/profile_bloc.dart';
import 'package:content_ai/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'auth/auth_bloc.dart';
import 'config.dart'; // Import the config file
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GenerativeModel _generativeModel = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: Config.generativeModelApiKey); // Use the API key from config

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => FirebaseAuthRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ProfileBloc(_firestore),
          ),
          BlocProvider(
              create: (context) => CalendarBloc(
                  _firestore, _generativeModel, context.read<ProfileBloc>())),
          BlocProvider(
            create: (context) => AuthBloc(
                authRepository: context.read<FirebaseAuthRepository>()),
          ),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Coco AI',
          home: SplashScreen(),
        ),
      ),
    );
  }
}
