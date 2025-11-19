import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/config/supabase_config.dart';
import '../../data/models/models.dart';
import 'dart:math';

// States
abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> orders;
  final OrderModel? selectedOrder;

  OrderLoaded({
    required this.orders,
    this.selectedOrder,
  });

  @override
  List<Object?> get props => [orders, selectedOrder];

  OrderLoaded copyWith({
    List<OrderModel>? orders,
    OrderModel? selectedOrder,
  }) {
    return OrderLoaded(
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
    );
  }
}

class OrderCreated extends OrderState {
  final OrderModel order;

  OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial());

  final _supabase = SupabaseConfig.client;

  // Load user orders
  Future<void> loadUserOrders(String userId) async {
    try {
      emit(OrderLoading());

      final data = await _supabase
          .from(DbTables.orders)
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('order_date', ascending: false);

      final orders = (data as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();

      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError('خطأ في تحميل الطلبات: ${e.toString()}'));
    }
  }

  // Load pharmacy orders (for pharmacist)
  Future<void> loadPharmacyOrders(String pharmacyId) async {
    try {
      emit(OrderLoading());

      final data = await _supabase
          .from(DbTables.orders)
          .select('*, order_items(*)')
          .eq('pharmacy_id', pharmacyId)
          .order('order_date', ascending: false);

      final orders = (data as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();

      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError('خطأ في تحميل الطلبات: ${e.toString()}'));
    }
  }

  // Select order
  void selectOrder(OrderModel order) {
    final currentState = state;
    if (currentState is OrderLoaded) {
      emit(currentState.copyWith(selectedOrder: order));
    }
  }

  // Create order from cart
  Future<void> createOrder({
    required String userId,
    required String pharmacyId,
    required String orderName,
    required double orderPrice,
    required double deliveryFee,
    required String customerAddress,
    required List<CartItemModel> cartItems,
    String? phoneNumberCustomer,
  }) async {
    try {
      emit(OrderLoading());

      // Generate order number
      final orderNumber = _generateOrderNumber();
      final totalPrice = orderPrice + deliveryFee;

      // Create order
      final orderData = {
        'user_id': userId,
        'pharmacy_id': pharmacyId,
        'order_name': orderName,
        'order_price': orderPrice,
        'delivery_fee': deliveryFee,
        'total_price': totalPrice,
        'order_date': DateTime.now().toIso8601String(),
        'order_number': orderNumber,
        'customer_address': customerAddress,
        'status': OrderStatus.inProcess.name,
        'phone_number_customer': phoneNumberCustomer,
      };

      final orderResponse = await _supabase
          .from(DbTables.orders)
          .insert(orderData)
          .select()
          .single();

      final orderId = orderResponse['id'];

      // Create order items
      final orderItems = cartItems.map((item) => {
        'order_id': orderId,
        'medicine_id': item.medicineId,
        'quantity': item.quantity,
        'price': item.medicine?.price ?? 0,
      }).toList();

      await _supabase.from(DbTables.orderItems).insert(orderItems);

      // Clear cart
      await _supabase
          .from(DbTables.cart)
          .delete()
          .eq('user_id', userId);

      final order = OrderModel.fromJson(orderResponse);
      emit(OrderCreated(order));
    } catch (e) {
      emit(OrderError('خطأ في إنشاء الطلب: ${e.toString()}'));
    }
  }

  // Update order status (for pharmacist)
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    required String pharmacyId,
  }) async {
    try {
      emit(OrderLoading());

      await _supabase
          .from(DbTables.orders)
          .update({'status': newStatus.name})
          .eq('id', orderId);

      await loadPharmacyOrders(pharmacyId);
    } catch (e) {
      emit(OrderError('خطأ في تحديث حالة الطلب: ${e.toString()}'));
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId, String userId) async {
    try {
      emit(OrderLoading());

      await _supabase
          .from(DbTables.orders)
          .delete()
          .eq('id', orderId);

      await loadUserOrders(userId);
    } catch (e) {
      emit(OrderError('خطأ في إلغاء الطلب: ${e.toString()}'));
    }
  }

  // Generate unique order number
  String _generateOrderNumber() {
    final random = Random();
    final number = 10000 + random.nextInt(90000);
    return number.toString();
  }

  // Get order status text in Arabic
  String getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.inProcess:
        return 'قيد المعالجة';
      case OrderStatus.beingPrepared:
        return 'يتم تجهيزه';
      case OrderStatus.onTheWayToYou:
        return 'في الطريق إليك';
      case OrderStatus.deliveryCompleted:
        return 'تم التسليم';
    }
  }
}