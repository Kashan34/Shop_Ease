import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/cart_service.dart';
import 'services/admin_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: '   ',
      anonKey: '      ',
    );
    print('Supabase initialized successfully');
    // Initialize Firebase
    print('Starting Firebase initialization...');
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "blah blah",
        appId: "    ",
        messagingSenderId: "     ",
        projectId: "     ",
      ),
    );
    print('Firebase initialized successfully');

    // Initialize storage bucket
    final storageService = StorageService();
    await storageService.initializeBucket();

    // Initialize sample products
    final productService = ProductService();
    try {
      print('Starting product initialization...');
      await productService.initializeSampleProducts();
      print('Products initialized successfully');
    } catch (e) {
      print('Error initializing products: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  } catch (e) {
    print('Error during initialization: $e');
    print('Stack trace: ${StackTrace.current}');
  }

  print('Starting app...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<ProductService>(
          create: (_) => ProductService(),
        ),
        ProxyProvider<AuthService, CartService>(
          update: (_, auth, __) =>
              CartService(userId: auth.currentUser?.uid ?? ''),
          child: const SizedBox(),
        ),
        ProxyProvider<AuthService, AdminService>(
          update: (_, auth, __) =>
              AdminService(userId: auth.currentUser?.uid ?? ''),
          child: const SizedBox(),
        ),
      ],
      child: MaterialApp(
        title: 'ShopEase',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<AuthService>().auth.authStateChanges(),
      builder: (context, snapshot) {
        print('Auth State: ${snapshot.connectionState}');
        print('Has Data: ${snapshot.hasData}');
        print('Has Error: ${snapshot.hasError}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 20),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Firebase.initializeApp();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          print('User: ${snapshot.data?.email ?? 'No user'}');
          return const HomeScreen();
        }

        print('Showing Login Screen');
        return const LoginScreen();
      },
    );
  }
}
