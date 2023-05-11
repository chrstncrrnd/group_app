List<String> toListString(dynamic input) {
  if (input == null) {
    return [];
  }
  return (input as List<dynamic>).map((e) => e.toString()).toList();
}
