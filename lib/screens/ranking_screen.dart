// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../config/app_colors.dart';
// import '../config/app_text_styles.dart';
// import '../models/user_model.dart';
// import '../services/user_service.dart';
//
// class RankingScreen extends StatefulWidget {
//   const RankingScreen({super.key});
//
//   @override
//   State<RankingScreen> createState() => _RankingScreenState();
// }
//
// class _RankingScreenState extends State<RankingScreen> {
//   List<UserModel> allUsers = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//   }
//
//   Future<void> _loadUsers() async {
//     try {
//       final users = await UserService().getAllUsers();
//       setState(() {
//         allUsers = users;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading users: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final colors = AppColors.getColors(isDark);
//     final textStyles = AppTextStyles.getStyles(isDark);
//
//     if (isLoading) {
//       return Scaffold(
//         backgroundColor: colors['background'],
//         appBar: AppBar(
//           backgroundColor: colors['background'],
//           elevation: 0,
//           title: Text('All Time Ranking', style: textStyles['headingLarge']),
//           centerTitle: true,
//         ),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     final sortedUsers = [...allUsers]..sort((a, b) => b.points.compareTo(a.points));
//     final currentUserId = Supabase.instance.client.auth.currentUser?.id;
//
//     final podiumColors = [
//       const Color(0xFFD4AF37), // злато
//       const Color(0xFFC0C0C0), // сребро
//       const Color(0xFFCD7F32), // бронз
//     ];
//
//     return Scaffold(
//       backgroundColor: colors['background'],
//       appBar: AppBar(
//         backgroundColor: colors['background'],
//         elevation: 0,
//         title: Text('All Time Ranking', style: textStyles['headingLarge']),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 🪜 Top 3 Podium: gold in center + цифри 2 1 3
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [1, 0, 2].map((originalIndex) {
//                 final user = sortedUsers[originalIndex];
//                 final heights = [140.0, 110.0, 100.0];
//                 final height = heights[originalIndex];
//                 final color = podiumColors[originalIndex];
//                 final place = originalIndex + 1;
//
//                 return Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 30,
//                       backgroundImage: user.imageUrl != null
//                           ? NetworkImage(user.imageUrl!)
//                           : null,
//                       child: user.imageUrl == null
//                           ? const Icon(Icons.person, size: 30)
//                           : null,
//                     ),
//                     const SizedBox(height: 6),
//                     Text(user.name, style: textStyles['bodyRegular']),
//                     const SizedBox(height: 6),
//                     Container(
//                       width: 60,
//                       height: height,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: color,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         '$place',
//                         style: textStyles['headingLarge']?.copyWith(color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 30),
//
//             // 📋 Full list (вкл. top 3)
//             Expanded(
//               child: ListView.separated(
//                 itemCount: sortedUsers.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 10),
//                 itemBuilder: (context, index) {
//                   final user = sortedUsers[index];
//                   final place = index + 1;
//                   final isCurrentUser = user.id == currentUserId;
//
//                   final placeEmoji = switch (place) {
//                     1 => '🥇',
//                     2 => '🥈',
//                     3 => '🥉',
//                     _ => '$place.'
//                   };
//
//                   return Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     decoration: BoxDecoration(
//                       color: isCurrentUser ? Colors.teal.shade700 : colors['box'],
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 3,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Text(
//                           placeEmoji,
//                           style: textStyles['headingLarge']?.copyWith(
//                             color: isCurrentUser ? Colors.white : null,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         CircleAvatar(
//                           radius: 18,
//                           backgroundImage: user.imageUrl != null
//                               ? NetworkImage(user.imageUrl!)
//                               : null,
//                           child: user.imageUrl == null
//                               ? Icon(Icons.person, size: 18, color: isCurrentUser ? Colors.white : null)
//                               : null,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             user.name,
//                             style: isCurrentUser
//                                 ? textStyles['headingLarge']?.copyWith(color: Colors.white)
//                                 : textStyles['bodyRegular'],
//                           ),
//                         ),
//                         Text(
//                           '${user.points}',
//                           style: isCurrentUser
//                               ? textStyles['headingLarge']?.copyWith(color: Colors.white)
//                               : textStyles['bodyRegular'],
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../config/app_colors.dart';
// import '../config/app_text_styles.dart';
// import '../models/user_model.dart';
// import '../services/user_service.dart';
//
// class RankingScreen extends StatefulWidget {
//   const RankingScreen({super.key});
//
//   @override
//   State<RankingScreen> createState() => _RankingScreenState();
// }
//
// class _RankingScreenState extends State<RankingScreen> {
//   List<UserModel> allUsers = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//   }
//
//   Future<void> _loadUsers() async {
//     try {
//       final users = await UserService().getAllUsers();
//       setState(() {
//         allUsers = users;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading users: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final colors = AppColors.getColors(isDark);
//     final textStyles = AppTextStyles.getStyles(isDark);
//
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     final sortedUsers = [...allUsers]..sort((a, b) => b.points.compareTo(a.points));
//     final currentUserId = Supabase.instance.client.auth.currentUser?.id;
//
//     final podiumColors = [
//       const Color(0xFFD4AF37),
//       const Color(0xFFC0C0C0),
//       const Color(0xFFCD7F32),
//     ];
//
//     return Scaffold(
//       backgroundColor: colors['background'],
//       appBar: AppBar(
//         backgroundColor: colors['background'],
//         elevation: 0,
//         title: Text('All Time Ranking', style: textStyles['headingLarge']),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 🏆 Podium
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [1, 0, 2].map((originalIndex) {
//                 if (originalIndex >= sortedUsers.length) return const SizedBox.shrink();
//                 final user = sortedUsers[originalIndex];
//                 final heights = [140.0, 110.0, 100.0];
//                 final height = heights[originalIndex];
//                 final color = podiumColors[originalIndex];
//                 final place = originalIndex + 1;
//
//                 return Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 30,
//                       backgroundImage: user.imageUrl != null
//                           ? NetworkImage(user.imageUrl!)
//                           : null,
//                       child: user.imageUrl == null
//                           ? const Icon(Icons.person, size: 30)
//                           : null,
//                     ),
//                     const SizedBox(height: 6),
//                     Text(user.name, style: textStyles['bodyRegular']),
//                     const SizedBox(height: 6),
//                     Container(
//                       width: 60,
//                       height: height,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: color,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         '$place',
//                         style: textStyles['headingLarge']?.copyWith(color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 30),
//
//             // 📋 Full List
//             Expanded(
//               child: ListView.separated(
//                 itemCount: sortedUsers.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 10),
//                 itemBuilder: (context, index) {
//                   final user = sortedUsers[index];
//                   final place = index + 1;
//                   final isCurrentUser = user.id == currentUserId;
//
//                   final placeEmoji = switch (place) {
//                     1 => '🥇',
//                     2 => '🥈',
//                     3 => '🥉',
//                     _ => '$place.'
//                   };
//
//                   return Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     decoration: BoxDecoration(
//                       color: isCurrentUser ? Colors.teal.shade700 : colors['box'],
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 3,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Text(
//                           placeEmoji,
//                           style: textStyles['headingLarge']?.copyWith(
//                             color: isCurrentUser ? Colors.white : null,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         CircleAvatar(
//                           radius: 18,
//                           backgroundImage: user.imageUrl != null
//                               ? NetworkImage(user.imageUrl!)
//                               : null,
//                           child: user.imageUrl == null
//                               ? Icon(Icons.person, size: 18, color: isCurrentUser ? Colors.white : null)
//                               : null,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             user.name,
//                             style: isCurrentUser
//                                 ? textStyles['headingLarge']?.copyWith(color: Colors.white)
//                                 : textStyles['bodyRegular'],
//                           ),
//                         ),
//                         Text(
//                           '${user.points}',
//                           style: isCurrentUser
//                               ? textStyles['headingLarge']?.copyWith(color: Colors.white)
//                               : textStyles['bodyRegular'],
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class RankingScreen extends StatefulWidget {
  final UserModel currentUser;

  const RankingScreen({super.key, required this.currentUser});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<UserModel> allUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await UserService().getAllUsers();
      setState(() {
        allUsers = users;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDark);
    final textStyles = AppTextStyles.getStyles(isDark);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final sortedUsers = [...allUsers]..sort((a, b) => b.points.compareTo(a.points));
    final currentUserIndex = sortedUsers.indexWhere((u) => u.id == widget.currentUser.id);
    final currentUserInTop3 = currentUserIndex >= 0 && currentUserIndex <= 2;

    final podiumColors = [
      const Color(0xFFD4AF37),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];

    return Scaffold(
      backgroundColor: colors['background'],
      appBar: AppBar(
        backgroundColor: colors['background'],
        elevation: 0,
        title: Text('All Time Ranking', style: textStyles['headingLarge']),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👑 Podium
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [1, 0, 2].map((originalIndex) {
                if (originalIndex >= sortedUsers.length) return const SizedBox.shrink();
                final user = sortedUsers[originalIndex];
                final heights = [140.0, 110.0, 100.0];
                final height = heights[originalIndex];
                final color = podiumColors[originalIndex];
                final place = originalIndex + 1;

                return Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: user.imageUrl != null
                          ? NetworkImage(user.imageUrl!)
                          : null,
                      child: user.imageUrl == null ? const Icon(Icons.person, size: 30) : null,
                    ),
                    const SizedBox(height: 6),
                    Text(user.name, style: textStyles['bodyRegular']),
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: height,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$place',
                        style: textStyles['headingLarge']?.copyWith(color: Colors.black),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // 👤 Current user (if not in top 3)
            if (!currentUserInTop3 && currentUserIndex != -1) ...[
              _buildUserTile(
                widget.currentUser,
                currentUserIndex + 1,
                colors,
                textStyles,
                isCurrentUser: true,
              ),
              const SizedBox(height: 12),
            ],

            // 📋 Full list
            Expanded(
              child: ListView.separated(
                itemCount: sortedUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = sortedUsers[index];
                  final place = index + 1;
                  final isCurrentUser = user.id == widget.currentUser.id;

                  return _buildUserTile(user, place, colors, textStyles, isCurrentUser: isCurrentUser);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(
      UserModel user,
      int place,
      Map<String, Color> colors,
      Map<String, TextStyle> textStyles, {
        bool isCurrentUser = false,
      }) {
    final placeEmoji = switch (place) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '$place.'
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // увеличен padding
      decoration: BoxDecoration(
        color: isCurrentUser ? colors['accent'] : colors['box'],
        borderRadius: BorderRadius.circular(16), // леко по-заоблено
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            placeEmoji,
            style: textStyles['bodyRegular']?.copyWith(
              color: isCurrentUser ? Colors.white : null,
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 24, // по-голям аватар
            backgroundImage: user.imageUrl != null ? NetworkImage(user.imageUrl!) : null,
            child: user.imageUrl == null
                ? Icon(Icons.person, size: 24, color: isCurrentUser ? Colors.white : null)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user.name,
              style: textStyles['bodyRegular']?.copyWith(
                fontSize: 18, // по-голям шрифт
                color: isCurrentUser ? Colors.white : null,
              ),
            ),
          ),
          Text(
            '${user.points}',
            style: textStyles['bodyRegular']?.copyWith(
              fontSize: 18,
              color: isCurrentUser ? Colors.white : null,
            ),
          ),
        ],
      ),
    );

}
}
