---
trigger: always_on
---

## 2. OOP Fundamentals

### 2.1 Encapsulation — Hide Internal State
Expose behavior, not raw mutable fields. Dart's `_` prefix creates library-private
members — use it.

```dart
// ❌ BAD: any code can corrupt the balance directly
class BankAccount {
  double balance = 0;
}

account.balance = -9999; // no validation, no invariant

// ✅ GOOD: state can only change through controlled behavior
class BankAccount {
  double _balance = 0;
  double get balance => _balance;

  void deposit(double amount) {
    if (amount <= 0) throw ArgumentError('Deposit must be positive');
    _balance += amount;
  }

  void withdraw(double amount) {
    if (amount > _balance) throw InsufficientFundsException(amount - _balance);
    _balance -= amount;
  }
}
```

### 2.2 Favor Composition Over Inheritance
Deep inheritance chains are fragile (changing a base class ripples through every
subclass). Prefer composing small collaborators.

```dart
// ❌ BAD: rigid inheritance hierarchy for behavior that doesn't fit "is-a"
class Vehicle {
  void move() => print('Moving');
}
class FlyingCar extends Vehicle {
  void fly() => print('Flying'); // now every Vehicle subtype question gets murky
}

// ✅ GOOD: compose capabilities instead of forcing a hierarchy
class Engine {
  void start() => print('Engine started');
}
class Wings {
  void deploy() => print('Wings deployed');
}
class FlyingCar {
  final Engine engine;
  final Wings wings;
  FlyingCar(this.engine, this.wings);

  void takeOff() {
    engine.start();
    wings.deploy();
  }
}
```

### 2.3 Program to an Interface, Not an Implementation
Depend on `abstract interface class` contracts so implementations are swappable
(directly enables DIP in §3.5 and testability via mocks/fakes).

```dart
// ❌ BAD: tightly coupled to one concrete implementation
class ReportGenerator {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();
  void track(String event) => _analytics.logEvent(name: event);
}

// ✅ GOOD: depends on an abstraction
abstract interface class AnalyticsService {
  void track(String event);
}
class ReportGenerator {
  final AnalyticsService _analytics;
  ReportGenerator(this._analytics); // any implementation can be injected, incl. a fake for tests
  void logCompletion() => _analytics.track('report_completed');
}
```

### 2.4 Keep Classes Small and Focused
A class that grows a new reason to change every sprint ("god class") is a sign
responsibilities need splitting — see SRP in §3.1 for the fix.

---

