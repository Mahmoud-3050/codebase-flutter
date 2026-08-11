---
trigger: always_on
---

## 3. SOLID Principles

### 3.1 Single Responsibility Principle (SRP)
*A class should have only one reason to change.*

```dart
// ❌ BAD: Invoice mixes data, formatting, and persistence
class Invoice {
  final String id;
  final double amount;
  Invoice(this.id, this.amount);

  String toPrintableReceipt() => 'Invoice $id: \$${amount.toStringAsFixed(2)}';
  Future<void> saveToDatabase() async { /* SQL here */ }
}

// ✅ GOOD: each concern is its own class
class Invoice {
  final String id;
  final double amount;
  const Invoice({required this.id, required this.amount});
}

class InvoiceFormatter {
  String toPrintableReceipt(Invoice invoice) =>
      'Invoice ${invoice.id}: \$${invoice.amount.toStringAsFixed(2)}';
}

abstract interface class InvoiceRepository {
  Future<void> save(Invoice invoice);
}
```

### 3.2 Open/Closed Principle (OCP)
*Open for extension, closed for modification* — add new behavior via new classes, not
by editing existing, tested ones.

```dart
// ❌ BAD: every new payment method means editing this method's if-chain
double calculateFee(String paymentType, double amount) {
  if (paymentType == 'creditCard') return amount * 0.03;
  if (paymentType == 'paypal') return amount * 0.05;
  // adding crypto means touching this function again, risking regressions
  throw ArgumentError('Unknown payment type');
}

// ✅ GOOD: new payment methods extend the system without modifying existing code
abstract interface class PaymentProcessor {
  Future<bool> processPayment(double amount);
  double calculateFee(double amount);
}

class CreditCardPayment implements PaymentProcessor {
  @override
  double calculateFee(double amount) => amount * 0.03;
  @override
  Future<bool> processPayment(double amount) async => true;
}

class CryptoPayment implements PaymentProcessor {
  // Added later. CreditCardPayment/PayPalPayment are untouched.
  @override
  double calculateFee(double amount) => amount * 0.01;
  @override
  Future<bool> processPayment(double amount) async => true;
}
```

### 3.3 Liskov Substitution Principle (LSP)
*Subtypes must be usable wherever their base type is expected, without surprises.*

```dart
// ❌ BAD: Ostrich breaks the contract every Bird is supposed to honor
abstract class Bird {
  void fly();
}
class Ostrich extends Bird {
  @override
  void fly() => throw UnsupportedError('Ostriches cannot fly!');
}

void makeBirdsFly(List<Bird> birds) {
  for (final bird in birds) {
    bird.fly(); // crashes at runtime if an Ostrich sneaks in
  }
}

// ✅ GOOD: model the actual capability hierarchy
abstract class Bird {}
abstract class FlyingBird extends Bird {
  void fly();
}
class Eagle extends FlyingBird {
  @override
  void fly() => print('Flying high');
}
class Ostrich extends Bird {
  void run() => print('Running fast');
}
```

### 3.4 Interface Segregation Principle (ISP)
*Don't force classes to implement methods they don't need.*

```dart
// ❌ BAD: RobotWorker is forced to implement eat(), which makes no sense for it
abstract interface class Worker {
  void work();
  void eat();
}
class RobotWorker implements Worker {
  @override
  void work() => print('Working non-stop');
  @override
  void eat() => throw UnsupportedError('Robots do not eat'); // code smell
}

// ✅ GOOD: split into focused, composable interfaces
abstract interface class Workable {
  void work();
}
abstract interface class Feedable {
  void eat();
}
class HumanWorker implements Workable, Feedable {
  @override
  void work() => print('Working');
  @override
  void eat() => print('Eating lunch');
}
class RobotWorker implements Workable {
  @override
  void work() => print('Working non-stop'); // no unused/unsupported method
}
```

### 3.5 Dependency Inversion Principle (DIP)
*High-level modules should depend on abstractions, not concrete low-level modules.*

```dart
// ❌ BAD: OrderService is welded to one concrete notification channel
class EmailService {
  Future<void> sendEmail(String to, String body) async { /* ... */ }
}
class OrderService {
  final EmailService _emailService = EmailService(); // hard-coded dependency
  Future<void> completeOrder(String userEmail, String orderId) async {
    await _emailService.sendEmail(userEmail, 'Order $orderId completed!');
  }
}

// ✅ GOOD: OrderService depends on an abstraction; any channel can be swapped in
abstract interface class NotificationService {
  Future<void> send(String recipient, String message);
}
class EmailService implements NotificationService {
  @override
  Future<void> send(String recipient, String message) async { /* ... */ }
}
class OrderService {
  final NotificationService _notificationService;
  OrderService(this._notificationService); // injected — testable, swappable

  Future<void> completeOrder(String userEmail, String orderId) async {
    await _notificationService.send(userEmail, 'Order $orderId completed!');
  }
}
```

---

