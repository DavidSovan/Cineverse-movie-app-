import 'package:cineverse/core/screens/home_screen.dart';
import 'package:cineverse/core/screens/splash_screen.dart';
import 'package:cineverse/core/theme/theme_provider.dart';
import 'package:cineverse/features/drawer/genre_provider.dart';
import 'package:cineverse/features/drawer/watchlist_provider.dart';
import 'package:cineverse/features/movies/providers/detail_movies_provider.dart';
import 'package:cineverse/features/movies/providers/movie_credits_provider.dart';
import 'package:cineverse/features/movies/providers/movies_provider.dart';
import 'package:cineverse/features/movies/providers/similar_movie_provider.dart';
import 'package:cineverse/features/movies/providers/upcoming_movies_provider.dart';
import 'package:cineverse/features/movies/providers/videos_movies_provider.dart';
import 'package:cineverse/features/movies/services/movies_api_service.dart';
import 'package:cineverse/features/search/providers/search_multi_provider.dart';
import 'package:cineverse/features/tv_shows/providers/tv_show_detail_provider.dart';
import 'package:cineverse/features/tv_shows/providers/tv_show_provider.dart';
import 'package:cineverse/shared/providers/connectivity_provider.dart';
import 'package:cineverse/shared/widgets/connectivity_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cineverse/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          // Theme provider should be first
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          // Connectivity provider should be near the top
          ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
          // Provide the MovieApiService instance
          Provider<MovieApiService>.value(value: MovieApiService()),
          ChangeNotifierProvider(
            create: (_) => MovieProvider(apiService: MovieApiService()),
          ),
          // Provide the DetailMoviesProvider with the same MovieApiService instance
          ChangeNotifierProvider(
            create: (_) =>
                DetailMoviesProvider(movieService: MovieApiService()),
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
  });
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
          home: const ConnectivityGuard(
            child: SplashScreen(),
          ),
          routes: {
            '/home': (context) => const ConnectivityGuard(
                  child: HomeScreen(),
                ),
          },
        );
      },
    );
  }
}
