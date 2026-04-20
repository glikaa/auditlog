import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../state/user_profile_cubit.dart';
import '../state/user_profile_state.dart';
import '../widgets/avatar_picker_widget.dart';
import '../widgets/profile_form_widget.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listener: _handleStateChange,
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.profilePageTitle),
            actions: [
              if (state is UserProfileLoaded && !state.isEditing)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.editProfile,
                  onPressed: () =>
                      context.read<UserProfileCubit>().startEditing(),
                ),
            ],
          ),
          body: switch (state) {
            UserProfileInitial() => const _InitialLoader(),
            UserProfileLoading() => const _LoadingBody(),
            UserProfileLoaded(:final profile) => ResponsiveLayout(
                mobile: _ProfileBody(
                  profile: profile,
                  state: state,
                  userId: userId,
                  maxWidth: double.infinity,
                ),
                desktop: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: _ProfileBody(
                      profile: profile,
                      state: state,
                      userId: userId,
                      maxWidth: 640,
                    ),
                  ),
                ),
              ),
            UserProfileError(:final message) => _ErrorBody(
                message: message,
                onRetry: () =>
                    context.read<UserProfileCubit>().loadProfile(userId),
              ),
            // AvatarPickerReady is transient — handled in listener
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }

  void _handleStateChange(BuildContext context, UserProfileState state) {
    final l10n = AppLocalizations.of(context)!;

    switch (state) {
      case AvatarPickerReady(:final file, :final previousState):
        context.read<UserProfileCubit>().uploadAvatar(
              userId: userId,
              imageFile: file,
              currentState: previousState,
            );

      case UserProfileLoaded(isSaving: false, isEditing: false)
          when context.read<UserProfileCubit>().state is! UserProfileLoading:
        // Snackbar only on successful save (guard against initial load)
        final prev = context.read<UserProfileCubit>().state;
        if (prev is! UserProfileLoaded) break;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdated)),
        );

      case UserProfileError(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );

      default:
        break;
    }
  }
}

// ---------------------------------------------------------------------------
// Body sub-widgets
// ---------------------------------------------------------------------------

class _InitialLoader extends StatelessWidget {
  const _InitialLoader();

  @override
  Widget build(BuildContext context) {
    // Kicks off load on first render
    return Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final screen = context.findAncestorWidgetOfExactType<UserProfileScreen>();
          if (screen != null) {
            context.read<UserProfileCubit>().loadProfile(screen.userId);
          }
        });
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
    required this.state,
    required this.userId,
    required this.maxWidth,
  });

  final dynamic profile;
  final UserProfileLoaded state;
  final String userId;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarPickerWidget(
            profile: state.profile,
            isEditing: state.isEditing,
            isUploading: state.isUploadingAvatar,
            onPickImage: (source) =>
                context.read<UserProfileCubit>().pickAvatar(source),
          ),
          const SizedBox(height: 24),
          if (state.isEditing) ...[
            ProfileFormWidget(
              profile: state.profile,
              isSaving: state.isSaving,
              onSave: (updated) =>
                  context.read<UserProfileCubit>().saveProfile(updated),
              onCancel: () =>
                  context.read<UserProfileCubit>().cancelEditing(),
            ),
          ] else ...[
            _ProfileReadView(profile: state.profile),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () =>
                  context.read<UserProfileCubit>().loadProfile(userId),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.refreshProfile),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileReadView extends StatelessWidget {
  const _ProfileReadView({required this.profile});

  final dynamic profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          (profile.fullName as String),
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          profile.email as String,
          style: textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        if (profile.bio != null && (profile.bio as String).isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            profile.bio as String,
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
