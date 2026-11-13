import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/widgets/FindJobBrand.dart';

class FindJobAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FindJobAppBar({
    super.key,
    this.actions = const [],
    this.title,
    this.section,
    this.icon,
  });

  final List<Widget> actions;
  final String? title;
  final String? section;
  final IconData? icon;

  @override
  Size get preferredSize => Size.fromHeight(section == null ? 64 : 140);

  @override
  Widget build(BuildContext context) {
    final heading = section;
    final titleIcon = icon;
    return AppBar(
      toolbarHeight: heading == null ? 64 : 82,
      titleSpacing: 20,
      title: title == null
          ? const FindJobBrand()
          : Row(
              children: [
                if (titleIcon != null) ...[
                  Icon(titleIcon),
                  const SizedBox(width: 8),
                ],
                Flexible(child: Text(title!, overflow: TextOverflow.ellipsis)),
              ],
            ),
      actions: heading == null ? actions : null,
      bottom: heading == null
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(58),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            heading,
                            style: findJobHeadline(context, 38),
                          ),
                        ),
                        ...actions,
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
