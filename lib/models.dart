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
  String? responsible;
  String? deliveryAddress;
  String? operationSubType; // e.g. 'Pick', 'Pack', 'Ship' for deliveries

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
    this.responsible,
    this.deliveryAddress,
    this.operationSubType,
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

  final List<String> customers = [
    'Acme Corp',
    'Azure Interior',
    'BuildPro Ltd',
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

  final List<String> operationSubTypes = ['Pick', 'Pack', 'Ship', 'Direct'];

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
      responsible: 'Admin',
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
      responsible: 'Admin',
      deliveryAddress: '123 Business Ave',
      operationSubType: 'Ship',
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
      responsible: 'Admin',
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

  // ── Status Transitions ──

  /// Validate: Draft → Ready (receipts/transfers), Waiting → Ready (deliveries)
  bool validateOperation(String opId) {
    final op = _findOp(opId);
    if (op == null) return false;

    if (op.type == OperationType.delivery) {
      if (op.status == OperationStatus.draft ||
          op.status == OperationStatus.waiting) {
        op.status = OperationStatus.ready;
        notifyListeners();
        return true;
      }
    } else {
      if (op.status == OperationStatus.draft) {
        op.status = OperationStatus.ready;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Mark Done: Ready → Done and apply stock changes
  bool markDone(String opId) {
    final op = _findOp(opId);
    if (op == null || op.status != OperationStatus.ready) return false;

    op.status = OperationStatus.done;
    _applyStockChanges(op);
    notifyListeners();
    return true;
  }

  /// Cancel any operation (unless already done)
  bool cancelOperation(String opId) {
    final op = _findOp(opId);
    if (op == null || op.status == OperationStatus.done) return false;

    op.status = OperationStatus.canceled;
    notifyListeners();
    return true;
  }

  /// Generic method to update status directly (useful for waiting state)
  bool updateOperationStatus(String opId, OperationStatus newStatus) {
    final op = _findOp(opId);
    if (op == null) return false;
    op.status = newStatus;
    notifyListeners();
    return true;
  }

  StockOperation? _findOp(String id) {
    try {
      return operations.firstWhere((op) => op.id == id);
    } catch (_) {
      return null;
    }
  }

  void _applyStockChanges(StockOperation op) {
    switch (op.type) {
      case OperationType.receipt:
        for (final entry in op.products.entries) {
          final product = getProduct(entry.key);
          if (product != null) {
            final dest = op.destinationLocation ?? '';
            product.stockPerLocation[dest] =
                (product.stockPerLocation[dest] ?? 0) + entry.value;
          }
        }
        break;
      case OperationType.delivery:
        for (final entry in op.products.entries) {
          final product = getProduct(entry.key);
          if (product != null) {
            final src = op.sourceLocation ?? '';
            final current = product.stockPerLocation[src] ?? 0;
            product.stockPerLocation[src] = (current - entry.value).clamp(
              0,
              current,
            );
          }
        }
        break;
      case OperationType.transfer:
        for (final entry in op.products.entries) {
          final product = getProduct(entry.key);
          if (product != null) {
            final src = op.sourceLocation ?? '';
            final dest = op.destinationLocation ?? '';
            final current = product.stockPerLocation[src] ?? 0;
            product.stockPerLocation[src] = (current - entry.value).clamp(
              0,
              current,
            );
            product.stockPerLocation[dest] =
                (product.stockPerLocation[dest] ?? 0) + entry.value;
          }
        }
        break;
      case OperationType.adjustment:
        // Adjustments are applied immediately
        break;
    }
  }

  /// Check if products in an operation have sufficient stock
  Map<String, bool> checkStockAvailability(StockOperation op) {
    final result = <String, bool>{};
    final location = op.sourceLocation ?? '';
    for (final entry in op.products.entries) {
      final product = getProduct(entry.key);
      if (product != null) {
        final available = product.stockPerLocation[location] ?? 0;
        result[entry.key] = available >= entry.value;
      } else {
        result[entry.key] = false;
      }
    }
    return result;
  }

  // ── Receipts (incoming) — now starts as draft ──
  void createReceipt({
    required String supplier,
    required String destination,
    required Map<String, int> items,
    String? responsible,
  }) {
    _opCounter++;
    final op = StockOperation(
      id: 'op$_opCounter',
      reference: 'WH/IN/${_opCounter.toString().padLeft(4, '0')}',
      type: OperationType.receipt,
      status: OperationStatus.draft,
      scheduledDate: DateTime.now(),
      partner: supplier,
      destinationLocation: destination,
      products: items,
      responsible: responsible ?? 'Admin',
    );
    operations.insert(0, op);
    notifyListeners();
  }

  // ── Deliveries (outgoing) — now starts as draft ──
  void createDelivery({
    required String customer,
    required String source,
    required Map<String, int> items,
    String? responsible,
    String? deliveryAddress,
    String? operationSubType,
  }) {
    _opCounter++;
    final op = StockOperation(
      id: 'op$_opCounter',
      reference: 'WH/OUT/${_opCounter.toString().padLeft(4, '0')}',
      type: OperationType.delivery,
      status: OperationStatus.draft,
      scheduledDate: DateTime.now(),
      partner: customer,
      sourceLocation: source,
      products: items,
      responsible: responsible ?? 'Admin',
      deliveryAddress: deliveryAddress,
      operationSubType: operationSubType,
    );
    operations.insert(0, op);
    notifyListeners();
  }

  // ── Transfers ──
  void createTransfer({
    required String source,
    required String destination,
    required Map<String, int> items,
    String? responsible,
  }) {
    _opCounter++;
    final op = StockOperation(
      id: 'op$_opCounter',
      reference: 'WH/INT/${_opCounter.toString().padLeft(4, '0')}',
      type: OperationType.transfer,
      status: OperationStatus.draft,
      scheduledDate: DateTime.now(),
      sourceLocation: source,
      destinationLocation: destination,
      products: items,
      responsible: responsible ?? 'Admin',
    );
    operations.insert(0, op);
    notifyListeners();
  }

  // ── Adjustments ── (applied immediately)
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
      responsible: 'Admin',
    );
    operations.insert(0, op);
    product.stockPerLocation[location] = newQuantity;
    notifyListeners();
  }

  List<StockOperation> getOperationsByType(OperationType type) =>
      operations.where((op) => op.type == type).toList();

  /// Get all move history entries (flattened: one row per product per operation)
  List<Map<String, dynamic>> getMoveHistory() {
    final moves = <Map<String, dynamic>>[];
    for (final op in operations) {
      for (final entry in op.products.entries) {
        final product = getProduct(entry.key);
        moves.add({
          'operation': op,
          'productId': entry.key,
          'productName': product?.name ?? entry.key,
          'productSku': product?.sku ?? '',
          'quantity': entry.value,
        });
      }
    }
    return moves;
  }
}
