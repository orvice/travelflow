import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../models/location_marker.dart';

/// A dialog widget for adding or editing location markers.
///
/// In new marker mode, provide [position] to specify where the marker will be created.
/// In edit mode, provide [marker] to pre-fill the form with existing data.
class MarkerDialog extends StatefulWidget {
  /// The position for a new marker. Required when creating a new marker.
  final LatLng? position;

  /// The existing marker to edit. When provided, the dialog enters edit mode.
  final LocationMarker? marker;

  /// Callback when the user confirms the dialog.
  /// Returns the name and optional notes entered by the user.
  final void Function(String name, String? notes) onConfirm;

  /// Callback when the user cancels the dialog.
  final VoidCallback onCancel;

  const MarkerDialog({
    super.key,
    this.position,
    this.marker,
    required this.onConfirm,
    required this.onCancel,
  }) : assert(
         position != null || marker != null,
         'Either position or marker must be provided',
       );

  @override
  State<MarkerDialog> createState() => _MarkerDialogState();
}

class _MarkerDialogState extends State<MarkerDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();
  String? _nameError;

  bool get isEditMode => widget.marker != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.marker?.name ?? '');
    _notesController = TextEditingController(text: widget.marker?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _nameError = '请输入地点名称';
      });
      return;
    }

    setState(() {
      _nameError = null;
    });

    final notes = _notesController.text.trim();
    widget.onConfirm(name, notes.isEmpty ? null : notes);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Get coordinates for display
    final lat = widget.marker?.latitude ?? widget.position?.latitude ?? 0;
    final lng = widget.marker?.longitude ?? widget.position?.longitude ?? 0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            isEditMode ? Icons.edit_location : Icons.add_location,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            isEditMode ? '编辑地点' : '添加地点',
            style: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coordinates display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withAlpha(13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Name field
              Text(
                '名称 *',
                style: GoogleFonts.notoSansSc(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '输入地点名称',
                  hintStyle: GoogleFonts.notoSansSc(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  errorText: _nameError,
                  errorStyle: GoogleFonts.notoSansSc(color: Colors.red),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.notoSansSc(),
                autofocus: true,
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() {
                      _nameError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Notes field
              Text(
                '备注',
                style: GoogleFonts.notoSansSc(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: '添加备注（可选）',
                  hintStyle: GoogleFonts.notoSansSc(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.notoSansSc(),
                maxLines: 3,
                minLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(
            '取消',
            style: GoogleFonts.notoSansSc(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        FilledButton(
          onPressed: _validateAndSubmit,
          child: Text(
            isEditMode ? '保存' : '添加',
            style: GoogleFonts.notoSansSc(),
          ),
        ),
      ],
    );
  }
}

/// Shows the marker dialog and returns the result.
///
/// For creating a new marker, provide [position].
/// For editing an existing marker, provide [marker].
///
/// Returns a tuple of (name, notes) if confirmed, or null if cancelled.
Future<(String, String?)?> showMarkerDialog({
  required BuildContext context,
  LatLng? position,
  LocationMarker? marker,
}) async {
  assert(
    position != null || marker != null,
    'Either position or marker must be provided',
  );

  return showDialog<(String, String?)>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return MarkerDialog(
        position: position,
        marker: marker,
        onConfirm: (name, notes) {
          Navigator.of(context).pop((name, notes));
        },
        onCancel: () {
          Navigator.of(context).pop(null);
        },
      );
    },
  );
}
