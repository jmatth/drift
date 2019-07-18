import 'dart:typed_data' show Uint8List;
import 'package:meta/meta.dart';
import 'package:moor/moor.dart';

/// Subclasses represent a table in a database generated by moor.
abstract class Table {
  /// Defines a table to be used with moor.
  const Table();

  /// The sql table name to be used. By default, moor will use the snake_case
  /// representation of your class name as the sql table name. For instance, a
  /// [Table] class named `LocalSettings` will be called `local_settings` by
  /// default.
  /// You can change that behavior by overriding this method to use a custom
  /// name. Please note that you must directly return a string literal by using
  /// a getter. For instance `@override String get tableName => 'my_table';` is
  /// valid, whereas `@override final String tableName = 'my_table';` or
  /// `@override String get tableName => createMyTableName();` is not.
  @visibleForOverriding
  String get tableName => null;

  /// Override this to specify custom primary keys:
  /// ```dart
  /// class IngredientInRecipes extends Table {
  ///  @override
  ///  Set<Column> get primaryKey => {recipe, ingredient};
  ///
  ///  IntColumn get recipe => integer()();
  ///  IntColumn get ingredient => integer()();
  ///
  ///  IntColumn get amountInGrams => integer().named('amount')();
  ///}
  /// ```
  /// The getter must return a set literal using the `=>` syntax so that the
  /// moor generator can understand the code.
  /// Also, please not that it's an error to have a
  /// [IntColumnBuilder.autoIncrement] column and a custom primary key.
  /// Writing such table in sql will throw at runtime.
  @visibleForOverriding
  Set<Column> get primaryKey => null;

  /// Custom table constraints that should be added to the table.
  ///
  /// See also:
  ///  - https://www.sqlite.org/syntax/table-constraint.html, which defines what
  ///    table constraints are supported.
  @visibleForOverriding
  List<String> get customConstraints => [];

  /// Use this as the body of a getter to declare a column that holds integers.
  /// Example (inside the body of a table class):
  /// ```
  /// IntColumn get id => integer().autoIncrement()();
  /// ```
  @protected
  IntColumnBuilder integer() => null;

  /// Use this as the body of a getter to declare a column that holds strings.
  /// Example (inside the body of a table class):
  /// ```
  /// TextColumn get name => text()();
  /// ```
  @protected
  TextColumnBuilder text() => null;

  /// Use this as the body of a getter to declare a column that holds bools.
  /// Example (inside the body of a table class):
  /// ```
  /// BoolColumn get isAwesome => boolean()();
  /// ```
  @protected
  BoolColumnBuilder boolean() => null;

  /// Use this as the body of a getter to declare a column that holds date and
  /// time.
  /// Example (inside the body of a table class):
  /// ```
  /// DateTimeColumn get accountCreatedAt => dateTime()();
  /// ```
  @protected
  DateTimeColumnBuilder dateTime() => null;

  /// Use this as the body of a getter to declare a column that holds arbitrary
  /// data blobs, stored as an [Uint8List]. Example:
  /// ```
  /// BlobColumn get payload => blob()();
  /// ```
  @protected
  BlobColumnBuilder blob() => null;

  /// Use this as the body of a getter to declare a column that holds floating
  /// point numbers. Example
  /// ```
  /// RealColumn get averageSpeed => real()();
  /// ```
  @protected
  RealColumnBuilder real() => null;
}

/// A class to to be used as an annotation on [Table] classes to customize the
/// name for the data class that will be generated for the table class. The data
/// class is a dart object that will be used to represent a row in the table.
/// {@template moor:custom_data_class}
/// By default, moor will attempt to use the singular form of the table name
/// when naming data classes (e.g. a table named "Users" will generate a data
/// class called "User"). However, this doesn't work for irregular plurals and
/// you might want to choose a different name, for which this annotation can be
/// used.
/// {@template}
class DataClassName {
  final String name;

  /// Customize the data class name for a given table.
  /// {@macro moor:custom_data_class}
  const DataClassName(this.name);
}
