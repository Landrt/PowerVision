## 2026-07-24T18:30:25Z
<USER_REQUEST>
You are worker_m3 assigned to Milestone 3: Security Rules & Quality Verification (R4) for VoltCam.
Your working directory is `d:/GDG Hackthon build with IA/.agents/worker_m3`. Create your progress.md and handoff.md in that directory.

TASK:
1. Enforce `d:/GDG Hackthon build with IA/voltcam/firebase/firestore.rules`:
   - Client direct writes strictly restricted (deny `create`, `update`, `delete` on `devices`, `installations`, `syncBatches`, `deviceEvents`, `incidents`, `evidence`, `consents`, `auditLogs`).
   - `users/{uid}`: Owner-only read and write (`request.auth.uid == uid`).
   - `zones/{zoneId}`: Authenticated read (`request.auth != null`).
   - `incidents/{incidentId}`: Authenticated read (`request.auth != null`).
   - `communityPosts/{postId}`: Authenticated read. Write allowed for user posts (`request.auth.uid == resource.data.authorUid && !request.resource.data.isOfficial`), official posts restricted to server functions (`isOfficial == false`).
   - Add unit/structure tests verifying rules syntax and security invariants.
2. Implement Protect Mode Risk Scoring Engine in `d:/GDG Hackthon build with IA/voltcam/lib/domain/protect_mode/risk_score_calculator.dart`:
   - Risk score calculation formula (0-100) based on recent voltage reading (nominal 220V/230V in Cameroon), voltage variance/fluctuations, micro-outage frequency, and telemetry data age (stale data penalty).
   - Classify risk levels per `docs/02-conception-technique.md` (Section 7):
     - 0-39: Stable ("Continuer la surveillance normale")
     - 40-69: Monitor / À surveiller ("Éviter de brancher des appareils sensibles tant que l'instabilité persiste")
     - 70-100: Protect / Protéger ("Débrancher de façon sûre les appareils sensibles et attendre une tension stable")
   - Provide detailed appliance safety tips list tailored to risk tier (refrigerators, TVs, laptops, AC units).
3. Create unit tests in `test/protect_mode_test.dart` and `test/firestore_rules_test.dart`:
   - Test risk score calculation across stable, unstable, overvoltage, undervoltage, micro-outage, and stale data scenarios.
   - Test tier classification and safety advice generation.
   - Test rules syntax / structure assertion.
4. Run `flutter analyze` and `flutter test`.
5. Write complete handoff report to `d:/GDG Hackthon build with IA/.agents/worker_m3/handoff.md`.
6. Send message to parent ("57978ccd-b59e-4fe0-91fb-7ad9c132a0c2") when finished.

MANDATORY INTEGRITY WARNING: DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
</USER_REQUEST>
