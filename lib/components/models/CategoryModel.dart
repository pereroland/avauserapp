class CategoryModel {
  final String id, name;

  CategoryModel._({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return new CategoryModel._(id: json['id'], name: json['name']);
  }
}
