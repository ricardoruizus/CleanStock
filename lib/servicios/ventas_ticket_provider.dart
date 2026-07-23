class VentasTicketProvider {
  static final VentasTicketProvider _instance = VentasTicketProvider._internal();
  
  List<Map<String, dynamic>> ticket = [];
  String codigoInput = "";

  factory VentasTicketProvider() {
    return _instance;
  }

  VentasTicketProvider._internal();
}
