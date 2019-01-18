import 'package:rxdart/rxdart.dart';

class JPObservable<T> {
  T data;
  Subject<T> sink;
  Observable stream;
  JPObservable(T initData) {
    data = initData;
    sink = BehaviorSubject<T>();
    stream = Observable(sink.stream);
  }
  dispost() async {
    try {
      await sink.close();
    } catch(e) {
    }
  }
}