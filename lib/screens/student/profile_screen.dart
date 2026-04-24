import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../config/admin_access.dart';
import '../login_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkNavy = Color(0xFF1a1a2e);
  static const Color lightGray = Color(0xFFF1F5FF);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color borderGray = Color(0xFFe5e7eb);
  static const Color redError = Color(0xFFef4444);
  static const Color greenSuccess = Color(0xFF22c55e);

  // Live data
  String _name = '';
  String _email = '';
  String _memberSince = '';
  int _totalRegistered = 0;
  int _upcomingCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final user = AuthService().currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Format member-since from createdAt
    String memberSince = '';
    if (user.createdAt != null) {
      final dt = user.createdAt!;
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      memberSince = '${months[dt.month - 1]} ${dt.year}';
    }

    // Fetch registrations for stats
    List<Map<String, dynamic>> registrations = [];
    try {
      registrations = await EventService.getUserRegistrations(user.id);
    } catch (_) {}

    final upcoming = registrations.where((r) {
      final event = r['events'] as Map<String, dynamic>?;
      return event?['status']?.toString().toLowerCase() == 'upcoming';
    }).length;

    if (mounted) {
      setState(() {
        _name = user.name ?? user.email.split('@').first;
        _email = user.email;
        _memberSince = memberSince;
        _totalRegistered = registrations.length;
        _upcomingCount = upcoming;
        _isLoading = false;
      });
    }
  }

  String get _avatarLetter =>
      _name.isNotEmpty ? _name[0].toUpperCase() : '?';

  Future<void> _handleSignOut() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    }
  }

  void _showEditProfile() {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: gray400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: darkNavy,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(ctx),
                                  color: gray400,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Name field
                            const Text(
                              'Display Name',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: gray600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: nameCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'Enter your name',
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: primaryBlue,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: borderGray),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: borderGray),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: primaryBlue,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFFAFAFA),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Name cannot be empty'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            // Email field
                            const Text(
                              'Email Address',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: gray600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: primaryBlue,
                                  size: 20,
                                ),
                                helperText:
                                    'A confirmation link will be sent to the new address',
                                helperStyle:
                                    const TextStyle(fontSize: 11, color: gray400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: borderGray),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: borderGray),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: primaryBlue,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFFAFAFA),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email cannot be empty';
                                }
                                if (!v.contains('@')) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            // Save button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!.validate()) {
                                          return;
                                        }
                                        setSheetState(() => isSaving = true);
                                        final newName = nameCtrl.text.trim();
                                        final newEmail = emailCtrl.text.trim();
                                        final auth = AuthService();
                                        String? error;
                                        bool emailChanged = newEmail != _email;

                                        try {
                                          if (newName != _name) {
                                            await auth.updateDisplayName(newName);
                                          }
                                          if (emailChanged) {
                                            await auth.updateEmail(newEmail);
                                          }
                                        } catch (e) {
                                          error = e.toString();
                                        }

                                        setSheetState(() => isSaving = false);

                                        if (!mounted) return;
                                        Navigator.pop(ctx);

                                        if (error != null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(error),
                                            backgroundColor: Colors.red,
                                          ));
                                        } else {
                                          // Update local state immediately for name
                                          setState(() => _name = newName);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(emailChanged
                                                ? 'Name updated. Check your new email inbox to confirm the email change.'
                                                : 'Profile updated successfully!'),
                                            backgroundColor: greenSuccess,
                                            duration: const Duration(seconds: 4),
                                          ));
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: primaryBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopSection(),
              _buildAccountDetailsSection(),
              _buildStatsSection(),
              _buildSignOutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      color: darkNavy,
      child: Column(
        children: [
          // Avatar with edit overlay
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _avatarLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showEditProfile,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: darkNavy,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _email,
            style: const TextStyle(
              color: Color.fromARGB(179, 255, 255, 255),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.white.withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Student',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _showEditProfile,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 13, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: darkNavy,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.person_outline, 'Name', _name),
          const SizedBox(height: 16),
          _infoRow(Icons.email_outlined, 'Email', _email),
          const SizedBox(height: 16),
          _infoRow(Icons.school_outlined, 'Role', 'Student'),
          if (_memberSince.isNotEmpty) ...[
            const SizedBox(height: 16),
            _infoRow(Icons.calendar_today_outlined, 'Member since',
                _memberSince),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(icon, color: primaryBlue, size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: gray400,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      color: darkNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _statCard('$_totalRegistered', 'Events Registered'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard('$_upcomingCount', 'Upcoming Events'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(number,
              style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: gray400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Admin Panel Button (only for admin user)
          if (AdminAccess.isAdminEmail(_email))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const AdminDashboardScreen(),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings, size: 20),
                  label: const Text(
                    'Admin Dashboard',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a1a2e),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          // Sign Out Button
          OutlinedButton(
            onPressed: _handleSignOut,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: redError, width: 1.5),
              minimumSize: const Size(double.infinity, 48),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Out',
                style: TextStyle(
                    color: redError,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
