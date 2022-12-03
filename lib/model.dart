const String tableDetails = 'details';

class DetailsFields {
  static final List<String> values = [
    id,
    firstName,
    lastName,
    gender,
    age,
  ];
  static const String id = '_id';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String gender = 'gender';
  static const String age = 'age';
}

class Details {
  final int? id;
  final String firstName;
  final String lastName;
  final String gender;
  final int age;

  const Details({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
  });

  Details copy(
          {int? id,
          String? firstName,
          String? lastName,
          String? gender,
          int? age}) =>
      Details(
          id: id ?? this.id,
          firstName: firstName ?? this.firstName,
          lastName: lastName ?? this.lastName,
          gender: gender ?? this.gender,
          age: age ?? this.age);

  static Details fromJson(Map<String, Object?> json) => Details(
        id: json[DetailsFields.id] as int?,
        firstName: json[DetailsFields.firstName] as String,
        lastName: json[DetailsFields.lastName] as String,
        gender: json[DetailsFields.gender] as String,
        age: json[DetailsFields.age] as int,
      );

  Map<String, Object?> toJson() => {
        DetailsFields.id: id,
        DetailsFields.firstName: firstName,
        DetailsFields.lastName: lastName,
        DetailsFields.gender: gender,
        DetailsFields.age: age,
      };
}
