import 'dart:convert';

import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/parcel_category_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';

class PaginatedOrderModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<OrderModel>? orders;

  PaginatedOrderModel({this.totalSize, this.limit, this.offset, this.orders});

  PaginatedOrderModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        orders!.add(OrderModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class OrderModel {
  int? id;
  int? userId;
  double? orderAmount;
  double? couponDiscountAmount;
  String? couponDiscountTitle;
  String? paymentStatus;
  String? orderStatus;
  double? totalTaxAmount;
  String? paymentMethod;
  String? couponCode;
  String? orderNote;
  String? orderType;
  String? createdAt;
  String? updatedAt;
  double? deliveryCharge;
  String? scheduleAt;
  String? otp;
  String? pending;
  String? accepted;
  String? confirmed;
  String? processing;
  String? handover;
  String? pickedUp;
  String? delivered;
  String? canceled;
  String? refundRequested;
  String? refunded;
  int? scheduled;
  double? storeDiscountAmount;
  String? failed;
  int? detailsCount;
  List<String?>? orderAttachment;
  String? chargePayer;
  String? moduleType;
  DeliveryMan? deliveryMan;
  Store? store;
  AddressModel? deliveryAddress;
  AddressModel? receiverDetails;
  ParcelCategoryModel? parcelCategory;
  double? dmTips;
  String? refundCancellationNote;
  String? refundCustomerNote;
  Refund? refund;
  bool? prescriptionOrder;
  bool? taxStatus;
  String? cancellationReason;
  int? processingTime;
  bool? cutlery;
  String? unavailableItemNote;
  String? deliveryInstruction;
  double? taxPercentage;

  OrderModel(
      {this.id,
        this.userId,
        this.orderAmount,
        this.couponDiscountAmount,
        this.couponDiscountTitle,
        this.paymentStatus,
        this.orderStatus,
        this.totalTaxAmount,
        this.paymentMethod,
        this.couponCode,
        this.orderNote,
        this.orderType,
        this.createdAt,
        this.updatedAt,
        this.deliveryCharge,
        this.scheduleAt,
        this.otp,
        this.pending,
        this.accepted,
        this.confirmed,
        this.processing,
        this.handover,
        this.pickedUp,
        this.delivered,
        this.canceled,
        this.refundRequested,
        this.refunded,
        this.scheduled,
        this.storeDiscountAmount,
        this.failed,
        this.detailsCount,
        this.chargePayer,
        this.moduleType,
        this.deliveryMan,
        this.deliveryAddress,
        this.receiverDetails,
        this.parcelCategory,
        this.store,
        this.orderAttachment,
        this.dmTips,
        this.refundCancellationNote,
        this.refundCustomerNote,
        this.refund,
        this.prescriptionOrder,
        this.taxStatus,
        this.cancellationReason,
        this.processingTime,
        this.cutlery,
        this.unavailableItemNote,
        this.deliveryInstruction,
        this.taxPercentage,
      });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderAmount = json['order_amount'].toDouble();
    couponDiscountAmount = json['coupon_discount_amount'].toDouble();
    couponDiscountTitle = json['coupon_discount_title'];
    paymentStatus = json['payment_status'];
    orderStatus = json['order_status'];
    totalTaxAmount = json['total_tax_amount'].toDouble();
    paymentMethod = json['payment_method'];
    couponCode = json['coupon_code'];
    orderNote = json['order_note'];
    orderType = json['order_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deliveryCharge = json['delivery_charge'].toDouble();
    scheduleAt = json['schedule_at'];
    otp = json['otp'];
    pending = json['pending'];
    accepted = json['accepted'];
    confirmed = json['confirmed'];
    processing = json['processing'];
    handover = json['handover'];
    pickedUp = json['picked_up'];
    delivered = json['delivered'];
    canceled = json['canceled'];
    refundRequested = json['refund_requested'];
    refunded = json['refunded'];
    scheduled = json['scheduled'];
    storeDiscountAmount = json['store_discount_amount'].toDouble();
    failed = json['failed'];
    detailsCount = json['details_count'];
    if (json['order_attachment'] != null) {
      if(json['order_attachment'].toString().startsWith('["')){
        orderAttachment = [];
        if(json['order_attachment'] is String) {
          jsonDecode(json['order_attachment']).forEach((v) {
            orderAttachment!.add(v);
          });
        }else {
          json['order_attachment'].forEach((v) {
            orderAttachment!.add(v);
          });
        }
      }else{
        orderAttachment = [];
        orderAttachment!.add(json['order_attachment']);
      }
    }
    chargePayer = json['charge_payer'];
    moduleType = json['module_type'];
    deliveryMan = json['delivery_man'] != null ? DeliveryMan.fromJson(json['delivery_man']) : null;
    store = json['store'] != null ? Store.fromJson(json['store']) : null;
    deliveryAddress = json['delivery_address'] != null ? AddressModel.fromJson(json['delivery_address']) : null;
    receiverDetails = json['receiver_details'] != null ? AddressModel.fromJson(json['receiver_details']) : null;
    parcelCategory = json['parcel_category'] != null ? ParcelCategoryModel.fromJson(json['parcel_category']) : null;
    dmTips = json['dm_tips'].toDouble();
    refundCancellationNote = json['refund_cancellation_note'];
    refundCustomerNote = json['refund_customer_note'];
    refund = json['refund'] != null ? Refund.fromJson(json['refund']) : null;
    prescriptionOrder = json['prescription_order'];
    taxStatus = json['tax_status'] == 'included' ? true : false;
    cancellationReason = json['cancellation_reason'];
    processingTime = json['processing_time'];
    cutlery = json['cutlery'];
    unavailableItemNote = json['unavailable_item_note'];
    deliveryInstruction = json['delivery_instruction'];
    taxPercentage = json['tax_percentage']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['order_amount'] = orderAmount;
    data['coupon_discount_amount'] = couponDiscountAmount;
    data['coupon_discount_title'] = couponDiscountTitle;
    data['payment_status'] = paymentStatus;
    data['order_status'] = orderStatus;
    data['total_tax_amount'] = totalTaxAmount;
    data['payment_method'] = paymentMethod;
    data['coupon_code'] = couponCode;
    data['order_note'] = orderNote;
    data['order_type'] = orderType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['delivery_charge'] = deliveryCharge;
    data['schedule_at'] = scheduleAt;
    data['otp'] = otp;
    data['pending'] = pending;
    data['accepted'] = accepted;
    data['confirmed'] = confirmed;
    data['processing'] = processing;
    data['handover'] = handover;
    data['picked_up'] = pickedUp;
    data['delivered'] = delivered;
    data['canceled'] = canceled;
    data['refund_requested'] = refundRequested;
    data['refunded'] = refunded;
    data['scheduled'] = scheduled;
    data['store_discount_amount'] = storeDiscountAmount;
    data['failed'] = failed;
    data['order_attachment'] = orderAttachment;
    data['charge_payer'] = chargePayer;
    data['module_type'] = moduleType;
    data['details_count'] = detailsCount;
    if (deliveryMan != null) {
      data['delivery_man'] = deliveryMan!.toJson();
    }
    if (store != null) {
      data['store'] = store!.toJson();
    }
    if (deliveryAddress != null) {
      data['delivery_address'] = deliveryAddress!.toJson();
    }
    if (receiverDetails != null) {
      data['receiver_details'] = receiverDetails!.toJson();
    }
    if (parcelCategory != null) {
      data['parcel_category'] = parcelCategory!.toJson();
    }
    data['dm_tips'] = dmTips;
    data['refund_cancellation_note'] = refundCancellationNote;
    data['refund_customer_note'] = refundCustomerNote;
    if (deliveryAddress != null) {
      data['refund'] = refund!.toJson();
    }
    data['prescription_order'] = prescriptionOrder;
    data['processing_time'] = processingTime;
    data['cutlery'] = cutlery;
    data['unavailable_item_note'] = unavailableItemNote;
    data['delivery_instruction'] = deliveryInstruction;
    return data;
  }
}

class DeliveryMan {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? image;
  int? zoneId;
  int? active;
  int? available;
  double? avgRating;
  int? ratingCount;
  String? lat;
  String? lng;
  String? location;

  DeliveryMan(
      {this.id,
        this.fName,
        this.lName,
        this.phone,
        this.email,
        this.image,
        this.zoneId,
        this.active,
        this.available,
        this.avgRating,
        this.ratingCount,
        this.lat,
        this.lng,
        this.location
      });

  DeliveryMan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    image = json['image'];
    zoneId = json['zone_id'];
    active = json['active'];
    available = json['available'];
    avgRating = json['avg_rating'].toDouble();
    ratingCount = json['rating_count'];
    lat = json['lat'];
    lng = json['lng'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image'] = image;
    data['zone_id'] = zoneId;
    data['active'] = active;
    data['available'] = available;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['lat'] = lat;
    data['lng'] = lng;
    data['location'] = location;
    return data;
  }
}
