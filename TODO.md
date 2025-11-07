# TODO: Implement Profile Picture Selection Flow

## Steps to Complete:
- [x] Add image_picker dependency to pubspec.yaml
- [x] Run flutter pub get to install dependencies
- [x] Implement take_profile.dart: Create page with camera/gallery selection, image picker, and navigation to profile_approval_screen
- [x] Modify otp_screen.dart: Change navigation from ProfileApprovalScreen to take_profile.dart
- [x] Update profile_approval_screen.dart: Accept image parameter and display selected image instead of dummy photo
- [x] Test the navigation flow: OTP -> take_profile -> approval -> BottomNav
