import 'package:dartz/dartz.dart';
import 'package:sajilo_stay/core/error/failures.dart';

abstract interface class UsecaseWithParams<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

abstract interface class UseecaseWithoutParams<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}
