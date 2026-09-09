import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../models/call_model.dart';
import '../../services/calling_service.dart';
import '../contacts/contacts_screen.dart';
import '../history/call_history_screen.dart';
import '../profile/profile_screen.dart';
import '../call/incoming_call_screen.dart';
import 'home_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);
    final activeCall = callProvider.activeCall;

    // Check if an incoming call is active and ringing
    final bool showIncomingCallOverlay =
        activeCall != null && activeCall.state == CallState.ringing && activeCall.isIncoming;

    final pages = [
      HomeTab(onTabSwitch: _onTabTapped),
      const ContactsScreen(),
      const CallHistoryScreen(),
      const ProfileScreen(),
    ];

    final titles = [
      AppStrings.appName,
      AppStrings.contactsTitle,
      AppStrings.historyTitle,
      AppStrings.profileTitle,
    ];

    return Stack(
      children: [
        Scaffold(
          appBar: _currentIndex == 2 // CallHistoryScreen has its own AppBar
              ? null
              : AppBar(
                  title: Text(titles[_currentIndex]),
                  actions: [
                    if (_currentIndex == 0)
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No new notifications')),
                          );
                        },
                      ),
                  ],
                ),
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: AppStrings.navHome,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contacts_rounded),
                label: AppStrings.navContacts,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.call_rounded),
                label: AppStrings.navCalls,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: AppStrings.navProfile,
              ),
            ],
          ),
        ),

        // Incoming call full screen overlay
        if (showIncomingCallOverlay)
          const Positioned.fill(
            child: IncomingCallScreen(),
          ),
      ],
    );
  }
}
