// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverModel _$DriverModelFromJson(Map<String, dynamic> json) => DriverModel(
  id: json['id'] as String,
  restaurantId: json['restaurant_id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  photoUrl: json['photo_url'] as String?,
  vehicleType: json['vehicle_type'] as String,
  licensePlate: json['license_plate'] as String,
  status: json['status'] as String,
  isOnline: json['is_online'] as bool,
  isOnDelivery: json['is_on_delivery'] as bool,
  createdAt: json['created_at'] as String,
  totalDeliveries: (json['total_deliveries'] as num?)?.toInt() ?? 0,
  ratingSum: (json['rating_sum'] as num?)?.toInt() ?? 0,
  ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
  averageRating: (json['average_rating'] as num?)?.toDouble(),
  totalEarningsCents: (json['total_earnings_cents'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DriverModelToJson(DriverModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'restaurant_id': instance.restaurantId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'photo_url': instance.photoUrl,
      'vehicle_type': instance.vehicleType,
      'license_plate': instance.licensePlate,
      'status': instance.status,
      'is_online': instance.isOnline,
      'is_on_delivery': instance.isOnDelivery,
      'created_at': instance.createdAt,
      'total_deliveries': instance.totalDeliveries,
      'rating_sum': instance.ratingSum,
      'rating_count': instance.ratingCount,
      'average_rating': instance.averageRating,
      'total_earnings_cents': instance.totalEarningsCents,
    };
