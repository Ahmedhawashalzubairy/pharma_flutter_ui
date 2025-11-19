import 'package:equatable/equatable.dart';

// User Model
class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? region;
  final String? address;
  final String gender;
  final UserRole role;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.region,
    this.address,
    required this.gender,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      region: json['region'],
      address: json['address'],
      gender: json['gender'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'region': region,
      'address': address,
      'gender': gender,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phoneNumber,
        region,
        address,
        gender,
        role,
        createdAt,
      ];
}

enum UserRole { customer, pharmacist, admin }

// Pharmacy Model
class PharmacyModel extends Equatable {
  final String id;
  final String name;
  final String? idNumber;
  final String? phoneNumber;
  final String? logoUrl;
  final DateTime createdAt;

  const PharmacyModel({
    required this.id,
    required this.name,
    this.idNumber,
    this.phoneNumber,
    this.logoUrl,
    required this.createdAt,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    return PharmacyModel(
      id: json['id'],
      name: json['name'],
      idNumber: json['id_number'],
      phoneNumber: json['phone_number'],
      logoUrl: json['logo_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'id_number': idNumber,
      'phone_number': phoneNumber,
      'logo_url': logoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, idNumber, phoneNumber, logoUrl, createdAt];
}

// Branch Model
class BranchModel extends Equatable {
  final String id;
  final String pharmacyId;
  final String supervisorName;
  final String idSupervisor;
  final String branchNumber;
  final String branchAddress;
  final bool isMainBranch;
  final DateTime createdAt;

  const BranchModel({
    required this.id,
    required this.pharmacyId,
    required this.supervisorName,
    required this.idSupervisor,
    required this.branchNumber,
    required this.branchAddress,
    required this.isMainBranch,
    required this.createdAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'],
      pharmacyId: json['pharmacy_id'],
      supervisorName: json['supervisor_name'],
      idSupervisor: json['id_supervisor'],
      branchNumber: json['branch_number'],
      branchAddress: json['branch_address'],
      isMainBranch: json['is_main_branch'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pharmacy_id': pharmacyId,
      'supervisor_name': supervisorName,
      'id_supervisor': idSupervisor,
      'branch_number': branchNumber,
      'branch_address': branchAddress,
      'is_main_branch': isMainBranch,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        pharmacyId,
        supervisorName,
        idSupervisor,
        branchNumber,
        branchAddress,
        isMainBranch,
        createdAt,
      ];
}

// Medicine Model
class MedicineModel extends Equatable {
  final String id;
  final String pharmacyId;
  final String name;
  final String? composition;
  final String? manufacturer;
  final String? uses;
  final String? sideEffects;
  final String? imageUrl;
  final DateTime? productionDate;
  final DateTime? expirationDate;
  final int quantity;
  final double price;
  final DateTime createdAt;

  const MedicineModel({
    required this.id,
    required this.pharmacyId,
    required this.name,
    this.composition,
    this.manufacturer,
    this.uses,
    this.sideEffects,
    this.imageUrl,
    this.productionDate,
    this.expirationDate,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'],
      pharmacyId: json['pharmacy_id'],
      name: json['name'],
      composition: json['composition'],
      manufacturer: json['manufacturer'],
      uses: json['uses'],
      sideEffects: json['side_effects'],
      imageUrl: json['image_url'],
      productionDate: json['production_date'] != null
          ? DateTime.parse(json['production_date'])
          : null,
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'])
          : null,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pharmacy_id': pharmacyId,
      'name': name,
      'composition': composition,
      'manufacturer': manufacturer,
      'uses': uses,
      'side_effects': sideEffects,
      'image_url': imageUrl,
      'production_date': productionDate?.toIso8601String(),
      'expiration_date': expirationDate?.toIso8601String(),
      'quantity': quantity,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        pharmacyId,
        name,
        composition,
        manufacturer,
        uses,
        sideEffects,
        imageUrl,
        productionDate,
        expirationDate,
        quantity,
        price,
        createdAt,
      ];
}

// Order Model
class OrderModel extends Equatable {
  final String id;
  final String userId;
  final String pharmacyId;
  final String orderName;
  final double orderPrice;
  final double deliveryFee;
  final double totalPrice;
  final DateTime orderDate;
  final String orderNumber;
  final String customerAddress;
  final OrderStatus status;
  final String? phoneNumberDelivery;
  final String? phoneNumberCustomer;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.pharmacyId,
    required this.orderName,
    required this.orderPrice,
    required this.deliveryFee,
    required this.totalPrice,
    required this.orderDate,
    required this.orderNumber,
    required this.customerAddress,
    required this.status,
    this.phoneNumberDelivery,
    this.phoneNumberCustomer,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      pharmacyId: json['pharmacy_id'],
      orderName: json['order_name'],
      orderPrice: (json['order_price'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      orderDate: DateTime.parse(json['order_date']),
      orderNumber: json['order_number'],
      customerAddress: json['customer_address'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.inProcess,
      ),
      phoneNumberDelivery: json['phone_number_delivery'],
      phoneNumberCustomer: json['phone_number_customer'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItemModel.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pharmacy_id': pharmacyId,
      'order_name': orderName,
      'order_price': orderPrice,
      'delivery_fee': deliveryFee,
      'total_price': totalPrice,
      'order_date': orderDate.toIso8601String(),
      'order_number': orderNumber,
      'customer_address': customerAddress,
      'status': status.name,
      'phone_number_delivery': phoneNumberDelivery,
      'phone_number_customer': phoneNumberCustomer,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        pharmacyId,
        orderName,
        orderPrice,
        deliveryFee,
        totalPrice,
        orderDate,
        orderNumber,
        customerAddress,
        status,
        phoneNumberDelivery,
        phoneNumberCustomer,
        items,
      ];
}

enum OrderStatus {
  inProcess,
  beingPrepared,
  onTheWayToYou,
  deliveryCompleted,
}

// Order Item Model
class OrderItemModel extends Equatable {
  final String id;
  final String orderId;
  final String medicineId;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.medicineId,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      orderId: json['order_id'],
      medicineId: json['medicine_id'],
      quantity: json['quantity'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'medicine_id': medicineId,
      'quantity': quantity,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [id, orderId, medicineId, quantity, price];
}

// Cart Item Model
class CartItemModel extends Equatable {
  final String id;
  final String userId;
  final String medicineId;
  final int quantity;
  final MedicineModel? medicine;

  const CartItemModel({
    required this.id,
    required this.userId,
    required this.medicineId,
    required this.quantity,
    this.medicine,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      userId: json['user_id'],
      medicineId: json['medicine_id'],
      quantity: json['quantity'],
      medicine: json['medicine'] != null
          ? MedicineModel.fromJson(json['medicine'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'medicine_id': medicineId,
      'quantity': quantity,
    };
  }

  @override
  List<Object?> get props => [id, userId, medicineId, quantity, medicine];
}