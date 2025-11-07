import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

/// Mở bottom sheet chọn avatar, trả về File (camera hoặc thư viện)
Future<File?> showMediaPickerSheet(
    BuildContext context, {
      required Future<File?> Function() onTakePhoto,
    }) {
  return showModalBottomSheet<File?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) {
      // vùng ngoài sheet: tap để đóng
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(modalCtx).pop(),
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            // sheet thật sự
            child: _MediaPickerSheet(onTakePhoto: onTakePhoto),
          ),
        ),
      );
    },
  );
}

class _MediaPickerSheet extends StatefulWidget {
  final Future<File?> Function() onTakePhoto;

  const _MediaPickerSheet({required this.onTakePhoto});

  @override
  State<_MediaPickerSheet> createState() => _MediaPickerSheetState();
}

class _MediaPickerSheetState extends State<_MediaPickerSheet> {
  List<AssetEntity> _assets = [];
  bool _loading = true;
  bool _noPermission = false;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      setState(() {
        _noPermission = true;
        _loading = false;
      });
      return;
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(
            type: OrderOptionType.createDate,
            asc: false, // mới nhất trước
          ),
        ],
      ),
    );

    if (paths.isEmpty) {
      setState(() {
        _assets = [];
        _loading = false;
      });
      return;
    }

    final first = paths.first;
    final assets = await first.getAssetListPaged(page: 0, size: 60);

    setState(() {
      _assets = assets;
      _loading = false;
    });
  }

  Future<void> _pickFromCamera() async {
    final f = await widget.onTakePhoto();
    if (f == null) return;
    Navigator.of(context).pop(f);
  }

  Future<void> _pickFromAsset(AssetEntity a) async {
    final f = await a.file;
    if (f == null) return;
    Navigator.of(context).pop(f);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      // chặn tap bên trong để không đóng sheet
      onTap: () {},
      child: DraggableScrollableSheet(
        initialChildSize: 0.25, // 25% chiều cao
        minChildSize: 0.25,
        maxChildSize: 0.5, // kéo tối đa 50%
        builder: (context, scrollController) {
          // tách 3 ảnh đầu cho hàng trên
          final topThumbs = _assets.take(3).toList();
          final gridAssets = _assets.skip(topThumbs.length).toList();

          return Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(18)),
              boxShadow: const [
                BoxShadow(blurRadius: 18, color: Colors.black26),
              ],
            ),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: cs.outlineVariant.withOpacity(.7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const Text(
                          'Chọn ảnh đại diện',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Hàng trên: chụp ảnh + 0–3 ảnh mới nhất (không có ô trống)
                        Row(
                          children: [
                            // ô chụp ảnh
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Material(
                                    color: Colors.black,
                                    child: InkWell(
                                      onTap: _pickFromCamera,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.photo_camera_outlined,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Chụp ảnh',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // các ảnh preview
                            for (final a in topThumbs) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: GestureDetector(
                                      onTap: () => _pickFromAsset(a),
                                      child: AssetEntityImage(
                                        a,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Phần dưới: grid ảnh còn lại
                if (_noPermission)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Không được cấp quyền truy cập thư viện',
                        style: TextStyle(
                          color: cs.error,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (_loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final a = gridAssets[index];
                          return GestureDetector(
                            onTap: () => _pickFromAsset(a),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AssetEntityImage(
                                a,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        childCount: gridAssets.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
