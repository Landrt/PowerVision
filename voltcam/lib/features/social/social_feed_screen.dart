import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/glassmorphism.dart';
import '../../domain/models/community_post_model.dart';

// State provider for community feed posts
final socialPostsProvider = StateProvider<List<CommunityPostModel>>((ref) {
  final now = DateTime.now();
  return [
    CommunityPostModel(
      id: 'post-official-1',
      authorUid: 'eneo-official',
      authorType: 'UTILITY',
      type: 'MAINTENANCE',
      title: 'Maintenance programmée sur le poste HTA Douala Akwa',
      content: 'L\'équipe ENEO effectuera des travaux d\'entretien préventif le 25 Juillet de 08h à 14h dans le secteur d\'Akwa. Risque de coupures intermittentes.',
      zoneId: 'douala-akwa',
      status: 'PUBLISHED',
      isOfficial: true,
      likesCount: 142,
      commentsCount: 28,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    CommunityPostModel(
      id: 'post-community-1',
      authorUid: 'usr-biyem-01',
      authorType: 'USER',
      type: 'ALERT',
      title: 'Baisse de tension critique observée à Biyem-Assi',
      content: 'Tension mesurée à 168V par mon boîtier VoltCam depuis 30min. Protégez vos congélateurs et appareils sensibles !',
      zoneId: 'yaounde-biyem-assi',
      status: 'PUBLISHED',
      isOfficial: false,
      likesCount: 56,
      commentsCount: 19,
      createdAt: now.subtract(const Duration(minutes: 35)),
    ),
    CommunityPostModel(
      id: 'post-tips-1',
      authorUid: 'voltcam-expert',
      authorType: 'ADMIN',
      type: 'TIPS',
      title: 'Conseils Protect Mode : comment isoler votre réfrigérateur',
      content: 'En cas de surtension (>245V), attendez au moins 5 minutes après le retour à 220V avant de rebrancher vos appareils à compresseur.',
      zoneId: null,
      status: 'PUBLISHED',
      isOfficial: true,
      likesCount: 89,
      commentsCount: 7,
      createdAt: now.subtract(const Duration(hours: 5)),
    ),
    CommunityPostModel(
      id: 'post-news-1',
      authorUid: 'eneo-official',
      authorType: 'UTILITY',
      type: 'NEWS',
      title: 'Mise en service du nouveau régulateur de tension Bastos',
      content: 'ENEO annonce la finalisation des travaux de stabilisation sur la ligne principale Yaoundé Bastos-Golf. Stabilité réseau améliorée de 35%.',
      zoneId: 'yaounde-bastos',
      status: 'PUBLISHED',
      isOfficial: true,
      likesCount: 210,
      commentsCount: 45,
      createdAt: now.subtract(const Duration(hours: 8)),
    ),
    CommunityPostModel(
      id: 'post-question-1',
      authorUid: 'usr-douala-88',
      authorType: 'USER',
      type: 'QUESTION',
      title: 'Est-ce que le rétablissement est confirmé à Bonanjo ?',
      content: 'Le courant vient de revenir chez moi à Bonanjo mais avec de légères variations. Vos boîtiers indiquent quoi ?',
      zoneId: 'douala-bonanjo',
      status: 'PUBLISHED',
      isOfficial: false,
      likesCount: 18,
      commentsCount: 12,
      createdAt: now.subtract(const Duration(minutes: 15)),
    ),
  ];
});

class SocialFeedScreen extends ConsumerStatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  ConsumerState<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen> {
  String _selectedTab = 'Tout'; // Tout, Officiel, Communauté
  String _selectedTypeFilter = 'ALL'; // ALL, NEWS, REPORT, QUESTION, MAINTENANCE, ALERT, TIPS
  final Set<String> _likedPostIds = {};
  final Set<String> _savedPostIds = {};

  Color _getPostTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'ALERT':
        return AppColors.dangerRed;
      case 'MAINTENANCE':
        return AppColors.maintenancePurple;
      case 'REPORT':
        return AppColors.voltYellow;
      case 'TIPS':
        return AppColors.successGreen;
      case 'NEWS':
        return AppColors.electricCyan;
      case 'QUESTION':
      default:
        return Colors.orangeAccent;
    }
  }

  IconData _getPostTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'ALERT':
        return Icons.warning_amber_rounded;
      case 'MAINTENANCE':
        return Icons.build_circle_outlined;
      case 'REPORT':
        return Icons.report_problem_outlined;
      case 'TIPS':
        return Icons.lightbulb_outline_rounded;
      case 'NEWS':
        return Icons.newspaper_rounded;
      case 'QUESTION':
      default:
        return Icons.help_outline_rounded;
    }
  }

  List<CommunityPostModel> _filterPosts(List<CommunityPostModel> posts) {
    return posts.where((post) {
      if (_selectedTab == 'Officiel' && !post.isOfficial) return false;
      if (_selectedTab == 'Communauté' && post.isOfficial) return false;
      if (_selectedTypeFilter != 'ALL' && post.type != _selectedTypeFilter) return false;
      return true;
    }).toList();
  }

  void _toggleLike(CommunityPostModel post) {
    setState(() {
      if (_likedPostIds.contains(post.id)) {
        _likedPostIds.remove(post.id);
        ref.read(socialPostsProvider.notifier).update((posts) {
          return posts.map((p) {
            if (p.id == post.id) return p.copyWith(likesCount: p.likesCount - 1);
            return p;
          }).toList();
        });
      } else {
        _likedPostIds.add(post.id);
        ref.read(socialPostsProvider.notifier).update((posts) {
          return posts.map((p) {
            if (p.id == post.id) return p.copyWith(likesCount: p.likesCount + 1);
            return p;
          }).toList();
        });
      }
    });
  }

  void _toggleSave(CommunityPostModel post) {
    setState(() {
      if (_savedPostIds.contains(post.id)) {
        _savedPostIds.remove(post.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication retirée de vos enregistrements.')),
        );
      } else {
        _savedPostIds.add(post.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication sauvegardée dans vos favoris !')),
        );
      }
    });
  }

  void _showNewPostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String type = 'REPORT';
    String zone = 'yaounde-biyem-assi';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
          title: const Text('Nouveau Signalement / Publication'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Catégorie :', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: type,
                  dropdownColor: AppColors.surface,
                  items: const [
                    DropdownMenuItem(value: 'REPORT', child: Text('Signalement (Report)')),
                    DropdownMenuItem(value: 'ALERT', child: Text('Alerte d\'Urgence (Alert)')),
                    DropdownMenuItem(value: 'QUESTION', child: Text('Question Communauté')),
                    DropdownMenuItem(value: 'TIPS', child: Text('Conseil & Astuce')),
                  ],
                  onChanged: (val) {
                    if (val != null) type = val;
                  },
                ),
                const SizedBox(height: 12),
                const Text('Zone concernée :', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: zone,
                  dropdownColor: AppColors.surface,
                  items: const [
                    DropdownMenuItem(value: 'yaounde-biyem-assi', child: Text('Yaoundé Biyem-Assi')),
                    DropdownMenuItem(value: 'douala-akwa', child: Text('Douala Akwa')),
                    DropdownMenuItem(value: 'yaounde-bastos', child: Text('Yaoundé Bastos')),
                    DropdownMenuItem(value: 'douala-bonanjo', child: Text('Douala Bonanjo')),
                  ],
                  onChanged: (val) {
                    if (val != null) zone = val;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre de la publication',
                    hintText: 'Ex: Baisse de tension importante...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description détaillée',
                    hintText: 'Partagez ce que vous observez...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir le titre et le contenu.')),
                  );
                  return;
                }

                final newPost = CommunityPostModel(
                  id: 'post-user-${DateTime.now().millisecondsSinceEpoch}',
                  authorUid: 'usr-current-user',
                  authorType: 'USER',
                  type: type,
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  zoneId: zone,
                  status: 'PUBLISHED',
                  isOfficial: false,
                  likesCount: 0,
                  commentsCount: 0,
                  createdAt: DateTime.now(),
                );

                ref.read(socialPostsProvider.notifier).update((posts) => [newPost, ...posts]);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Publication publiée sur le réseau communautaire VoltCam !'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
              child: const Text('Publier'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(socialPostsProvider);
    final filteredPosts = _filterPosts(posts);

    return Scaffold(
      key: const Key('social_screen_scaffold'),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hub_rounded, color: AppColors.voltYellow, size: 24),
            SizedBox(width: 8),
            Text('Réseau Social GridTrust'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, color: AppColors.electricCyan),
            onPressed: _showNewPostDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewPostDialog,
        backgroundColor: AppColors.electricCyan,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Publier', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Tabs (Tout, Officiel, Communauté)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['Tout', 'Officiel', 'Communauté'].map((tab) {
                final isSelected = _selectedTab == tab;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GlassButton(
                      onPressed: () {
                        setState(() {
                          _selectedTab = tab;
                        });
                      },
                      height: 40,
                      color: isSelected ? AppColors.electricCyan : AppColors.surfaceLight,
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 6 Post Types Pills Filter Horizontal Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildTypeFilterChip('Tous Types', 'ALL'),
                _buildTypeFilterChip('NEWS', 'NEWS'),
                _buildTypeFilterChip('REPORT', 'REPORT'),
                _buildTypeFilterChip('ALERT', 'ALERT'),
                _buildTypeFilterChip('MAINTENANCE', 'MAINTENANCE'),
                _buildTypeFilterChip('TIPS', 'TIPS'),
                _buildTypeFilterChip('QUESTION', 'QUESTION'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Social Feed Posts List
          Expanded(
            child: filteredPosts.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune publication ne correspond aux filtres.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      final typeColor = _getPostTypeColor(post.type);
                      final typeIcon = _getPostTypeIcon(post.type);
                      final isLiked = _likedPostIds.contains(post.id);
                      final isSaved = _savedPostIds.contains(post.id);

                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Author, Verification Badge, Post Type Badge
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: post.isOfficial
                                      ? AppColors.electricCyan.withOpacity(0.2)
                                      : AppColors.voltYellow.withOpacity(0.2),
                                  child: Icon(
                                    post.isOfficial ? Icons.verified_rounded : Icons.person_rounded,
                                    color: post.isOfficial ? AppColors.electricCyan : AppColors.voltYellow,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            post.isOfficial ? 'ENEO Officiel' : 'Citoyen GridTrust',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          if (post.isOfficial)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.electricCyan,
                                              size: 16,
                                            ),
                                        ],
                                      ),
                                      if (post.zoneId != null)
                                        Text(
                                          'Zone: ${post.zoneId}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                GlassBadge(
                                  label: post.type,
                                  icon: typeIcon,
                                  color: typeColor,
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Post Title & Content
                            Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              post.content,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Action buttons: Like, Comment, Save
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        color: isLiked ? AppColors.dangerRed : AppColors.textMuted,
                                        size: 20,
                                      ),
                                      onPressed: () => _toggleLike(post),
                                    ),
                                    Text(
                                      '${post.likesCount}',
                                      style: TextStyle(
                                        color: isLiked ? AppColors.dangerRed : AppColors.textMuted,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: AppColors.textMuted,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Ouverture des ${post.commentsCount} commentaires...'),
                                          ),
                                        );
                                      },
                                    ),
                                    Text(
                                      '${post.commentsCount}',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                    color: isSaved ? AppColors.voltYellow : AppColors.textMuted,
                                    size: 20,
                                  ),
                                  onPressed: () => _toggleSave(post),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilterChip(String label, String value) {
    final isSelected = _selectedTypeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.electricCyan : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedTypeFilter = value;
          });
        },
        backgroundColor: AppColors.surface.withOpacity(0.5),
        selectedColor: AppColors.electricCyan.withOpacity(0.2),
        side: BorderSide(
          color: isSelected ? AppColors.electricCyan : AppColors.glassBorderSubtle,
        ),
      ),
    );
  }
}
