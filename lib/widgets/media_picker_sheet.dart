import 'package:flutter/material.dart';

typedef AvatarGridTap = void Function(int index);

Future<void> showMediaPickerSheet(
    BuildContext context, {
      required VoidCallback onTakePhoto,
      AvatarGridTap? onTapMockImage,
    }) async {
  final cs = Theme.of(context).colorScheme;
  final h = MediaQuery.of(context).size.height * 0.5;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return SizedBox(
        height: h,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(blurRadius: 14, color: Colors.black26),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn ảnh hoặc video',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _AvatarSheetTile(
                        icon: Icons.photo_camera_outlined,
                        label: 'Chụp ảnh',
                        onTap: () {
                          Navigator.pop(context);
                          onTakePhoto();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    ),
                    itemCount: 8, // mock ảnh có sẵn
                    itemBuilder: (_, i) => InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.pop(context);
                        onTapMockImage?.call(i);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.image, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _AvatarSheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AvatarSheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 96,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: const Color(0xFF111827)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
