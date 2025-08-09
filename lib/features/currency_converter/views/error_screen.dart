import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _bounce = Tween<double>(begin: 0.95, end: 1.06).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dynamic extra = GoRouterState.of(context).extra;
    String message;
    DateTime? lastUpdated;

    if (extra is String) {
      message = extra;
    } else if (extra is Map<String, dynamic>) {
      message = extra['message']?.toString() ??
          'We are unable to fetch latest data.';
      lastUpdated = extra['lastUpdated'] is DateTime
          ? extra['lastUpdated'] as DateTime
          : null;
    } else {
      message = 'We are unable to fetch latest data.';
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Offline / Error'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _bounce,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.95),
                                theme.colorScheme.secondary.withOpacity(0.85),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.wifi_off_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Connection problem',
                        style: textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (lastUpdated != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Last cached: ${lastUpdated.toLocal()}',
                          style: textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor),
                        ),
                      ] else ...[
                        const SizedBox(height: 6),
                        Text(
                          'If available, you’ll see cached values from the last 30 minutes.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _onRetryPressed,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () => context.pop(),
                            child: const Text('Go back'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(110, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _openNetworkSettings,
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Open network settings'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(180, 36),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onRetryPressed() {

    if (mounted) {
     
      context.pop({'retry': true});
    }
  }

  void _openNetworkSettings() {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open network settings (not implemented).')),
    );
  }
}
