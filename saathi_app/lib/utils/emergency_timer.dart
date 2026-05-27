import 'dart:async';

class EmergencyTimer {
  EmergencyTimer({this.duration = const Duration(minutes: 10)});

  final Duration duration;
  Timer? _timer;
  DateTime? _startedAt;

  void start(void Function(Duration remaining) onTick, {void Function()? onCompleted}) {
    stop();
    _startedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final elapsed = DateTime.now().difference(_startedAt!);
      final remaining = duration - elapsed;
      if (remaining.isNegative || remaining == Duration.zero) {
        stop();
        onTick(Duration.zero);
        onCompleted?.call();
        return;
      }
      onTick(remaining);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
