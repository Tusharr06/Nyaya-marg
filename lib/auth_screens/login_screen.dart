import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nyaya_marg/auth_screens/auth_router.dart';
import 'package:nyaya_marg/auth_screens/service/auth_method.dart';
import 'package:nyaya_marg/auth_screens/singup_screen.dart';
import 'package:nyaya_marg/theme/colors.dart'; 

// Notifier used to enable/disable chat across screens; default to true.
ValueNotifier<bool> chatEnabledNotifier = ValueNotifier<bool>(true);

class LoginScreen extends StatefulWidget {
  final String? selectedRole;
  const LoginScreen({super.key, this.selectedRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isGoogleLoading = false; // Track Google Sign-In loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatEnabledNotifier.value = false;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          // Validate role after successful authentication
          final isValidRole = await _validateUserRole();
          if (isValidRole && mounted) {
            final home = await getHomeAfterAuth();
            if (!mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => home));
          } else {
            // Check if user exists but doesn't have a role yet
            final user = FirebaseAuth.instance.currentUser;
            if (user != null && widget.selectedRole != null) {
              final doc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();
              
              if (!doc.exists || doc.data()?['role'] == null) {
                // User exists but no role - save the selected role
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .set({
                  'uid': user.uid,
                  'email': user.email,
                  'name': user.displayName ?? '',
                  'role': widget.selectedRole,
                  'createdAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
                
                // Now proceed to home screen
                final home = await getHomeAfterAuth();
                if (!mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => home));
                return;
              }
            }
            
            // Sign out user if role doesn't match
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No account found with ${widget.selectedRole} role'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'No user found with that email.';
            break;
          case 'wrong-password':
            message = 'Incorrect password.';
            break;
          case 'invalid-email':
            message = 'Invalid email format.';
            break;
          default:
            message = 'Error: ${e.message}';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final userCredential = await GoogleSignInService.signInWithGoogle(role: widget.selectedRole);
      if (userCredential != null && mounted) {
        // Validate role after successful authentication
        final isValidRole = await _validateUserRole();
        if (isValidRole && mounted) {
          final home = await getHomeAfterAuth();
          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => home));
        } else {
          // Check if user exists but doesn't have a role yet
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && widget.selectedRole != null) {
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
            
            if (!doc.exists || doc.data()?['role'] == null) {
              // User exists but no role - save the selected role
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .set({
                'uid': user.uid,
                'email': user.email,
                'name': user.displayName ?? '',
                'role': widget.selectedRole,
                'createdAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
              
              // Now proceed to home screen
              final home = await getHomeAfterAuth();
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => home));
              return;
            }
          }
          
          // Sign out user if role doesn't match
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No account found with ${widget.selectedRole} role'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<bool> _validateUserRole() async {
    if (widget.selectedRole == null) return true; // No role selected, allow login
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final userRole = doc.data()?['role'] as String?;
      return userRole == widget.selectedRole;
    } catch (e) {
      return false;
    }
  }

@override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatEnabledNotifier.value = true;
    });
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: SizedBox(
        height: screenHeight,
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.poppins(
                                  color: AppColors.deepBlue,
                                  fontSize: screenWidth * 0.04,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 2,
                                  decorationColor: AppColors.deepBlue,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignupScreen(selectedRole: widget.selectedRole)),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.poppins(
                                  color: AppColors.deepBlue,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Center(
                        child: Image.asset(
                          'assets/logo.png',
                          width: 160,
                          height: 160,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Welcome!',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Sign in to continue',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.04,
                          color: AppColors.deepBlue,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            _buildTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              icon: Icons.lock,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.goldenAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.075),
                            _isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.deepBlue),
                                  )
                                : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.deepBlue,
                                      minimumSize: Size(double.infinity, screenHeight * 0.07),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      'Sign In',
                                      style: GoogleFonts.poppins(
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Center(
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignupScreen(selectedRole: widget.selectedRole)),
                                );
                              },
                              child: Text(
                                "Don't have an account? Sign Up",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  color: AppColors.deepBlue,
                                ),
                              ),
                            ),
                            Text(
                              'or',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                color: AppColors.deepBlue,
                              ),
                            ),
                            TextButton(
                              onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/google_logo.png', // Google logo asset
                                    height: screenWidth * 0.06,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  _isGoogleLoading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.deepBlue),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Continue with Google',
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth * 0.04,
                                            color: AppColors.deepBlue,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.goldenAccent),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: screenWidth * 0.04,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }
}