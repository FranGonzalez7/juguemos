import '../domain/board_game.dart';

/// [TEMPORAL] Juegos de prueba para sembrar la ludoteca mientras llega la
/// aprobación de BGG. Dejamos `thumbnail` a null (sin imágenes externas).
/// Cuando tengamos BGG, este archivo se puede borrar.
const List<BoardGame> sampleGames = [
  BoardGame(
    name: 'Catan',
    minPlayers: 3,
    maxPlayers: 4,
    playingTime: 90,
    customTags: ['Eurogame'],
  ),
  BoardGame(
    name: 'Carcassonne',
    minPlayers: 2,
    maxPlayers: 5,
    playingTime: 40,
    customTags: ['Eurogame', 'Filler'],
  ),
  BoardGame(
    name: 'Ticket to Ride',
    minPlayers: 2,
    maxPlayers: 5,
    playingTime: 60,
    customTags: ['Familiar'],
  ),
  BoardGame(
    name: 'Pandemic',
    minPlayers: 2,
    maxPlayers: 4,
    playingTime: 45,
    customTags: ['Cooperativo'],
  ),
  BoardGame(
    name: '7 Wonders',
    minPlayers: 3,
    maxPlayers: 7,
    playingTime: 30,
    customTags: ['Eurogame', 'Draft'],
  ),
  BoardGame(
    name: 'Azul',
    minPlayers: 2,
    maxPlayers: 4,
    playingTime: 40,
    customTags: ['Abstracto', 'Eurogame'],
  ),
  BoardGame(
    name: 'Dixit',
    minPlayers: 3,
    maxPlayers: 6,
    playingTime: 30,
    customTags: ['Party'],
  ),
  BoardGame(
    name: 'Wingspan',
    minPlayers: 1,
    maxPlayers: 5,
    playingTime: 60,
    customTags: ['Eurogame'],
  ),
  BoardGame(
    name: 'Terraforming Mars',
    minPlayers: 1,
    maxPlayers: 5,
    playingTime: 120,
    customTags: ['Eurogame'],
  ),
  BoardGame(
    name: 'Código Secreto',
    minPlayers: 2,
    maxPlayers: 8,
    playingTime: 15,
    customTags: ['Party', 'Filler'],
  ),
];
