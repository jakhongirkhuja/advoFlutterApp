import 'package:flutter/material.dart';

import '../../../../data/models/auth/user_model.dart';
import 'profile_content.dart';

/// Dedicated route screen for editing personal information.
class ProfileEditRouteScreen extends StatelessWidget {
  final UserModel user;

  const ProfileEditRouteScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) => ProfileEditScreen(user: user);
}
