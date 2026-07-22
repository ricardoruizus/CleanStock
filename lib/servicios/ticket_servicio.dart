import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class TicketServicio {
  static Future<void> generarYCompartirTicket(List<Map<String, dynamic>> ticket, double total, String folio) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('TICKET DE VENTA', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text('Folio: $folio'),
              pw.Divider(),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Producto', 'Cant', 'Precio', 'Total'],
                  ...ticket.map((item) => [
                    item['nombre'],
                    item['cantidad'].toString(),
                    item['precio'].toStringAsFixed(2),
                    (item['precio'] * item['cantidad']).toStringAsFixed(2)
                  ]),
                ],
              ),
              pw.Divider(),
              pw.Text('TOTAL: \$${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ticket_$folio.pdf');
    await file.writeAsBytes(await pdf.save());

    // Compartir por WhatsApp
    await Share.shareXFiles([XFile(file.path)], text: 'Aquí está tu ticket de compra: $folio');
  }
}
