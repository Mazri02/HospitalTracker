import 'package:flutter/material.dart';
import 'package:mobile_frontend/services/api_service.dart';
import 'package:mobile_frontend/widget/fieldbox.dart';
import 'package:gap/gap.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _isSaving = false;
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> _originalData = {};
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final userId = widget.userData['UserID'];
      print('Loading user data for ID: $userId'); // Debug print
      print('Full userData received: ${widget.userData}'); // Debug print

      if (userId == null) {
        // If UserID is null, try to fall back to the data we already have
        if (widget.userData['UserName'] != null ||
            widget.userData['UserEmail'] != null) {
          setState(() {
            _userData = Map<String, dynamic>.from(widget.userData);
            _originalData = Map<String, dynamic>.from(widget.userData);
            _nameController.text = _userData['UserName'] ?? '';
            _emailController.text = _userData['UserEmail'] ?? '';
            _isLoading = false;
          });
          return;
        }
        throw Exception('UserID is null and no fallback data available');
      }

      final response =
          await _apiService.getUserData(int.parse(userId.toString()));
      print('Response from getUserData: $response'); // Debug print

      if (response['status'] == 200) {
        setState(() {
          _userData = Map<String, dynamic>.from(response['data']);
          _originalData = Map<String, dynamic>.from(response['data']);
          _nameController.text = _userData['UserName'] ?? '';
          _emailController.text = _userData['UserEmail'] ?? '';
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar(response['error'] ?? 'Failed to load user data');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error in _loadUserData: $e'); // Debug print
      _showErrorSnackBar('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // If no UserID, just update local data without API call
      if (_userData['UserID'] == null) {
        setState(() {
          _userData['UserName'] = _nameController.text.trim();
          _userData['UserEmail'] = _emailController.text.trim();
          _originalData = Map<String, dynamic>.from(_userData);
          _isEditing = false;
          _isSaving = false;
        });

        _showSuccessSnackBar('Profile updated locally!');

        // Small delay to show the snackbar before navigating back
        await Future.delayed(Duration(milliseconds: 1500));

        // Pass updated data back to previous screen
        Navigator.pop(context, {
          'UserName': _nameController.text.trim(),
          'UserEmail': _emailController.text.trim(),
        });
        return;
      }

      final response = await _apiService.editUser(
        userId: int.parse(_userData['UserID'].toString()),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (response['status'] == 200) {
        setState(() {
          _userData['UserName'] = _nameController.text.trim();
          _userData['UserEmail'] = _emailController.text.trim();
          _originalData = Map<String, dynamic>.from(_userData);
          _isEditing = false;
          _isSaving = false;
        });

        _showSuccessSnackBar('Profile updated successfully!');

        // Small delay to show the snackbar before navigating back
        await Future.delayed(Duration(milliseconds: 1500));

        // Pass updated data back to previous screen
        Navigator.pop(context, {
          'UserName': _nameController.text.trim(),
          'UserEmail': _emailController.text.trim(),
        });
      } else {
        _showErrorSnackBar(response['error'] ?? 'Failed to update profile');
        setState(() => _isSaving = false);
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
      setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final response = await _apiService.editUser(
        userId: int.parse(_userData['UserID'].toString()),
        name: _userData['UserName'],
        email: _userData['UserEmail'],
        password: _newPasswordController.text,
      );

      if (response['status'] == 200) {
        setState(() {
          _isChangingPassword = false;
          _isSaving = false;
        });

        _clearPasswordFields();
        _showSuccessSnackBar('Password changed successfully!');
      } else {
        _showErrorSnackBar(response['error'] ?? 'Failed to change password');
        setState(() => _isSaving = false);
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isSaving = true);

    try {
      final response = await _apiService.deleteUser(
        int.parse(_userData['UserID'].toString()),
      );

      if (response['status'] == 200) {
        _showSuccessSnackBar('Account deleted successfully');

        // Small delay to show the snackbar before navigating
        await Future.delayed(Duration(milliseconds: 2000));

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        _showErrorSnackBar(response['error'] ?? 'Failed to delete account');
        setState(() => _isSaving = false);
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
      setState(() => _isSaving = false);
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _isChangingPassword = false;
      _nameController.text = _originalData['UserName'] ?? '';
      _emailController.text = _originalData['UserEmail'] ?? '';
      _clearPasswordFields();
    });
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure you want to delete your account?'),
                Gap(8),
                Text(
                  'This action cannot be undone. All your data will be permanently removed.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete Account',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 150, 53, 220),
            const Color.fromARGB(255, 120, 43, 190),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: const Color.fromARGB(255, 150, 53, 220),
            ),
          ),
          Gap(10),
          Text(
            _userData['UserName'] ?? 'Loading...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _userData['UserEmail'] ?? '',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    if (_isChangingPassword) {
      return _buildPasswordChangeForm();
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          if (_isEditing) ...[
            // Edit Mode
            Text(
              'Edit Profile Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 150, 53, 220),
              ),
            ),
            Gap(20),
            FieldBox(
              label: 'Full Name',
              controller: _nameController,
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            Gap(20),
            FieldBox(
              label: 'Email Address',
              controller: _emailController,
              prefixIcon: Icons.email,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            Gap(30),
            // Action buttons for edit mode
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _cancelEditing,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                Gap(12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfileChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 150, 53, 220),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Save Changes',
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ] else ...[
            // View Mode
            Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 150, 53, 220),
              ),
            ),
            Gap(20),
            ProfileDetailCard(
              icon: Icons.person,
              title: 'Full Name',
              value: _userData['UserName'] ?? 'Not available',
            ),
            Gap(12),
            ProfileDetailCard(
              icon: Icons.email,
              title: 'Email Address',
              value: _userData['UserEmail'] ?? 'Not available',
            ),
            Gap(12),
            ProfileDetailCard(
              icon: Icons.badge,
              title: 'User ID',
              value: _userData['UserID']?.toString() ?? 'Not available',
            ),
            Gap(30),
            // Action buttons for view mode
            ElevatedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: Icon(Icons.edit, color: Colors.white),
              label:
                  Text('Edit Profile', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 150, 53, 220),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            Gap(12),
            OutlinedButton.icon(
              onPressed: _userData['UserID'] != null
                  ? () => setState(() => _isChangingPassword = true)
                  : null,
              icon: Icon(Icons.lock,
                  color: _userData['UserID'] != null
                      ? const Color.fromARGB(255, 150, 53, 220)
                      : Colors.grey),
              label: Text(
                _userData['UserID'] != null
                    ? 'Change Password'
                    : 'Change Password (Unavailable)',
                style: TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: _userData['UserID'] != null
                        ? const Color.fromARGB(255, 150, 53, 220)
                        : Colors.grey),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            Gap(12),
            OutlinedButton.icon(
              onPressed: _userData['UserID'] != null ? _deleteAccount : null,
              icon: Icon(Icons.delete_forever,
                  color:
                      _userData['UserID'] != null ? Colors.red : Colors.grey),
              label: Text(
                _userData['UserID'] != null
                    ? 'Delete Account'
                    : 'Delete Account (Unavailable)',
                style: TextStyle(
                  color: _userData['UserID'] != null ? Colors.red : Colors.grey,
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color:
                        _userData['UserID'] != null ? Colors.red : Colors.grey),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordChangeForm() {
    return Form(
      key: _passwordFormKey,
      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text(
            'Change Password',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 150, 53, 220),
            ),
          ),
          Gap(20),
          FieldBox(
            label: 'Current Password',
            controller: _currentPasswordController,
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your current password';
              }
              return null;
            },
          ),
          Gap(20),
          FieldBox(
            label: 'New Password',
            controller: _newPasswordController,
            prefixIcon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          Gap(20),
          FieldBox(
            label: 'Confirm New Password',
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_clock,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your new password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          Gap(30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text('Cancel'),
                ),
              ),
              Gap(12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 150, 53, 220),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Change Password',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 244, 236),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 150, 53, 220),
        elevation: 0,
        title: Text(
          'Profile Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isEditing || _isChangingPassword) {
              _cancelEditing();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: const Color.fromARGB(255, 150, 53, 220),
                  ),
                  Gap(16),
                  Text('Loading profile...'),
                ],
              ),
            )
          : Column(
              children: [
                // Header Section
                _buildProfileHeader(),
                // Details Section
                Expanded(
                  child: _buildProfileDetails(),
                ),
              ],
            ),
    );
  }
}

// Enhanced widget for each profile detail row
class ProfileDetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileDetailCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 150, 53, 220).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color.fromARGB(255, 150, 53, 220),
            ),
          ),
          Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gap(4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for the old profile detail row (keeping for backward compatibility)
class ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileDetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.deepPurple),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
