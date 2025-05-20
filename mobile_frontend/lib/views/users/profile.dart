import 'package:flutter/material.dart';
import 'package:mobile_frontend/services/api_service.dart';
import 'package:mobile_frontend/widget/fieldbox.dart';

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
  Map<String, dynamic> _userData = {};
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = widget.userData['UserID'];
      print('Loading user data for ID: $userId'); // Debug print
      
      if (userId == null) {
        throw Exception('UserID is null');
      }

      final response = await _apiService.getUserData(int.parse(userId.toString()));
      print('Response from getUserData: $response'); // Debug print

      if (response['status'] == 200) {
        setState(() {
          _userData = response['data'];
          _nameController.text = _userData['UserName'] ?? '';
          _emailController.text = _userData['UserEmail'] ?? '';
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Failed to load user data')),
        );
      }
    } catch (e) {
      print('Error in _loadUserData: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await _apiService.editUser(
        userId: int.parse(_userData['UserID'].toString()),
        name: _nameController.text,
        email: _emailController.text,
      );

      if (response['status'] == 200) {
        setState(() {
          _userData['UserName'] = _nameController.text;
          _userData['UserEmail'] = _emailController.text;
          _isEditing = false;
        });
        
        // Pass updated data back to previous screen
        Navigator.pop(context, {
          'UserName': _nameController.text,
          'UserEmail': _emailController.text,
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Failed to update profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildProfileDetails() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          if (_isEditing) ...[
            // Edit Mode
            FieldBox(
              label: 'Name',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            FieldBox(
              label: 'Email',
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
          ] else ...[
            // View Mode
            ProfileDetailRow(
              icon: Icons.person,
              title: 'Name',
              value: _userData['UserName'] ?? '',
            ),
            ProfileDetailRow(
              icon: Icons.email,
              title: 'Email',
              value: _userData['UserEmail'] ?? '',
            ),
          ],
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
          'Profile Data',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Section
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 150, 53, 220),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
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
                      SizedBox(height: 10),
                      Text(
                        _userData['UserName'] ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Details Section
                Expanded(
                  child: _buildProfileDetails(),
                ),
                // Edit/Save Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      if (_isEditing) {
                        _saveChanges();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                    child: Center(
                      child: Text(
                        _isEditing ? 'Save Changes' : 'Edit Profile',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// Widget for each profile detail row
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
