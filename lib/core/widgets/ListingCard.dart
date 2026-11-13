import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/widgets/InitialsAvatar.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.author,
    required this.source,
    required this.title,
    required this.children,
    this.titleBesideAuthor = false,
    this.verified = false,
    this.onTap,
    this.onDetails,
    this.trailing,
  });

  final String author;
  final String source;
  final String title;
  final List<Widget> children;
  final bool titleBesideAuthor;
  final bool verified;
  final VoidCallback? onTap;
  final VoidCallback? onDetails;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final heading = Text(
      title,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: textTheme.titleMedium?.copyWith(
        fontSize: titleBesideAuthor ? 20 : 17,
        fontWeight: FontWeight.w600,
        height: 1.22,
      ),
    );
    final byline = Row(
      children: [
        Flexible(
          child: Text(
            author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (verified) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.verified,
            size: 14,
            color: AppColors.primary,
            semanticLabel: 'Аккредитована',
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(21),
          side: BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InitialsAvatar(
                      name: author,
                      size: titleBesideAuthor ? 39 : 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: byline),
                              if (source.trim().isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: Text(
                                      source,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.muted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (titleBesideAuthor) ...[
                            const SizedBox(height: 3),
                            heading,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (!titleBesideAuthor) ...[const SizedBox(height: 6), heading],
                ...children,
                const SizedBox(height: 7),
                const Divider(height: 1),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onDetails,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 40),
                            textStyle: TextStyle(
                              fontSize: titleBesideAuthor ? 14 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                          ),
                          label: const Text('Подробнее'),
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
