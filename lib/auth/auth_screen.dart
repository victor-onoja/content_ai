import 'package:content_ai/profile/profile_creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_bloc.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication failed'),
                backgroundColor: Colors.orange,
              ),
            );
            print(state.errorMessage);
          } else if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfileCreationScreen()),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state.status == AuthStatus.loading;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Stack(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo
                    Image.asset(
                      'assets/images/coco.png',
                      height: 150,
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Welcome to Coco AI',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your intelligent content creation assistant',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 48),

                    // Sign In Buttons
                    _buildSignInButton(
                      context,
                      onPressed: isLoading
                          ? null
                          : () => context
                              .read<AuthBloc>()
                              .add(AuthSignInWithGoogle()),
                      icon: 'assets/icons/google_logo.png',
                      label: 'Continue with Google',
                    ),
                    const SizedBox(height: 16),
                    _buildSignInButton(
                      context,
                      onPressed: isLoading
                          ? null
                          : () => context
                              .read<AuthBloc>()
                              .add(AuthSignInWithApple()),
                      icon: 'assets/icons/apple_logo.jpeg',
                      label: 'Continue with Apple',
                    ),
                    const SizedBox(height: 16),
                    _buildSignInButton(
                      context,
                      onPressed: isLoading
                          ? null
                          : () =>
                              context.read<AuthBloc>().add(AuthSignInAsGuest()),
                      icon: 'assets/icons/guest_icon.png',
                      label: 'Continue as Guest',
                    ),

                    // Loading indicator
                    // if (state.status == AuthStatus.unknown)
                    //   const Padding(
                    //     padding: EdgeInsets.only(top: 24),
                    //     child: Center(child: CircularProgressIndicator()),
                    //   ),
                  ],
                ),
                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignInButton(
    BuildContext context, {
    required VoidCallback? onPressed,
    required String icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(
        icon,
        width: 24,
        height: 24,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
