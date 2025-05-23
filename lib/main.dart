import 'package:cineverse/Providers/detail_movies_provider.dart';
import 'package:cineverse/Providers/genre_provider.dart';
import 'package:cineverse/Providers/movies_provider.dart';
import 'package:cineverse/Providers/search_movies_provider.dart';
import 'package:cineverse/Providers/upcoming_movies_provider.dart';
import 'package:cineverse/Services/movies_api_service.dart';
import 'package:cineverse/Services/search_movie_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Google Fonts
  GoogleFonts.poppins();

  // Get API key from .env
  final movieApiService = MovieApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Provide the MovieApiService instance
        Provider<MovieApiService>.value(value: movieApiService),
        ChangeNotifierProvider(
          create: (_) => MovieProvider(apiService: movieApiService),
        ),
        // Provide the DetailMoviesProvider with the same MovieApiService instance
        ChangeNotifierProvider(
          create: (_) => DetailMoviesProvider(movieService: movieApiService),
        ),
        //SearchMoviesProvider
        Provider<SearchMovieApiService>.value(value: SearchMovieApiService()),
        ChangeNotifierProvider(
          create: (_) =>
              SearchMoviesProvider(movieService: SearchMovieApiService()),
        ),
        // GenreProvider
        ChangeNotifierProvider(create: (_) => GenreProvider()),
        // upcoming movies provider
        ChangeNotifierProvider(create: (_) => UpcomingMoviesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Cineverse',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}
