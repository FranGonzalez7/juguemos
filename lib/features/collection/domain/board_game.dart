import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa un juego dentro de la ludoteca (o la wishlist).
///
/// Es una clase "de dominio": describe los datos de un juego sin saber nada
/// de Firestore ni de pantallas. Las conversiones a/desde Firestore las
/// hacemos con `fromDoc` y `toMap`.
class BoardGame {
  const BoardGame({
    this.id = '',
    required this.name,
    this.thumbnail,
    this.minPlayers,
    this.maxPlayers,
    this.playingTime,
    this.customTags = const [],
  });

  /// Id del documento (será el gameId de BGG, o uno generado en altas manuales).
  final String id;
  final String name;
  final String? thumbnail;
  final int? minPlayers;
  final int? maxPlayers;
  final int? playingTime; // en minutos
  final List<String> customTags;

  /// Crea un BoardGame a partir de un documento de Firestore.
  factory BoardGame.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return BoardGame(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      thumbnail: data['thumbnail'] as String?,
      minPlayers: (data['minPlayers'] as num?)?.toInt(),
      maxPlayers: (data['maxPlayers'] as num?)?.toInt(),
      playingTime: (data['playingTime'] as num?)?.toInt(),
      customTags:
          (data['customTags'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  /// Convierte el objeto a un mapa para guardarlo en Firestore.
  /// Ojo: NO incluimos el id (ese es la clave del documento, no un campo).
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'thumbnail': thumbnail,
      'minPlayers': minPlayers,
      'maxPlayers': maxPlayers,
      'playingTime': playingTime,
      'customTags': customTags,
    };
  }

  /// Texto cómodo para mostrar el rango de jugadores (ej. "2-4").
  String? get playersLabel {
    if (minPlayers == null && maxPlayers == null) return null;
    if (minPlayers != null && maxPlayers != null) {
      return minPlayers == maxPlayers ? '$minPlayers' : '$minPlayers-$maxPlayers';
    }
    return '${minPlayers ?? maxPlayers}';
  }
}
