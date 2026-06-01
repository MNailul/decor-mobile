import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/api_service.dart';

class AddressProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<AddressModel> _addresses = [];
  bool _isLoading = false;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;

  AddressModel? get mainAddress {
    try {
      return _addresses.firstWhere((addr) => addr.isMain);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  Future<void> loadAddresses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.fetchAddresses();
      _addresses = data.map((json) => AddressModel.fromJson(json)).toList();
    } catch (e) {
      print("Load Addresses Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress(AddressModel address) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.createAddress(address.toJson());
      if (data != null) {
        final newAddress = AddressModel.fromJson(data);
        _addresses.add(newAddress);
        if (newAddress.isMain) {
          _setAllNotMainExcept(newAddress.id);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Add Address Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(AddressModel address) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.updateAddress(address.id, address.toJson());
      if (data != null) {
        final updatedAddress = AddressModel.fromJson(data);
        final index = _addresses.indexWhere((a) => a.id == updatedAddress.id);
        if (index != -1) {
          _addresses[index] = updatedAddress;
          if (updatedAddress.isMain) {
            _setAllNotMainExcept(updatedAddress.id);
          }
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Update Address Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(String id) async {
    try {
      final success = await _apiService.deleteAddress(id);
      if (success) {
        _addresses.removeWhere((a) => a.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Delete Address Error: $e");
      return false;
    }
  }

  Future<void> setMainAddress(String id) async {
    final index = _addresses.indexWhere((a) => a.id == id);
    if (index != -1) {
      final address = _addresses[index].copyWith(isMain: true);
      await updateAddress(address);
    }
  }

  void _setAllNotMainExcept(String id) {
    for (var addr in _addresses) {
      if (addr.id != id) {
        addr.isMain = false;
      }
    }
  }
}
