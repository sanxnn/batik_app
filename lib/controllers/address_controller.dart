import 'package:flutter/material.dart';

import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressController extends ChangeNotifier {
  final AddressService _service = AddressService();

  List<AddressModel> _addresses = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<AddressModel> get addresses => _addresses;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  void clearLocal() {
    _addresses = [];
    _errorMessage = null;
    notifyListeners();
  }

  AddressModel? get primaryAddress {
    try {
      return _addresses.firstWhere((e) => e.isPrimary);
    } catch (_) {
      return null;
    }
  }

  // Mengambil semua alamat
  Future<void> fetchAddresses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.getAddresses();

    if (result.isSuccess) {
      _addresses = result.data!;
    } else {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Menambahkan alamat
  Future<bool> createAddress(Map<String, dynamic> data) async {
    _isSaving = true;
    notifyListeners();

    final result = await _service.createAddress(data);

    _isSaving = false;

    if (result.isSuccess) {
      await fetchAddresses();
      return true;
    }

    _errorMessage = result.message;
    notifyListeners();
    return false;
  }

  // Mengedit alamat
  Future<bool> updateAddress(int id, Map<String, dynamic> data) async {
    _isSaving = true;
    notifyListeners();

    final result = await _service.updateAddress(id, data);

    _isSaving = false;

    if (result.isSuccess) {
      await fetchAddresses();
      return true;
    }

    _errorMessage = result.message;
    notifyListeners();
    return false;
  }

  // Menghapus alamat
  Future<bool> deleteAddress(int id) async {
    final result = await _service.deleteAddress(id);

    if (result.isSuccess) {
      await fetchAddresses();
      return true;
    }

    _errorMessage = result.message;
    notifyListeners();
    return false;
  }

  // Mengubah alamat utama
  Future<bool> setPrimary(int id) async {
    final result = await _service.setPrimary(id);

    if (result.isSuccess) {
      await fetchAddresses();
      return true;
    }

    _errorMessage = result.message;
    notifyListeners();
    return false;
  }
}
