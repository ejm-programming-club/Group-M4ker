import 'utils.dart';
export 'generators/min_jealousy.dart';

abstract class Generator {
  List<Student> promo;

  Generator(this.promo);

  Grouping generate(
      {int numberOfGroups = 10});
}
