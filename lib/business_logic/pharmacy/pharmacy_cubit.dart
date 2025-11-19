import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/config/supabase_config.dart';
import '../../data/models/models.dart';

// States
abstract class PharmacyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PharmacyInitial extends PharmacyState {}

class PharmacyLoading extends PharmacyState {}

class PharmacyLoaded extends PharmacyState {
  final List<PharmacyModel> pharmacies;
  final PharmacyModel? selectedPharmacy;
  final List<BranchModel> branches;

  PharmacyLoaded({
    required this.pharmacies,
    this.selectedPharmacy,
    this.branches = const [],
  });

  @override
  List<Object?> get props => [pharmacies, selectedPharmacy, branches];

  PharmacyLoaded copyWith({
    List<PharmacyModel>? pharmacies,
    PharmacyModel? selectedPharmacy,
    List<BranchModel>? branches,
  }) {
    return PharmacyLoaded(
      pharmacies: pharmacies ?? this.pharmacies,
      selectedPharmacy: selectedPharmacy ?? this.selectedPharmacy,
      branches: branches ?? this.branches,
    );
  }
}

class PharmacyError extends PharmacyState {
  final String message;

  PharmacyError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class PharmacyCubit extends Cubit<PharmacyState> {
  PharmacyCubit() : super(PharmacyInitial());

  final _supabase = SupabaseConfig.client;

  // Load all pharmacies
  Future<void> loadPharmacies() async {
    try {
      emit(PharmacyLoading());

      final data = await _supabase
          .from(DbTables.pharmacies)
          .select()
          .order('created_at', ascending: false);

      final pharmacies = (data as List)
          .map((pharmacy) => PharmacyModel.fromJson(pharmacy))
          .toList();

      emit(PharmacyLoaded(pharmacies: pharmacies));
    } catch (e) {
      emit(PharmacyError('خطأ في تحميل الصيدليات: ${e.toString()}'));
    }
  }

  // Select pharmacy and load its branches
  Future<void> selectPharmacy(PharmacyModel pharmacy) async {
    try {
      final currentState = state;
      if (currentState is! PharmacyLoaded) return;

      emit(PharmacyLoading());

      final branchesData = await _supabase
          .from(DbTables.branches)
          .select()
          .eq('pharmacy_id', pharmacy.id)
          .order('is_main_branch', ascending: false);

      final branches = (branchesData as List)
          .map((branch) => BranchModel.fromJson(branch))
          .toList();

      emit(currentState.copyWith(
        selectedPharmacy: pharmacy,
        branches: branches,
      ));
    } catch (e) {
      emit(PharmacyError('خطأ في تحميل فروع الصيدلية: ${e.toString()}'));
    }
  }

  // Add pharmacy (Admin only)
  Future<void> addPharmacy({
    required String name,
    required String idNumber,
    required String phoneNumber,
    String? logoUrl,
  }) async {
    try {
      emit(PharmacyLoading());

      final pharmacyData = {
        'name': name,
        'id_number': idNumber,
        'phone_number': phoneNumber,
        'logo_url': logoUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from(DbTables.pharmacies).insert(pharmacyData);

      await loadPharmacies();
    } catch (e) {
      emit(PharmacyError('خطأ في إضافة الصيدلية: ${e.toString()}'));
    }
  }

  // Add branch (Admin only)
  Future<void> addBranch({
    required String pharmacyId,
    required String supervisorName,
    required String idSupervisor,
    required String branchNumber,
    required String branchAddress,
    required bool isMainBranch,
  }) async {
    try {
      emit(PharmacyLoading());

      final branchData = {
        'pharmacy_id': pharmacyId,
        'supervisor_name': supervisorName,
        'id_supervisor': idSupervisor,
        'branch_number': branchNumber,
        'branch_address': branchAddress,
        'is_main_branch': isMainBranch,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from(DbTables.branches).insert(branchData);

      // Reload pharmacies
      await loadPharmacies();
    } catch (e) {
      emit(PharmacyError('خطأ في إضافة الفرع: ${e.toString()}'));
    }
  }

  // Search pharmacies
  Future<void> searchPharmacies(String query) async {
    try {
      emit(PharmacyLoading());

      final data = await _supabase
          .from(DbTables.pharmacies)
          .select()
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);

      final pharmacies = (data as List)
          .map((pharmacy) => PharmacyModel.fromJson(pharmacy))
          .toList();

      emit(PharmacyLoaded(pharmacies: pharmacies));
    } catch (e) {
      emit(PharmacyError('خطأ في البحث: ${e.toString()}'));
    }
  }
}