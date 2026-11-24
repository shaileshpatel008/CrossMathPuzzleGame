import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_text.dart';
import 'buttons.dart';
import 'dialogs.dart';

enum UpdateChoice { update, later, skip }

/// "Update available" (optional) / "Update required" (forced).
class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key, required this.force, this.version, this.notes, this.canSkip = false});

  final bool force;
  final String? version;
  final String? notes;
  final bool canSkip;

  @override
  Widget build(BuildContext context) {
    final cleanNotes = notes?.trim();
    return PopScope(
      canPop: !force,
      child: AppDialog(
        onClose: force ? null : () => Get.back(result: UpdateChoice.later),
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: force ? AppColors.coral : AppColors.gold,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: force ? const Color(0xFFB54848) : AppColors.goldShadow,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Icon(
              force ? Icons.system_security_update_warning_rounded : Icons.system_update_rounded,
              size: 38,
              color: force ? AppColors.onCoral : AppColors.onGold,
            ),
          ),
          const SizedBox(height: 18),
          Text(force ? 'Update required' : 'Update available', style: AppText.display(24)),
          const SizedBox(height: 8),
          Text(
            force
                ? 'This version is no longer supported. Please update to keep playing — your progress is saved.'
                : version == null
                ? 'A new version of CrossMath Puzzle is ready with improvements and fixes.'
                : 'Version $version is ready with improvements and fixes.',
            textAlign: TextAlign.center,
            style: AppText.muted(14).copyWith(height: 1.5),
          ),
          if (cleanNotes != null && cleanNotes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 140),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("WHAT'S NEW", style: AppText.label()),
                    const SizedBox(height: 6),
                    Text(cleanNotes, style: AppText.body(13, color: AppColors.text, height: 1.5)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Update now',
            icon: Icons.download_rounded,
            tone: force ? ButtonTone.coral : ButtonTone.gold,
            onPressed: () => Get.back(result: UpdateChoice.update),
          ),
          if (!force) ...[
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Later',
              onPressed: () => Get.back(result: UpdateChoice.later),
            ),
            if (canSkip)
              TextLinkButton('Skip this version', onPressed: () => Get.back(result: UpdateChoice.skip)),
          ],
        ],
      ),
    );
  }
}

/// Android flexible update finished downloading.
class UpdateReadyDialog extends StatelessWidget {
  const UpdateReadyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: AppColors.mintShadow, offset: Offset(0, 7))],
          ),
          child: const Icon(Icons.download_done_rounded, size: 38, color: AppColors.onMint),
        ),
        const SizedBox(height: 18),
        Text('Update ready', style: AppText.display(24)),
        const SizedBox(height: 8),
        Text(
          'The new version has downloaded. Restart now to finish installing — it takes a few seconds and your progress is saved.',
          textAlign: TextAlign.center,
          style: AppText.muted(14).copyWith(height: 1.5),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Restart now',
          icon: Icons.restart_alt_rounded,
          tone: ButtonTone.mint,
          onPressed: () => Get.back(result: true),
        ),
        const SizedBox(height: 4),
        TextLinkButton('Later', onPressed: () => Get.back(result: false)),
      ],
    );
  }
}
