import 'dart:convert';

AffiliateStats affiliateStatsFromJson(String str) =>
    AffiliateStats.fromJson(json.decode(str));

class AffiliateStats {
  final int? totalReferredUsers;
  final int? totalReferredOrders;
  final double? totalReferredSalesVolume;
  final double? totalCommissions;
  final double? pendingCommissions;
  final double? paidCommissions;

  const AffiliateStats({
    this.totalReferredUsers,
    this.totalReferredOrders,
    this.totalReferredSalesVolume,
    this.totalCommissions,
    this.pendingCommissions,
    this.paidCommissions,
  });

  factory AffiliateStats.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return AffiliateStats(
      totalReferredUsers: json['total_referred_users'] is int
          ? json['total_referred_users'] as int
          : int.tryParse(json['total_referred_users']?.toString() ?? ''),
      totalReferredOrders: json['total_referred_orders'] is int
          ? json['total_referred_orders'] as int
          : int.tryParse(json['total_referred_orders']?.toString() ?? ''),
      totalReferredSalesVolume:
          _toDouble(json['total_referred_sales_volume']),
      totalCommissions: _toDouble(json['total_commissions']),
      pendingCommissions: _toDouble(json['pending_commissions']),
      paidCommissions: _toDouble(json['paid_commissions']),
    );
  }
}


