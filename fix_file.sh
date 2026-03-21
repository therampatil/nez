#!/bin/bash
sed -e '/class _ActionButton extends StatelessWidget {/,/^}/d' nez_app/lib/features/feed/presentation/new_home_screen.dart > nez_app/lib/features/feed/presentation/new_home_screen.tmp
mv nez_app/lib/features/feed/presentation/new_home_screen.tmp nez_app/lib/features/feed/presentation/new_home_screen.dart
sed -e '/class _BookmarkButton extends StatelessWidget {/,/^}/d' nez_app/lib/features/feed/presentation/new_home_screen.dart > nez_app/lib/features/feed/presentation/new_home_screen.tmp
mv nez_app/lib/features/feed/presentation/new_home_screen.tmp nez_app/lib/features/feed/presentation/new_home_screen.dart
