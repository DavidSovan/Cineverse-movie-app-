import 'package:cineverse/providers/detail_movies_provider.dart';
import 'package:cineverse/providers/genre_provider.dart';
import 'package:cineverse/providers/movie_credits_provider.dart';
import 'package:cineverse/providers/movies_provider.dart';
import 'package:cineverse/providers/search_multi_provider.dart';
import 'package:cineverse/providers/similar_movie_provider.dart';
import 'package:cineverse/providers/tv_show_detail_provider.dart';
import 'package:cineverse/providers/tv_show_provider.dart';
import 'package:cineverse/providers/upcoming_movies_provider.dart';
import 'package:cineverse/providers/videos_movies_provider.dart';
import 'package:cineverse/providers/watchlist_provider.dart';
import 'package:cineverse/services/movies_api_service.dart';
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
        // GenreProvider
        ChangeNotifierProvider(create: (_) => GenreProvider()),
        // upcoming movies provider
        ChangeNotifierProvider(create: (_) => UpcomingMoviesProvider()),
        // VideosMoviesProvider
        ChangeNotifierProvider(
          create: (_) => MovieVideosProvider(),
        ),
        // MovieCreditsProvider
        ChangeNotifierProvider(create: (_) => MovieCreditsProvider()),
        //SimilarMoviesProvider
        ChangeNotifierProvider(create: (_) => SimilarMoviesProvider()),
        //tv show provider
        ChangeNotifierProvider(create: (context) => TvShowProvider()),
        //tv show detail provider
        ChangeNotifierProvider(create: (_) => TvShowDetailProvider()),
        //SearchMultiProvider
        ChangeNotifierProvider(create: (_) => SearchMultiProvider()),
        //WatchlistProvider
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
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
