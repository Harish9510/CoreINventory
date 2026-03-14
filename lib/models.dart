enum OperationType { receipt, delivery, transfer, adjustment }

enum OperationStatus { draft, waiting, ready, done, canceled }

class Supplier {
  final String id;
  final String name;

  Supplier({required this.id, this.name = ""});
}

class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String unitOfMeasure;
  final int initialStock;
  final Map<String, int> stockPerLocation;
  final int reorderPoint;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.unitOfMeasure,
    this.initialStock = 0,
    this.stockPerLocation = const {},
    this.reorderPoint = 0,
  });

  int get totalStock =>
      stockPerLocation.values.fold(0, (sum, val) => sum + val);
}

class StockOperation {
  final String id;
  final String reference;
  final OperationType type;
  final OperationStatus status;
  final DateTime scheduledDate;
  final String? partner; // Supplier or Customer
  final String? sourceLocation;
  final String? destinationLocation;
  final Map<String, int> products; // Product ID -> Quantity

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

// Temporary data store
class DummyData {
  static List<Supplier> suppliers = [
    Supplier(id: "s1", name: "Apex Steel Corp"),
    Supplier(id: "s2", name: "Global Office Supplies"),
  ];

  static List<Product> products = [
    Product(
      id: "1",
      name: "Steel Rods 10mm",
      sku: "ST-ROD-10",
      category: "Raw Materials",
      unitOfMeasure: "Pieces",
      initialStock: 500,
      stockPerLocation: {"Warehouse A": 300, "Warehouse B": 200},
      reorderPoint: 100,
    ),
    Product(
      id: "2",
      name: "Ergonomic Office Chair",
      sku: "CH-ERGO-01",
      category: "Furniture",
      unitOfMeasure: "Units",
      initialStock: 25,
      stockPerLocation: {"Showroom": 5, "Main Store": 20},
      reorderPoint: 10,
    ),
    Product(
      id: "3",
      name: "LED Monitor 24 inch",
      sku: "EL-MON-24",
      category: "Electronics",
      unitOfMeasure: "Units",
      initialStock: 0,
      stockPerLocation: {"Main Store": 0},
      reorderPoint: 5,
    ),
  ];

  static List<StockOperation> operations = [
    StockOperation(
      id: "op1",
      reference: "WH/IN/0001",
      type: OperationType.receipt,
      status: OperationStatus.done,
      scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
      partner: "Apex Steel Corp",
      destinationLocation: "Warehouse A",
      products: {"1": 50},
    ),
    StockOperation(
      id: "op2",
      reference: "WH/OUT/0001",
      type: OperationType.delivery,
      status: OperationStatus.ready,
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      partner: "John Doe",
      sourceLocation: "Main Store",
      products: {"2": 10},
    ),
    StockOperation(
      id: "op3",
      reference: "WH/INT/0001",
      type: OperationType.transfer,
      status: OperationStatus.waiting,
      scheduledDate: DateTime.now(),
      sourceLocation: "Warehouse A",
      destinationLocation: "Warehouse B",
      products: {"1": 20},
    ),
  ];
}
