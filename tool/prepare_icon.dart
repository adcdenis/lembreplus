import 'dart:io';
import 'package:image/image.dart' as img;

void main(List<String> args) async {
  final srcPath = args.isNotEmpty ? args[0] : 'assets/app_icon.png';
  final dstPath = args.length > 1 ? args[1] : 'assets/app_icon_foreground.png';

  final srcFile = File(srcPath);
  if (!await srcFile.exists()) {
    stderr.writeln('Fonte não encontrada: $srcPath');
    exit(1);
  }

  final bytes = await srcFile.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    stderr.writeln('Falha ao decodificar imagem: $srcPath');
    exit(1);
  }

  // Tamanho alvo padrão para adaptive foreground (Android recomenda 432x432)
  const targetSize = 432;

  // Define um fator de escala para "diminuir um pouco" a arte dentro da área
  // 0.88 ~ 12% de padding ao redor (ajuste fino conforme necessidade)
  const scaleFactor = 0.88;
  final innerSize = (targetSize * scaleFactor).round();

  // Redimensiona a arte original para innerSize mantendo proporção
  final resized = img.copyResize(decoded, width: innerSize, height: innerSize, interpolation: img.Interpolation.cubic);

  // Cria uma tela transparente targetSize x targetSize
  final canvas = img.Image(width: targetSize, height: targetSize);

  // Centraliza a arte redimensionada na tela
  final dx = ((targetSize - innerSize) / 2).round();
  final dy = ((targetSize - innerSize) / 2).round();
  for (var y = 0; y < innerSize; y++) {
    for (var x = 0; x < innerSize; x++) {
      final color = resized.getPixel(x, y);
      canvas.setPixel(dx + x, dy + y, color);
    }
  }

  // Grava PNG final
  final outBytes = img.encodePng(canvas);
  await File(dstPath).writeAsBytes(outBytes);
  stdout.writeln('Gerado foreground com padding: $dstPath');
}