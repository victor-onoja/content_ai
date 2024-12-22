import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:content_ai/profile_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'profile_creation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(_firestore),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Coco AI',
        home: ProfileCreationScreen(),
      ),
    );
  }
}
