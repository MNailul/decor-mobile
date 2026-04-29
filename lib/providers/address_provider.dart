import 'package:flutter/material.dart';
import '../models/address_model.dart';

class AddressProvider extends ChangeNotifier {
  final List<AddressModel> _addresses = [
    AddressModel(
      id: 'default-1',
      name: 'Home',
      recipientName: 'Jane Doe',
      phoneNumber: '+1 (555) 123-4567',
      fullAddress: '123 Minimalist Avenue, Suite 4B\nNew York, NY 10001',
      isMain: true,
    ),
  ];

  List<AddressModel> get addresses => _addresses;

  AddressModel? get mainAddress {
    try {
      return _addresses.firstWhere((addr) => addr.isMain);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  void addAddress(AddressModel address) {
    if (address.isMain || _addresses.isEmpty) {
      _setAllNotMain();
      address.isMain = true;
    }
    _addresses.add(address);
    notifyListeners();
  }

  void updateAddress(AddressModel address) {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      if (address.isMain) {
        _setAllNotMain();
      }
      _addresses[index] = address;
      // If we accidentally set the only address to not main, fix it
      if (_addresses.where((a) => a.isMain).isEmpty && _addresses.isNotEmpty) {
        _addresses.first.isMain = true;
      }
      notifyListeners();
    }
  }

  void deleteAddress(String id) {
    final address = _addresses.firstWhere((a) => a.id == id);
    _addresses.removeWhere((a) => a.id == id);
    if (address.isMain && _addresses.isNotEmpty) {
      _addresses.first.isMain = true;
    }
    notifyListeners();
  }

  void setMainAddress(String id) {
    _setAllNotMain();
    final index = _addresses.indexWhere((a) => a.id == id);
    if (index != -1) {
      _addresses[index].isMain = true;
    }
    notifyListeners();
  }

  void _setAllNotMain() {
    for (var addr in _addresses) {
      addr.isMain = false;
    }
  }
}
