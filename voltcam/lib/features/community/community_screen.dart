import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/glassmorphism.dart';

class FaqItem {
  final String category;
  final String question;
  final String answer;

  const FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class CommunityQuestion {
  final String id;
  final String author;
  final String title;
  final String category;
  final int votes;
  final int answersCount;
  final bool isResolved;
  final DateTime createdAt;

  const CommunityQuestion({
    required this.id,
    required this.author,
    required this.title,
    required this.category,
    required this.votes,
    required this.answersCount,
    required this.isResolved,
    required this.createdAt,
  });

  CommunityQuestion copyWith({
    String? id,
    String? author,
    String? title,
    String? category,
    int? votes,
    int? answersCount,
    bool? isResolved,
    DateTime? createdAt,
  }) {
    return CommunityQuestion(
      id: id ?? this.id,
      author: author ?? this.author,
      title: title ?? this.title,
      category: category ?? this.category,
      votes: votes ?? this.votes,
      answersCount: answersCount ?? this.answersCount,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

final communityQuestionsProvider = StateProvider<List<CommunityQuestion>>((ref) {
  return [
    CommunityQuestion(
      id: 'q-1',
      author: 'Paul M.',
      title: 'Comment connecter mon Boîtier VoltCam sur un réseau Wi-Fi 2.4GHz ?',
      category: 'Mon Boîtier',
      votes: 24,
      answersCount: 5,
      isResolved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CommunityQuestion(
      id: 'q-2',
      author: 'Amina K.',
      title: 'Quel est le calcul exact du score de confiance GridTrust ?',
      category: 'GridTrust',
      votes: 41,
      answersCount: 8,
      isResolved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CommunityQuestion(
      id: 'q-3',
      author: 'Cédric T.',
      title: 'Mon relais Protect Mode se déclenche en cas de 250V : est-ce normal ?',
      category: 'Protect Mode',
      votes: 15,
      answersCount: 3,
      isResolved: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    CommunityQuestion(
      id: 'q-4',
      author: 'Samuel N.',
      title: 'Peut-on signaler une baisse de tension sans boîtier connecté ?',
      category: 'Signalement',
      votes: 19,
      answersCount: 4,
      isResolved: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];
});

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFaqCategory = 'Mon Boîtier';

  final List<FaqItem> _faqItems = const [
    // Mon Boîtier
    FaqItem(
      category: 'Mon Boîtier',
      question: 'Quels sont les indicateurs LED sur le Boîtier IoT ?',
      answer: 'Vert fixe = Tension normale (220V)\nJaune clignotant = Fluctuations détectées\nRouge = Coupure ou surtension active\nBleu = Connexion Wi-Fi/BLE en cours',
    ),
    FaqItem(
      category: 'Mon Boîtier',
      question: 'Que se passe-t-il si la connexion Wi-Fi s\'interrompt ?',
      answer: 'Le boîtier stocke localement jusqu\'à 500 événements télémétriques dans sa mémoire chiffrée. Dès la reconnexion, la file d\'attente hors-ligne synchronise les données.',
    ),

    // GridTrust
    FaqItem(
      category: 'GridTrust',
      question: 'Comment GridTrust valide-t-il les incidents ?',
      answer: 'GridTrust utilise un algorithme de consensus décentralisé. Une coupure est confirmée si au moins 3 boîtiers indépendants d\'une même zone géographique signalent l\'événement sous 60 secondes.',
    ),
    FaqItem(
      category: 'GridTrust',
      question: 'Qu\'est-ce que le score de confiance % ?',
      answer: 'C\'est le pourcentage certifié de validité de l\'incident (0 à 100%), calculé en croisant le nombre de boîtiers, l\'historique et la vérification réseau.',
    ),

    // Protect Mode
    FaqItem(
      category: 'Protect Mode',
      question: 'Comment fonctionne le mode Protect Mode ?',
      answer: 'Protect Mode évalue le risque en temps réel (0 à 100). En cas de score élevé (>70), il déclenche la coupure physique du relais ou l\'envoi d\'une alerte push d\'urgence.',
    ),
    FaqItem(
      category: 'Protect Mode',
      question: 'Quels sont les seuils de tension dangereux ?',
      answer: 'Sous-tension : < 185V (risque compresseur)\nSurtension : > 245V (risque circuits électroniques)',
    ),

    // Signalement
    FaqItem(
      category: 'Signalement',
      question: 'Comment effectuer un signalement citoyen ?',
      answer: 'Rendez-vous dans la Carte Live ou l\'onglet Réseau Social, appuyez sur "+ Signaler" et renseignez votre zone et le type de problème.',
    ),
    FaqItem(
      category: 'Signalement',
      question: 'Mon signalement est-il anonyme ?',
      answer: 'Oui, les données géographiques sont agrégées par zones (ex: Yaoundé Biyem-Assi) sans divulguer l\'adresse exacte.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAskQuestionDialog() {
    final titleController = TextEditingController();
    String category = 'Mon Boîtier';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
          title: const Text('Poser une question à la communauté'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Catégorie :', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: category,
                dropdownColor: AppColors.surface,
                items: const [
                  DropdownMenuItem(value: 'Mon Boîtier', child: Text('Mon Boîtier')),
                  DropdownMenuItem(value: 'GridTrust', child: Text('GridTrust')),
                  DropdownMenuItem(value: 'Protect Mode', child: Text('Protect Mode')),
                  DropdownMenuItem(value: 'Signalement', child: Text('Signalement')),
                ],
                onChanged: (val) {
                  if (val != null) category = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Votre question',
                  hintText: 'Posez votre question clairement...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;

                final newQ = CommunityQuestion(
                  id: 'q-${DateTime.now().millisecondsSinceEpoch}',
                  author: 'Utilisateur VoltCam',
                  title: titleController.text.trim(),
                  category: category,
                  votes: 1,
                  answersCount: 0,
                  isResolved: false,
                  createdAt: DateTime.now(),
                );

                ref.read(communityQuestionsProvider.notifier).update((qs) => [newQ, ...qs]);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Question publiée ! La communauté vous répondra rapidement.'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
              child: const Text('Soumettre'),
            ),
          ],
        );
      },
    );
  }

  void _upvoteQuestion(CommunityQuestion q) {
    ref.read(communityQuestionsProvider.notifier).update((qs) {
      return qs.map((item) {
        if (item.id == q.id) return item.copyWith(votes: item.votes + 1);
        return item;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(communityQuestionsProvider);
    final filteredFaqs = _faqItems.where((f) => f.category == _selectedFaqCategory).toList();

    return Scaffold(
      key: const Key('community_screen_scaffold'),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_alt_rounded, color: AppColors.maintenancePurple, size: 24),
            SizedBox(width: 8),
            Text('Communauté & Entraide'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.electricCyan,
          labelColor: AppColors.electricCyan,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Forum Entraide'),
            Tab(text: 'FAQ & Guides'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAskQuestionDialog,
        backgroundColor: AppColors.electricCyan,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.help_outline_rounded),
        label: const Text('Poser une question', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Q&A Discussion Board
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upvote Column
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_drop_up_rounded, size: 32, color: AppColors.electricCyan),
                          onPressed: () => _upvoteQuestion(q),
                        ),
                        Text(
                          '${q.votes}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GlassBadge(label: q.category, color: AppColors.maintenancePurple, fontSize: 10),
                              const SizedBox(width: 8),
                              if (q.isResolved)
                                const GlassBadge(
                                  label: 'Résolu',
                                  icon: Icons.check_circle_rounded,
                                  color: AppColors.successGreen,
                                  fontSize: 10,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            q.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Par ${q.author}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.forum_outlined, size: 14, color: AppColors.electricCyan),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${q.answersCount} réponse(s)',
                                    style: const TextStyle(fontSize: 12, color: AppColors.electricCyan),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Tab 2: Categorized FAQ
          Column(
            children: [
              const SizedBox(height: 12),
              // Category Selection Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['Mon Boîtier', 'GridTrust', 'Protect Mode', 'Signalement'].map((cat) {
                    final isSelected = _selectedFaqCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.electricCyan,
                        backgroundColor: AppColors.surfaceLight.withOpacity(0.5),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFaqCategory = cat;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // FAQ Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredFaqs.length,
                  itemBuilder: (context, index) {
                    final faq = filteredFaqs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: ExpansionTile(
                        iconColor: AppColors.electricCyan,
                        collapsedIconColor: AppColors.textMuted,
                        title: Text(
                          faq.question,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              faq.answer,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
