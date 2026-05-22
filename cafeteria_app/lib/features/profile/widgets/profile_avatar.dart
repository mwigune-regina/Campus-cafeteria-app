import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';

/// Circular profile picture with an orange ring matching the role pill.
/// Tapping it lets the user pick a photo (camera or gallery) and uploads it
/// via [AuthNotifier.updateAvatar]. Shows a spinner while uploading and falls
/// back to a camera icon when no picture is set.
///
/// Shared by the profile screen (camera badge) and the personal-information
/// screen (orange "Edit" label) so avatar upload lives in one place.
class ProfileAvatar extends ConsumerStatefulWidget {
  final double size;

  /// Small orange camera badge on the bottom-right (profile screen style).
  final bool showCameraBadge;

  /// Underlined orange "Edit" label below the avatar (personal-info style).
  final bool showEditLabel;

  const ProfileAvatar({
    super.key,
    this.size = 100,
    this.showCameraBadge = true,
    this.showEditLabel = false,
  });

  @override
  ConsumerState<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends ConsumerState<ProfileAvatar> {
  final _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    if (_uploading) return;

    final source = await _chooseSource();
    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    final error = await ref.read(authProvider.notifier).updateAvatar(picked.path);
    if (!mounted) return;
    setState(() => _uploading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Profile picture updated'),
      backgroundColor: error == null ? AppColors.success : AppColors.danger,
    ));
  }

  Future<ImageSource?> _chooseSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: AppColors.navyBlue),
              title: Text('Take a photo', style: TextStyle(color: AppColors.textDark)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppColors.navyBlue),
              title: Text('Choose from gallery', style: TextStyle(color: AppColors.textDark)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final imageUrl = AppStrings.resolveMediaUrl(user?.avatarUrl);

    final avatar = GestureDetector(
      onTap: _pickAndUpload,
      child: Stack(
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightGray,
              border: Border.all(color: AppColors.orange, width: 3),
            ),
            child: ClipOval(child: _buildContent(imageUrl)),
          ),
          if (widget.showCameraBadge)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: Icon(Icons.camera_alt, size: 16, color: AppColors.white),
              ),
            ),
        ],
      ),
    );

    if (!widget.showEditLabel) return avatar;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickAndUpload,
          child: Text(
            'Edit',
            style: TextStyle(
              color: AppColors.orange,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(String? imageUrl) {
    if (_uploading) {
      return Center(
        child: SizedBox(
          width: widget.size * 0.28,
          height: widget.size * 0.28,
          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.orange),
        ),
      );
    }
    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderIcon(),
      );
    }
    return _placeholderIcon();
  }

  Widget _placeholderIcon() {
    return Icon(Icons.camera_alt_outlined, size: widget.size * 0.4, color: AppColors.textLight);
  }
}