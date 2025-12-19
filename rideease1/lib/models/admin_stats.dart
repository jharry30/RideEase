class AdminStats {
  final int totalUsers;
  final int totalRiders;
  final int totalDrivers;
  final int activeRides;
  final int completedRidesToday;
  final int cancelledRidesToday;
  final double todayRevenue;
  final int pendingVerifications;
  final int unresolvedDisputes;
  final int openTickets;

  AdminStats({
    required this.totalUsers,
    required this.totalRiders,
    required this.totalDrivers,
    required this.activeRides,
    required this.completedRidesToday,
    required this.cancelledRidesToday,
    required this.todayRevenue,
    required this.pendingVerifications,
    required this.unresolvedDisputes,
    required this.openTickets,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
    totalUsers: json['totalUsers'] ?? 0,
    totalRiders: json['totalRiders'] ?? 0,
    totalDrivers: json['totalDrivers'] ?? 0,
    activeRides: json['activeRides'] ?? 0,
    completedRidesToday: json['completedRidesToday'] ?? 0,
    cancelledRidesToday: json['cancelledRidesToday'] ?? 0,
    todayRevenue: (json['todayRevenue'] ?? 0).toDouble(),
    pendingVerifications: json['pendingVerifications'] ?? 0,
    unresolvedDisputes: json['unresolvedDisputes'] ?? 0,
    openTickets: json['openTickets'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'totalUsers': totalUsers,
    'totalRiders': totalRiders,
    'totalDrivers': totalDrivers,
    'activeRides': activeRides,
    'completedRidesToday': completedRidesToday,
    'cancelledRidesToday': cancelledRidesToday,
    'todayRevenue': todayRevenue,
    'pendingVerifications': pendingVerifications,
    'unresolvedDisputes': unresolvedDisputes,
    'openTickets': openTickets,
  };
}
