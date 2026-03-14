import 'package:flutter/material.dart';

enum OperationType { receipt, delivery, transfer, adjustment }

enum OperationStatus { draft, waiting, ready, done, canceled }

class Product {
  final String id;
  String name;
  String sku;
  String category;
  String unitOfMeasure;
  int reorderPoint;
  Map<String, int> stockPerLocation;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.unitOfMeasure,
    this.reorderPoint = 0,
    Map<String, int>? stockPerLocation,
  }) : stockPerLocation = stockPerLocation ?? {};

  int get totalStock =>
      stockPerLocation.values.fold(0, (sum, val) => sum + val);
}

class StockOperation {
  final String id;
  final String reference;
  final OperationType type;
  OperationStatus status;
  final DateTime scheduledDate;
  final String? partner;
  final String? sourceLocation;
  final String? destinationLocation;
  final Map<String, int> products; // productId -> quantity

  StockOperation({
    required this.id,
    required this.reference,
    required this.type,
    required this.status,
    required this.scheduledDate,
    this.partner,
    this.sourceLocation,
    this.destinationLocation,
    required this.products,
  });
}

/// Central in-memory data store with ChangeNotifier for reactive UI
class InventoryStore extends ChangeNotifier {
  int _opCounter = 4;

  final List<String> suppliers = [
    'Apex Steel Corp',
    'Global Office Supplies',
    'TechWorld Distributors',
  ];

  final List<String> warehouses = [
    'Warehouse A',
    'Warehouse B',
    'Main Store',
    'Showroom',
    'Production',
  ];

  final List<String> categories = [
    'Raw Materials',
    'Furniture',
    'Electronics',
    'Office Supplies',
  ];

  final List<Product> products = [
    Product(
      id: '1',
      name: 'Steel Rods 10mm',
      sku: 'ST-ROD-10',
      category: 'Raw Materials',
      unitOfMeasure: 'Pieces',
      reorderPoint: 100,
      stockPerLocation: {'Warehouse A': 300, 'Warehouse B': 200},
    ),
    Product(
      id: '2',
      name: 'Ergonomic Office Chair',
      sku: 'CH-ERGO-01',
      category: 'Furniture',
      unitOfMeasure: 'Units',
      reorderPoint: 10,
      stockPerLocation: {'Showroom': 5, 'Main Store': 20},
    ),
    Product(
      id: '3',
      name: 'LED Monitor 24"',
      sku: 'EL-MON-24',
      category: 'Electronics',
      unitOfMeasure: 'Units',
      reorderPoint: 5,
      stockPerLocation: {'Main Store': 0},
    ),
    Product(
      id: '4',
      name: 'A4 Printing Paper',
      sku: 'OS-A4-01',
      category: 'Office Supplies',
      unitOfMeasure: 'Reams',
      reorderPoint: 20,
      stockPerLocation: {'Main Store': 45, 'Warehouse A': 100},
    ),
  ];

  final List<StockOperation> operations = [
    StockOperation(
      id: 'op1',
      reference: 'WH/IN/0001',
      type: OperationType.receipt,
      status: OperationStatus.done,
      scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
      partner: 'Apex Steel Corp',
      destinationLocation: 'Warehouse A',
      products: {'1': 50},
    ),
    StockOperation(
      id: 'op2',
      reference: 'WH/OUT/0001',
      type: OperationType.delivery,
      status: OperationStatus.ready,
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      partner: 'Acme Corp',
      sourceLocation: 'Main Store',
      products: {'2': 10},
    ),
    StockOperation(
      id: 'op3',
      reference: 'WH/INT/0001',
      type: OperationType.transfer,
      status: OperationStatus.waiting,
      scheduledDate: DateTime.now(),
      sourceLocation: 'Warehouse A',
      destinationLocation: 'Warehouse B',
      products: {'1': 20},
    ),
  ];

  // ── Product CRUD ──
  void addProduct(Product product) {
    products.add(product);
    notifyListeners();
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Product? getProduct(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Receipts (incoming) ──
  void createReceipt({
    required String supplier,
    required String destination,
    required Map<String, int> items,
  }) {
    _opCounter++;
    final op = StockOperation(
      id: 'op$_opCounter',
      reference: 'WH/IN/${_opCounter.toString().padLeft(4, '0')}',
      type: OperationType.receipt,
      status: OperationStatus.done,
      scheduledDate: DateTime.now(),
      partner: supplier,
      destinationLocation: destination,
      products: items,
    );
    operations.insert(0, op);

    // Increase stock
    for (final entry in items.entries) {
      final product = getProduct(entry.key);
      if (product != null) {
        product.stockPerLocation[destination] =
            (product.stockPerLocation[destination] ?? 0) + entry.value;
      }
    }
    notifyListeners();
  }

  // ── Deliveries (outgoing) ──
  void createDelivery({
    required String customer,
    required String source,
    required Map<String, int> items,
  }) {
    _opCounter++;
    final op = StockOperation(
      id: 'op$_opCounter',
      reference: 'WH/OUT/${_opCounter.toString().padLeft(4, '0')}',
      type: OperationType.delivery,
      status: OperationStatus.done,
      scheduledDate: DateTime.now(),
      partner: customer,
      sourceLocation: source,
      products: items,
    );
    operations.insert(0, op);

    // Decrease stock
    for (final entry in items.entries) {
      final product = getProduct(entry.key);
      if (product != null) {
        final current = product.stockPerLocation[source] ?? 0;
        product.stockPerLocation[source] = (current - entry.value).clamp(
          0,
          current,
        );
      }
    }
    notifyListeners();
  }

  // ── Transfers ──
  void createTransfer({
    required String source,
    required String destination,
    required Map<String, int> items,
  }) {
    _opCounter++;
    final op = StockOperation(
      id: 'op$_opCounter',
      reference: 'WH/INT/${_opCounter.toString().padLeft(4, '0')}',
      type: OperationType.transfer,
      status: OperationStatus.done,
      scheduledDate: DateTime.now(),
      sourceLocation: source,
      destinationLocation: destination,
      products: items,
    );
    operations.insert(0, op);

    for (final entry in items.entries) {
      final product = getProduct(entry.key);
      if (product != null) {
        final current = product.stockPerLocation[source] ?? 0;
        product.stockPerLocation[source] = (current - entry.value).clamp(
          0,
          current,
        );
        product.stockPerLocation[destination] =
            (product.stockPerLocation[destination] ?? 0) + entry.value;
      }
    }
    notifyListeners();
  }

  // ── Adjustments ──
  void createAdjustment({
    required String productId,
    required String location,
    required int newQuantity,
    String reason = '',
  }) {
    final product = getProduct(productId);
    if (product == null) return;

    final oldQty = product.stockPerLocation[location] ?? 0;
    final diff = newQuantity - oldQty;

    _opCounter++;
    final op = StockOperation(
      id: 'op$_opCounter',
      reference: 'WH/ADJ/${_opCounter.toString().padLeft(4, '0')}',
      type: OperationType.adjustment,
      status: OperationStatus.done,
      scheduledDate: DateTime.now(),
      partner: reason,
      sourceLocation: location,
      products: {productId: diff},
    );
    operations.insert(0, op);
    product.stockPerLocation[location] = newQuantity;
    notifyListeners();
  }

  List<StockOperation> getOperationsByType(OperationType type) =>
      operations.where((op) => op.type == type).toList();
}
