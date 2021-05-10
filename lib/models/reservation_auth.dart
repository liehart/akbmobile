class ReservationAuth {
  final String token;
  final String customerName;
  final int tableNumber;
  final DateTime enterTime;

  ReservationAuth({
    this.token,
    this.customerName,
    this.tableNumber,
    this.enterTime
  });

  factory ReservationAuth.fromJson(Map<String, dynamic> json) => ReservationAuth(
    token: json['token'],
    customerName: json['customer_name'],
    tableNumber: json['table_number'],
    enterTime: json['enter_time']
  );
}