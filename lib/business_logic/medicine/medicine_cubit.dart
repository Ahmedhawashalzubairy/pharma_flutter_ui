import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/config/supabase_config.dart';
import '../../data/models/models.dart';

// States
abstract class MedicineState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MedicineInitial extends MedicineState {}

class MedicineLoading extends MedicineState {}

class MedicineLoaded extends MedicineState {
  final List<MedicineModel> medicines;
  final MedicineModel? selectedMedicine;
  final String? category;

  MedicineLoaded({
    required this.medicines,
    this.selectedMedicine,
    this.category,
  });

  @override
  List<Object?> get props => [medicines, selectedMedicine, category];

  MedicineLoaded copyWith({
    List<MedicineModel>? medicines,
    MedicineModel? selectedMedicine,
    String? category,
  }) {
    return MedicineLoaded(
      medicines: medicines ?? this.medicines,
      selectedMedicine: selectedMedicine ?? this.selectedMedicine,
      category: category ?? this.category,
    );
  }
}

class MedicineError extends MedicineState {
  final String message;

  MedicineError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class MedicineCubit extends Cubit<MedicineState> {
  MedicineCubit() : super(MedicineInitial());

  final _supabase = SupabaseConfig.client;

  // Load medicines by pharmacy
  Future<void> loadMedicinesByPharmacy(String pharmacyId) async {
    try {
      emit(MedicineLoading());

      final data = await _supabase
          .from(DbTables.medicines)
          .select()
          .eq('pharmacy_id', pharmacyId)
          .order('created_at', ascending: false);

      final medicines = (data as List)
          .map((medicine) => MedicineModel.fromJson(medicine))
          .toList();

      emit(MedicineLoaded(medicines: medicines));
    } catch (e) {
      emit(MedicineError('خطأ في تحميل الأدوية: ${e.toString()}'));
    }
  }

  // Load all medicines
  Future<void> loadAllMedicines() async {
    try {
      emit(MedicineLoading());

      final data = await _supabase
          .from(DbTables.medicines)
          .select()
          .order('created_at', ascending: false);

      final medicines = (data as List)
          .map((medicine) => MedicineModel.fromJson(medicine))
          .toList();

      emit(MedicineLoaded(medicines: medicines));
    } catch (e) {
      emit(MedicineError('خطأ في تحميل الأدوية: ${e.toString()}'));
    }
  }

  // Search medicines
  Future<void> searchMedicines(String query, {String? pharmacyId}) async {
    try {
      emit(MedicineLoading());

      var queryBuilder = _supabase
          .from(DbTables.medicines)
          .select()
          .ilike('name', '%$query%');

      if (pharmacyId != null) {
        queryBuilder = queryBuilder.eq('pharmacy_id', pharmacyId);
      }

      final data = await queryBuilder.order('created_at', ascending: false);

      final medicines = (data as List)
          .map((medicine) => MedicineModel.fromJson(medicine))
          .toList();

      emit(MedicineLoaded(medicines: medicines));
    } catch (e) {
      emit(MedicineError('خطأ في البحث: ${e.toString()}'));
    }
  }

  // Select medicine
  void selectMedicine(MedicineModel medicine) {
    final currentState = state;
    if (currentState is MedicineLoaded) {
      emit(currentState.copyWith(selectedMedicine: medicine));
    }
  }

  // Add medicine (Pharmacist only)
  Future<void> addMedicine({
    required String pharmacyId,
    required String name,
    String? composition,
    String? manufacturer,
    String? uses,
    String? sideEffects,
    String? imageUrl,
    DateTime? productionDate,
    DateTime? expirationDate,
    required int quantity,
    required double price,
  }) async {
    try {
      emit(MedicineLoading());

      final medicineData = {
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
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from(DbTables.medicines).insert(medicineData);

      await loadMedicinesByPharmacy(pharmacyId);
    } catch (e) {
      emit(MedicineError('خطأ في إضافة الدواء: ${e.toString()}'));
    }
  }

  // Update medicine quantity
  Future<void> updateMedicineQuantity({
    required String medicineId,
    required String pharmacyId,
    required int newQuantity,
  }) async {
    try {
      await _supabase
          .from(DbTables.medicines)
          .update({'quantity': newQuantity})
          .eq('id', medicineId);

      await loadMedicinesByPharmacy(pharmacyId);
    } catch (e) {
      emit(MedicineError('خطأ في تحديث الكمية: ${e.toString()}'));
    }
  }

  // Delete medicine
  Future<void> deleteMedicine(String medicineId, String pharmacyId) async {
    try {
      emit(MedicineLoading());

      await _supabase
          .from(DbTables.medicines)
          .delete()
          .eq('id', medicineId);

      await loadMedicinesByPharmacy(pharmacyId);
    } catch (e) {
      emit(MedicineError('خطأ في حذف الدواء: ${e.toString()}'));
    }
  }
}