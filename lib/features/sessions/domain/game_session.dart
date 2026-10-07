import 'package:cloud_firestore/cloud_firestore.dart';

/// Un jugador dentro de una partida. Guardamos el nombre denormalizado
/// para poder mostrar la partida sin tener que buscar cada perfil.
class SessionPlayer {
  const SessionPlayer({required this.uid, required this.name});

  final String uid;
  final String name;

  factory SessionPlayer.fromMap(Map<String, dynamic> map) => SessionPlayer(
        uid: (map['uid'] ?? '') as String,
        name: (map['name'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {'uid': uid, 'name': name};
}

/// Una partida: se juega en UNA ludoteca (la del sitio físico), con unos
/// jugadores presentes, un tiempo disponible y una categoría opcional.
class GameSession {
  const GameSession({
    this.id = '',
    required this.hostUid,
    required this.libraryOwnerUid,
    required this.libraryOwnerName,
    required this.players,
    this.availableMinutes,
    this.desiredCategory,
    this.chosenGameId,
    this.chosenGameName,
    this.status = 'planned',
    this.createdAt,
  });

  final String id;
  final String hostUid; // quién creó la partida
  final String libraryOwnerUid; // de quién es la ludoteca donde se juega
  final String libraryOwnerName;
  final List<SessionPlayer> players;
  final int? availableMinutes;
  final String? desiredCategory;
  final String? chosenGameId;
  final String? chosenGameName; // nombre del juego decidido (denormalizado)
  final String status; // "planned" | "played"
  final DateTime? createdAt;

  /// Solo los uids, para poder consultar en Firestore "partidas donde estoy".
  List<String> get playerUids => players.map((p) => p.uid).toList();

  factory GameSession.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final playersRaw = (data['players'] as List<dynamic>?) ?? const [];
    return GameSession(
      id: doc.id,
      hostUid: (data['hostUid'] ?? '') as String,
      libraryOwnerUid: (data['libraryOwnerUid'] ?? '') as String,
      libraryOwnerName: (data['libraryOwnerName'] ?? '') as String,
      players: playersRaw
          .map((p) => SessionPlayer.fromMap(p as Map<String, dynamic>))
          .toList(),
      availableMinutes: (data['availableMinutes'] as num?)?.toInt(),
      desiredCategory: data['desiredCategory'] as String?,
      chosenGameId: data['chosenGameId'] as String?,
      chosenGameName: data['chosenGameName'] as String?,
      status: (data['status'] ?? 'planned') as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'hostUid': hostUid,
        'libraryOwnerUid': libraryOwnerUid,
        'libraryOwnerName': libraryOwnerName,
        'players': players.map((p) => p.toMap()).toList(),
        'playerUids': playerUids, // campo plano para consultas array-contains
        'availableMinutes': availableMinutes,
        'desiredCategory': desiredCategory,
        'chosenGameId': chosenGameId,
        'chosenGameName': chosenGameName,
        'status': status,
      };
}
