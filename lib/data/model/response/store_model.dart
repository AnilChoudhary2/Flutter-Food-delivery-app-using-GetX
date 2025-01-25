import 'dart:convert';

class StoreModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<Store>? stores;

  StoreModel({this.totalSize, this.limit, this.offset, this.stores});

  StoreModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['stores'] != null) {
      stores = [];
      json['stores'].forEach((v) {
        stores!.add(Store.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (stores != null) {
      data['stores'] = stores!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Store {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? logo;
  String? latitude;
  String? longitude;
  String? address;
  double? minimumOrder;
  String? currency;
  bool? freeDelivery;
  String? coverPhoto;
  bool? delivery;
  bool? takeAway;
  bool? scheduleOrder;
  double? avgRating;
  double? tax;
  int? ratingCount;
  int? featured;
  int? zoneId;
  int? selfDeliverySystem;
  bool? posSystem;
  double? minimumShippingCharge;
  double? maximumShippingCharge;
  double? perKmShippingCharge;
  int? open;
  num? distance;
  bool? active;
  String? deliveryTime;
  List<int>? categoryIds;
  int? veg;
  int? nonVeg;
  int? moduleId;
  int? orderPlaceToScheduleInterval;
  Discount? discount;
  List<Schedules>? schedules;
  int? vendorId;
  bool? prescriptionOrder;
  bool? cutlery;

  Store(
      {this.id,
        this.name,
        this.phone,
        this.email,
        this.logo,
        this.latitude,
        this.longitude,
        this.address,
        this.minimumOrder,
        this.currency,
        this.freeDelivery,
        this.coverPhoto,
        this.delivery,
        this.takeAway,
        this.scheduleOrder,
        this.avgRating,
        this.tax,
        this.featured,
        this.zoneId,
        this.ratingCount,
        this.selfDeliverySystem,
        this.posSystem,
        this.minimumShippingCharge,
        this.maximumShippingCharge,
        this.perKmShippingCharge,
        this.open,
        this.distance,
        this.active,
        this.deliveryTime,
        this.categoryIds,
        this.veg,
        this.nonVeg,
        this.moduleId,
        this.orderPlaceToScheduleInterval,
        this.discount,
        this.schedules,
        this.vendorId,
        this.prescriptionOrder,
        this.cutlery,
      });

  Store.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    logo = json['logo'] ?? '';
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    minimumOrder = json['minimum_order'] == null ? 0 : json['minimum_order'].toDouble();
    currency = json['currency'];
    freeDelivery = json['free_delivery'];
    coverPhoto = json['cover_photo'] ?? '';
    delivery = json['delivery'];
    takeAway = json['take_away'];
    scheduleOrder = json['schedule_order'];
    avgRating = json['avg_rating'].toDouble();
    tax = json['tax']?.toDouble();
    ratingCount = json['rating_count'];
    selfDeliverySystem = json['self_delivery_system'];
    posSystem = json['pos_system'];
    minimumShippingCharge = json['minimum_shipping_charge'].toDouble();
    maximumShippingCharge = json['maximum_shipping_charge']?.toDouble();
    perKmShippingCharge = json['per_km_shipping_charge'] != null ? json['per_km_shipping_charge'].toDouble() : 0;
    open = json['open'];
    distance = json['distance'];
    active = json['active'];
    featured = int.parse(json['featured'].toString());
    zoneId = json['zone_id'];
    deliveryTime = json['delivery_time'];
    veg = json['veg'];
    nonVeg = json['non_veg'];
    moduleId = json['module_id'];
    orderPlaceToScheduleInterval = json['order_place_to_schedule_interval'];
    categoryIds = json['category_ids'] != null ? json['category_ids'].cast<int>() : [];
    discount = json['discount'] != null ? Discount.fromJson(json['discount']) : null;
    if (json['schedules'] != null) {
      schedules = <Schedules>[];
      json['schedules'].forEach((v) {
        schedules!.add(Schedules.fromJson(v));
      });
    }
    vendorId = json['vendor_id'];
    prescriptionOrder = json['prescription_order'] ?? false;
    cutlery = json['cutlery'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['logo'] = logo;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    data['minimum_order'] = minimumOrder;
    data['currency'] = currency;
    data['free_delivery'] = freeDelivery;
    data['cover_photo'] = coverPhoto;
    data['delivery'] = delivery;
    data['take_away'] = takeAway;
    data['schedule_order'] = scheduleOrder;
    data['avg_rating'] = avgRating;
    data['tax'] = tax;
    data['rating_count '] = ratingCount;
    data['self_delivery_system'] = selfDeliverySystem;
    data['pos_system'] = posSystem;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['maximum_shipping_charge'] = maximumShippingCharge;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['open'] = open;
    data['distance'] = distance;
    data['active'] = active;
    data['veg'] = veg;
    data['featured'] = featured;
    data['zone_id'] = zoneId;
    data['non_veg'] = nonVeg;
    data['module_id'] = moduleId;
    data['order_place_to_schedule_interval'] = orderPlaceToScheduleInterval;
    data['delivery_time'] = deliveryTime;
    data['category_ids'] = categoryIds;
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    if (schedules != null) {
      data['schedules'] = schedules!.map((v) => v.toJson()).toList();
    }
    data['vendor_id'] = vendorId;
    data['prescription_order'] = prescriptionOrder;
    data['cutlery'] = cutlery;
    return data;
  }
}

class Discount {
  int? id;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  double? minPurchase;
  double? maxDiscount;
  double? discount;
  String? discountType;
  int? storeId;
  String? createdAt;
  String? updatedAt;

  Discount(
      {this.id,
        this.startDate,
        this.endDate,
        this.startTime,
        this.endTime,
        this.minPurchase,
        this.maxDiscount,
        this.discount,
        this.discountType,
        this.storeId,
        this.createdAt,
        this.updatedAt});

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    startTime = json['start_time']?.substring(0, 5);
    endTime = json['end_time']?.substring(0, 5);
    minPurchase = json['min_purchase'].toDouble();
    maxDiscount = json['max_discount'].toDouble();
    discount = json['discount'].toDouble();
    discountType = json['discount_type'];
    storeId = json['store_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['store_id'] = storeId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Schedules {
  int? id;
  int? storeId;
  int? day;
  String? openingTime;
  String? closingTime;

  Schedules(
      {this.id,
        this.storeId,
        this.day,
        this.openingTime,
        this.closingTime});

  Schedules.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    day = json['day'];
    openingTime = json['opening_time'].substring(0, 5);
    closingTime = json['closing_time'].substring(0, 5);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['store_id'] = storeId;
    data['day'] = day;
    data['opening_time'] = openingTime;
    data['closing_time'] = closingTime;
    return data;
  }
}

class Refund {
  int? id;
  int? orderId;
  List<String>? image;
  String? customerReason;
  String? customerNote;
  String? adminNote;

  Refund(
      {this.id,
        this.orderId,
        this.image,
        this.customerReason,
        this.customerNote,
        this.adminNote,
      });

  Refund.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    if(json['image'] != null){
      image = [];
      jsonDecode(json['image']).forEach((v) => image!.add(v));
    }
    customerReason = json['customer_reason'];
    customerNote = json['customer_note'];
    adminNote = json['admin_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['image'] = image;
    data['customer_reason'] = customerReason;
    data['customer_note'] = customerNote;
    data['admin_note'] = adminNote;
    return data;
  }
}