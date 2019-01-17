import 'package:rxdart/rxdart.dart';

class JPObservable<T> {
  Subject<T> sink;
  Observable stream;
  JPObservable() {
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