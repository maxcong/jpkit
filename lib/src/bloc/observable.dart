import 'package:rxdart/rxdart.dart';

class JPObservable<T> {
  T data;
  Subject<T> sink;
  Observable get stream => sink.stream;
  JPObservable(T initData) {
    data = initData;
    sink = BehaviorSubject<T>();
  }
  dispost() async {
    try {
      await sink.close();
    } catch(e) {
    }
  }
}