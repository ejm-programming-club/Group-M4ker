import 'utils.dart';
export 'evaluators/mean_evaluator.dart';

abstract class Evaluator {
  List<Student> promo;

  Evaluator(this.promo);

  List<List<String>> findIssues(Grouping grouping);
}
