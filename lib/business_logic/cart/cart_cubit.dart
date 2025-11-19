import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/config/supabase_config.dart';
import '../../data/models/models.dart';

// States
abstract class CartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final double totalPrice;

  CartLoaded({
    required this.items,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [items, totalPrice];

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class CartError extends CartState {
  final String message;

  CartError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  final _supabase = SupabaseConfig.client;

  // Load cart items
  Future<void> loadCart(String userId) async {
    try {
      emit(CartLoading());

      final data = await _supabase
          .from(DbTables.cart)
          .select('*, medicine:medicines(*)')
          .eq('user_id', userId);

      final items = (data as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList();

      final totalPrice = items.fold<double>(
        0.0,
        (sum, item) => sum + (item.medicine?.price ?? 0) * item.quantity,
      );

      emit(CartLoaded(items: items, totalPrice: totalPrice));
    } catch (e) {
      emit(CartError('خطأ في تحميل السلة: ${e.toString()}'));
    }
  }

  // Add item to cart
  Future<void> addToCart({
    required String userId,
    required String medicineId,
    int quantity = 1,
  }) async {
    try {
    //  final currentState = state;
      emit(CartLoading());

      // Check if item already exists
      final existing = await _supabase
          .from(DbTables.cart)
          .select()
          .eq('user_id', userId)
          .eq('medicine_id', medicineId)
          .maybeSingle();

      if (existing != null) {
        // Update quantity
        final newQuantity = (existing['quantity'] as int) + quantity;
        await _supabase
            .from(DbTables.cart)
            .update({'quantity': newQuantity})
            .eq('id', existing['id']);
      } else {
        // Insert new item
        await _supabase.from(DbTables.cart).insert({
          'user_id': userId,
          'medicine_id': medicineId,
          'quantity': quantity,
        });
      }

      await loadCart(userId);
    } catch (e) {
      emit(CartError('خطأ في إضافة المنتج: ${e.toString()}'));
    }
  }

  // Update item quantity
  Future<void> updateQuantity({
    required String userId,
    required String cartItemId,
    required int newQuantity,
  }) async {
    try {
      emit(CartLoading());

      if (newQuantity <= 0) {
        await _supabase
            .from(DbTables.cart)
            .delete()
            .eq('id', cartItemId);
      } else {
        await _supabase
            .from(DbTables.cart)
            .update({'quantity': newQuantity})
            .eq('id', cartItemId);
      }

      await loadCart(userId);
    } catch (e) {
      emit(CartError('خطأ في تحديث الكمية: ${e.toString()}'));
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String userId, String cartItemId) async {
    try {
      emit(CartLoading());

      await _supabase
          .from(DbTables.cart)
          .delete()
          .eq('id', cartItemId);

      await loadCart(userId);
    } catch (e) {
      emit(CartError('خطأ في حذف المنتج: ${e.toString()}'));
    }
  }

  // Clear cart
  Future<void> clearCart(String userId) async {
    try {
      emit(CartLoading());

      await _supabase
          .from(DbTables.cart)
          .delete()
          .eq('user_id', userId);

      emit(CartLoaded(items: [], totalPrice: 0.0));
    } catch (e) {
      emit(CartError('خطأ في مسح السلة: ${e.toString()}'));
    }
  }

  // Calculate total with delivery fee
  double calculateTotalWithDelivery(double deliveryFee) {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.totalPrice + deliveryFee;
    }
    return 0.0;
  }
}