$ErrorActionPreference = "Continue"

Set-Location -Path "d:\GDG Hackthon build with IA"

git add .gitignore
git commit -m "config(git): add root gitignore rules"

git add voltcam/lib/domain/models/user_model.dart
git commit -m "feat(domain): define UserModel schema and authentication"

git add voltcam/lib/domain/models/grid_zone_model.dart
git commit -m "feat(domain): define GridZoneModel for grid monitoring"

git add voltcam/lib/domain/models/incident_model.dart
git commit -m "feat(domain): define IncidentModel for outages & instability"

git add voltcam/lib/domain/models/device_model.dart
git commit -m "feat(domain): define DeviceModel for IoT box hardware"

git add voltcam/lib/domain/models/device_event_model.dart
git commit -m "feat(domain): define DeviceEventModel for last-gasp events"

git add voltcam/lib/domain/models/community_post_model.dart
git commit -m "feat(domain): define CommunityPostModel for social feeds"

git add voltcam/lib/domain/models/sync_batch_model.dart
git commit -m "feat(domain): define SyncBatchModel for offline sync"

git add voltcam/lib/domain/protect_mode/risk_score_calculator.dart
git commit -m "feat(domain): add Protect Mode risk score calculator logic"

git add voltcam/lib/core/theme/app_colors.dart
git commit -m "feat(theme): define AppColors palette (Primary, Accent, Light surface)"

git add voltcam/lib/core/theme/app_theme.dart
git commit -m "feat(theme): create AppTheme configuration with Light and Dark modes"

git add voltcam/lib/core/theme/glassmorphism.dart
git commit -m "feat(theme): add Glassmorphism UI components (GlassCard, GlassContainer)"

git add voltcam/lib/data/local/encrypted_storage.dart
git commit -m "feat(data): implement EncryptedStorage service using flutter_secure_storage"

git add voltcam/lib/data/local/offline_queue.dart
git commit -m "feat(data): add OfflineQueue for storing pending sync actions"

git add voltcam/lib/data/remote/voltcam_box_integration_service.dart
git commit -m "feat(data): create VoltCamBoxIntegrationService with WebSocket support"

git add voltcam/lib/core/router/app_router.dart
git commit -m "feat(router): implement GoRouter appRouter configuration & bottom nav shell"

git add voltcam/lib/core/providers/auth_provider.dart
git commit -m "feat(providers): add AuthProvider for user session state"

git add voltcam/lib/core/providers/device_provider.dart
git commit -m "feat(providers): add DeviceProvider for IoT telemetry state"

git add voltcam/lib/core/providers/incident_provider.dart
git commit -m "feat(providers): add IncidentProvider for active grid incidents"

git add voltcam/lib/core/providers/sync_provider.dart
git commit -m "feat(providers): add SyncProvider for offline batch updates"

git add voltcam/lib/features/map/map_screen.dart
git commit -m "feat(map): add MapScreen scaffold with custom light map style and theme toggle"

git add voltcam/lib/features/device/protect_mode_widget.dart
git commit -m "feat(device): add ProtectModeWidget with radial risk score gauge"

git add voltcam/lib/features/device/device_dashboard_screen.dart
git commit -m "feat(device): implement DeviceDashboardScreen with WebSocket pairing dialog"

git add voltcam/lib/features/assistant/assistant_chat_screen.dart
git commit -m "feat(assistant): integrate Gemini 1.5 Flash AI client into AssistantChatScreen"

git add voltcam/lib/features/assistant/assistant_screen.dart
git commit -m "feat(assistant): add AssistantScreen layout container"

git add voltcam/lib/features/social/social_feed_screen.dart
git commit -m "feat(social): implement SocialFeedScreen for citizen incident reporting"

git add voltcam/lib/features/social/social_screen.dart
git commit -m "feat(social): add SocialScreen wrapper layout"

git add voltcam/lib/features/community/community_screen.dart
git commit -m "feat(community): implement CommunityScreen with grid trust statistics"

git add voltcam/lib/main.dart
git commit -m "feat(app): configure main entry point with ConsumerWidget and themeModeProvider"

git add voltcam/test/
git commit -m "test: add unit & widget tests for theme, models, router, and screens"

git add .
git commit -m "chore: commit remaining assets, firebase configs, and artifacts"
