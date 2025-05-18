class GetNameInitials {
  const GetNameInitials();

  static String getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';

    final firstInitial = parts.isNotEmpty ? parts[0][0] : '';
    final secondInitial = parts.length > 1 ? parts[1][0] : '';

    return (firstInitial + secondInitial).toUpperCase();
  }
}
