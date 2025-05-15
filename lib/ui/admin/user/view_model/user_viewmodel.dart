import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/manage_user_service.dart';
import 'package:mycrochetbag/domain/model/User.dart';
import 'package:mycrochetbag/utils/result.dart';

enum ViewState { idle, loading, error }

class UserViewModel extends ChangeNotifier {
  final ManageUserService _userService;

  List<User> _users = [];
  User? _selectedUser;
  String? _errorMessage;
  ViewState _state = ViewState.idle;

  UserViewModel({required ManageUserService userService})
    : _userService = userService;

  // Getters
  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  String? get errorMessage => _errorMessage;
  ViewState get state => _state;
  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;

  // Set state and notify listeners
  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  // Set error message and error state
  void _setError(String message) {
    _errorMessage = message;
    _setState(ViewState.error);
  }

  // Fetch all users
  Future<void> fetchUsers() async {
    _setState(ViewState.loading);

    final result = await _userService.getAllUsers();

    switch (result) {
      case Ok():
        _users = result.asOk.value;
        _setState(ViewState.idle);
      case Error():
        _setError(result.asError.error.toString());
    }
  }

  // Fetch user by ID
  Future<void> fetchUserById(String id) async {
    _setState(ViewState.loading);

    final result = await _userService.getUserDetails(id);

    switch (result) {
      case Ok():
        _selectedUser = result.asOk.value;
        _setState(ViewState.idle);
      case Error():
        _setError(result.asError.error.toString());
    }
  }

  // Create new user
  Future<bool> createUser(User user) async {
    _setState(ViewState.loading);

    final result = await _userService.addUser(user);

    switch (result) {
      case Ok():
        // Add the new user to the list if we have a list already loaded
        if (_users.isNotEmpty) {
          _users.add(result.asOk.value);
          notifyListeners();
        }
        _setState(ViewState.idle);
        return true;
      case Error():
        _setError(result.asError.error.toString());
        return false;
    }
  }

  // Update existing user
  Future<bool> updateUser(User user) async {
    _setState(ViewState.loading);

    final result = await _userService.editUser(user);

    switch (result) {
      case Ok():
        // Update local list if it's already loaded
        if (_users.isNotEmpty) {
          final index = _users.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            _users[index] = user;
          }
        }

        if (_selectedUser?.id == user.id) {
          _selectedUser = user;
        }

        _setState(ViewState.idle);
        return true;
      case Error():
        _setError(result.asError.error.toString());
        return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String? id) async {
    _setState(ViewState.loading);

    final result = await _userService.removeUser(id!);

    switch (result) {
      case Ok():
        // Remove from local list if it's already loaded
        if (_users.isNotEmpty) {
          _users.removeWhere((user) => user.id == id);
        }

        if (_selectedUser?.id == id) {
          _selectedUser = null;
        }

        _setState(ViewState.idle);
        return true;
      case Error():
        _setError(result.asError.error.toString());
        return false;
    }
  }

  // Clear selected user
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  // Clear error state
  void clearError() {
    _errorMessage = null;
    if (_state == ViewState.error) {
      _setState(ViewState.idle);
    }
  }
}
