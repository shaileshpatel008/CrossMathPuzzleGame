import 'package:flutter/material.dart';

enum AchievementMetric {
  totalSolved,
  journeyCompleted,
  perfect,
  bestDailyStreak,
  trophies,
  fastHard,
  noHintSolves,
  expertSolved,
  masterSolved,
  dailySolved,
}

class AchievementDef {
  const AchievementDef(
    this.id,
    this.title,
    this.description,
    this.metric,
    this.target,
    this.reward,
    this.icon,
  );

  final String id;
  final String title;
  final String description;
  final AchievementMetric metric;
  final int target;
  final int reward;
  final IconData icon;

  static const all = <AchievementDef>[
    AchievementDef(
      'first_steps',
      'First Steps',
      'Solve your first puzzle',
      AchievementMetric.totalSolved,
      1,
      1,
      Icons.check_rounded,
    ),
    AchievementDef(
      'warming_up',
      'Warming Up',
      'Solve 10 journey levels',
      AchievementMetric.journeyCompleted,
      10,
      2,
      Icons.trending_up_rounded,
    ),
    AchievementDef(
      'century',
      'Century',
      'Solve 100 journey levels',
      AchievementMetric.journeyCompleted,
      100,
      5,
      Icons.bar_chart_rounded,
    ),
    AchievementDef(
      'marathon',
      'Marathon',
      'Solve 500 journey levels',
      AchievementMetric.journeyCompleted,
      500,
      10,
      Icons.directions_run_rounded,
    ),
    AchievementDef(
      'sharp',
      'Sharp Mind',
      'Earn 3 stars on 10 levels',
      AchievementMetric.perfect,
      10,
      2,
      Icons.star_rounded,
    ),
    AchievementDef(
      'perfectionist',
      'Perfectionist',
      'Earn 3 stars on 100 levels',
      AchievementMetric.perfect,
      100,
      5,
      Icons.auto_awesome_rounded,
    ),
    AchievementDef(
      'daily_habit',
      'Daily Habit',
      'Keep a 7-day daily streak',
      AchievementMetric.bestDailyStreak,
      7,
      3,
      Icons.local_fire_department_rounded,
    ),
    AchievementDef(
      'on_fire',
      'On Fire',
      'Keep a 14-day daily streak',
      AchievementMetric.bestDailyStreak,
      14,
      3,
      Icons.whatshot_rounded,
    ),
    AchievementDef(
      'daily_30',
      'Regular',
      'Solve 30 daily challenges',
      AchievementMetric.dailySolved,
      30,
      3,
      Icons.calendar_month_rounded,
    ),
    AchievementDef(
      'trophy_hunter',
      'Trophy Hunter',
      'Earn a monthly trophy',
      AchievementMetric.trophies,
      1,
      5,
      Icons.emoji_events_rounded,
    ),
    AchievementDef(
      'speed',
      'Speed Solver',
      'Solve a Hard puzzle under 3:00',
      AchievementMetric.fastHard,
      1,
      3,
      Icons.bolt_rounded,
    ),
    AchievementDef(
      'no_help',
      'No Help Needed',
      'Solve 50 puzzles without hints',
      AchievementMetric.noHintSolves,
      50,
      3,
      Icons.shield_rounded,
    ),
    AchievementDef(
      'expert',
      'Expert Thinker',
      'Solve an Expert puzzle',
      AchievementMetric.expertSolved,
      1,
      5,
      Icons.psychology_rounded,
    ),
    AchievementDef(
      'master',
      'Master Mind',
      'Solve a Master puzzle',
      AchievementMetric.masterSolved,
      1,
      10,
      Icons.workspace_premium_rounded,
    ),
  ];
}
