import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'providers/theme_provider.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/chat/chat_bloc.dart';
import 'blocs/chat/message_bloc.dart';
import 'blocs/call/call_bloc.dart';
import 'blocs/profile/profile_bloc.dart';
import 'blocs/status/status_bloc.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/call/call_screen.dart';

import 'screens/contact/contact_detail_screen.dart';
import 'screens/chat/group_info_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/group/create_group_screen.dart';
import 'models/group.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/contact/new_contact_screen.dart';
import 'screens/broadcast/new_broadcast_screen.dart';
import 'screens/devices/linked_devices_screen.dart';
import 'screens/home/select_contact_screen.dart';
import 'models/chat.dart';
import 'models/user.dart';
import 'models/call.dart';
import 'services/mock_data_service.dart';
import 'repositories/status_repository.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const ChatWaveApp(),
    ),
  );
}

class ChatWaveApp extends StatelessWidget {
  const ChatWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Blocs
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(),
        ),
        BlocProvider<MessageBloc>(
          create: (context) => MessageBloc(),
        ),
        BlocProvider<CallBloc>(
          create: (context) => CallBloc(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
        ),
        BlocProvider<StatusBloc>(
          create: (context) => StatusBloc(
            statusRepository: StatusRepository(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConfig.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const OnboardingScreen(), // Start with onboarding
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const HomeScreen(),
          '/chat': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments;
            if (arguments is Chat) {
              return ChatScreen(chat: arguments);
            } else {
              // Fallback: navigate back if no valid chat is provided
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
              });
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
          '/call': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments;
            if (arguments is Map<String, dynamic>) {
              try {
                final chat = arguments['chat'] as Chat;
                final isVideo = arguments['isVideo'] as bool;
                final isIncoming = arguments['isIncoming'] as bool;
                
                // Create a Call object from the chat data
                final currentUser = MockDataService.currentUser;
                final receiver = chat.participants.firstWhere((user) => user.id != currentUser.id);
                
                final call = Call(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  callerId: currentUser.id,
                  receiverId: receiver.id,
                  type: isVideo ? CallType.video : CallType.voice,
                  status: CallStatus.initial,
                  startTime: DateTime.now(),
                  isIncoming: isIncoming,
                );
                
                return CallScreen(
                  call: call,
                  receiver: receiver,
                  isIncoming: isIncoming,
                  callType: isVideo ? CallType.video : CallType.voice,
                );
              } catch (e) {
                // Fallback if arguments are malformed
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pop();
                });
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            } else {
              // Fallback: navigate back if no valid arguments
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
              });
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
          '/profile': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments;
            if (arguments is User) {
              return ContactDetailScreen(contact: arguments);
            } else {
              // Fallback: navigate back if no valid user is provided
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
              });
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },

          '/settings': (context) => const SettingsScreen(),
          '/create-group': (context) => const CreateGroupScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/group-info': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments;
            if (arguments is Group) {
              return GroupInfoScreen(group: arguments);
            } else {
              // Fallback: navigate back if no valid group is provided
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
              });
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
          '/select-contact': (context) => const SelectContactScreen(),
          '/new-contact': (context) => const NewContactScreen(),
          '/new-broadcast': (context) => const NewBroadcastScreen(),
          '/linked-devices': (context) => const LinkedDevicesScreen(),
        },
          );
        },
      ),
    );
  }
}
