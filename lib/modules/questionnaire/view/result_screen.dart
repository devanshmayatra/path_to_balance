import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final bool isRecentEvaluation;

  const ResultScreen({
    super.key,
    required this.result,
    this.isRecentEvaluation = false,
  });

  @override
  Widget build(BuildContext context) {
    final sentiment = result['sentiment'] as String? ?? '';
    final riskLevel = result['risk_level'] as String? ?? '';
    final summary = result['summary'] as String? ?? '';
    final suggestions = result['suggestions'] as List<dynamic>? ?? [];
    final score = result['assesmentScore']?.toString() ?? '';

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('AI Evaluation Result'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () async {
            try {
              final prefs = await SharedPreferences.getInstance();
              // Use a null check operator with a default value instead of force unwrapping
              bool hasSeenOnboarding =
                  prefs.getBool('hasSeenOnboarding') ?? false;

              log('hasSeenOnboarding: $hasSeenOnboarding');

              if (hasSeenOnboarding) {
                // Use pushReplacementNamed instead of popAndPushNamed
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              } else if (isRecentEvaluation) {
                Navigator.pop(context);
              } else {
                // Make sure this route exists in your route definitions
                if (Navigator.canPop(context)) {
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName(AppRoutes.questionaryList),
                  );
                } else {
                  // Fallback - go to home if can't pop
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                }
              }
            } catch (e) {
              log('Error navigating back: $e');
              // Fallback - just try to go back
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              }
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoTile(context, label: 'Sentiment', value: sentiment),
              _infoTile(context, label: 'Risk Level', value: riskLevel),
              _infoTile(context, label: 'Assessment Score', value: score),
              const SizedBox(height: 24),
              Text('Summary', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(summary, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              Text('Suggestions', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...suggestions.map(
                (s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.check_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      s.toString(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
