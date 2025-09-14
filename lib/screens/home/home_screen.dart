import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../config/app_config.dart';
import '../../utils/animation_utils.dart';
import '../../models/call.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import 'chats_list_screen.dart';
import 'updates_screen.dart';
import 'groups_screen.dart';
import 'calls_screen.dart';
import '../qr_scanner_screen.dart';
import '../call/call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    SafeArea(child: ChatsListScreen()),
    SafeArea(child: UpdatesScreen()),
    SafeArea(child: GroupsScreen()),
    SafeArea(child: CallsScreen()),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatsFetched());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(index, duration: AppConfig.shortAnimation, curve: Curves.easeInOut);
  }

  void _onPageChanged(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _screens.length,
        itemBuilder: (context, index) {
          try {
            return _screens[index];
          } catch (e) {
            // Fallback widget if screen creation fails
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Screen loading error',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: _buildFloatingActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildBottomBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      selectedItemColor: AppConfig.primaryColor,
          unselectedItemColor: isDark ? AppConfig.darkTextSecondary : Colors.grey.shade600,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
      items: [
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
                  Icon(_currentIndex == 0 ? Icons.chat_bubble : Icons.chat_bubble_outline),
              Positioned(
                right: -6,
                top: -4,
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    int unread = 0;
                    if (state is ChatsLoadSuccess) {
                      unread = state.chats.fold(0, (sum, c) => sum + c.unreadCount);
                    }
                    if (unread <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppConfig.primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
          label: 'Chats',
        ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 1 ? Icons.update : Icons.update_outlined),
              label: 'Updates',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 2 ? Icons.groups : Icons.groups_outlined),
              label: 'Communities',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 3 ? Icons.call : Icons.call_outlined),
              label: 'Calls',
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActions() {
    // Show FAB for different screens
    switch (_currentIndex) {
      case 0: // Chats
        return null; // Chats screen has its own FAB now
      case 1: // Updates/Status
        return null; // Status screen has its own FAB
      case 2: // Groups/Communities
        return null; // Groups screen has its own FAB
      case 3: // Calls
        return ScaleAnimation(
          beginScale: 0.8,
          endScale: 1.1,
          duration: AnimationDurations.quick,
          curve: AppAnimationCurves.microBounce,
          onTap: _showNewCallOptions,
          child: FloatingActionButton(
            onPressed: _showNewCallOptions,
            backgroundColor: AppConfig.primaryColor,
            elevation: 6,
            child: const Icon(Icons.add_call, color: Colors.white, size: 24),
          ),
        );
      default:
        return null;
    }
  }

  void _showNewChatOptions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_add,
                  color: AppConfig.primaryColor,
                ),
              ),
              title: const Text('New Contact'),
              subtitle: const Text('Add a new contact'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/new-contact');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.group_add,
                  color: AppConfig.primaryColor,
                ),
              ),
              title: const Text('New Group'),
              subtitle: const Text('Create a group chat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/create-group');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  color: AppConfig.primaryColor,
                ),
              ),
              title: const Text('Scan QR'),
              subtitle: const Text('Scan QR code to chat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QrScannerScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewCallOptions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.call,
                  color: AppConfig.primaryColor,
                ),
              ),
              title: const Text('New Call'),
              subtitle: const Text('Start a voice call'),
              onTap: () {
                Navigator.pop(context);
                _showContactSelectionDialog(CallType.voice);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.videocam,
                  color: AppConfig.primaryColor,
                ),
              ),
              title: const Text('New Video Call'),
              subtitle: const Text('Start a video call'),
              onTap: () {
                Navigator.pop(context);
                _showContactSelectionDialog(CallType.video);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactSelectionDialog(CallType callType) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                callType == CallType.voice ? 'Select Contact for Call' : 'Select Contact for Video Call',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: MockDataService.users.length,
                  itemBuilder: (context, index) {
                    final user = MockDataService.users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppConfig.primaryColor,
                        backgroundImage: user.profilePicture != null
                            ? NetworkImage(user.profilePicture!)
                            : null,
                        child: user.profilePicture == null
                            ? Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppConfig.darkText : AppConfig.lightText,
                        ),
                      ),
                      subtitle: Text(
                        user.phoneNumber,
                        style: TextStyle(
                          color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                        ),
                      ),
                      trailing: Icon(
                        callType == CallType.voice ? Icons.call : Icons.videocam,
                        color: AppConfig.primaryColor,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _startCall(user, callType);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startCall(User receiver, CallType callType) {
    final currentUser = MockDataService.currentUser;

    final call = Call(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      callerId: currentUser.id,
      receiverId: receiver.id,
      type: callType,
      status: CallStatus.initial,
      startTime: DateTime.now(),
      isIncoming: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          call: call,
          receiver: receiver,
          callType: callType,
          isIncoming: false,
        ),
      ),
    );
  }
}
