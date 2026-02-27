import 'package:hesabu_app/features/settings/domain/settings_repository.dart';

class MockSettingsRepository implements SettingsRepository {
  @override
  Future<UserProfile> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserProfile(
      name: 'John Doe',
      membershipType: 'Premium Member',
      activeGroupName: 'Savvy Savers Group',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAcmdBLLosv5m-fgk2R7j0oMOzGK2okBaAGv_YTItY4od3Fiij-y0Q4yoZXGpKqHizRGlz6MRkCF0WSvK3HL2vmTp3wGHPWBw24-w0obZQOyWHH_FNcllVFWevS9F_-RWn93Z_Rh3OTlVBoPXAxzmjDgFCNqbKQb7tV9D-x1rx_HY9AtWOqWaKNFzewI3lanZbFwKumgV8KuvKNeiK6KIIxbcQZb4SJ90FPCa96vVv76QcupQ_3OLYkHQuOgXBLYe2RczAleTuMNpw',
    );
  }
}
