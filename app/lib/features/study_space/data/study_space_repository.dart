import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:socra_task/core/data/database.dart';

/// Thin persistence layer for the Study Space hub (v2 rebuild).
/// Rule: callers commit on gesture END, never per-frame. All drag/preview
/// state lives in memory in the presentation layer.
class StudySpaceRepository {
  StudySpaceRepository(this.db);
  final AppDatabase db;

  Future<int> ensureBoard() async {
    final existing = await db.select(db.studyBoards).get();
    if (existing.isNotEmpty) return existing.first.id;
    return db.into(db.studyBoards).insert(
        StudyBoardsCompanion.insert(title: const Value('Study Space')));
  }

  Future<List<StudyBoard>> fetchBoards() =>
      db.select(db.studyBoards).get();

  Future<int> createBoard(String title) => db
      .into(db.studyBoards)
      .insert(StudyBoardsCompanion.insert(title: Value(title)));

  Stream<List<BoardWidget>> watchWidgets(int boardId) => (db
        .select(db.boardWidgets)
        ..where((t) => t.boardId.equals(boardId))
        ..orderBy([(t) => OrderingTerm.asc(t.z)]))
      .watch();

  Future<int> addWidget(int boardId,
      {required String type,
      double x = 80,
      double y = 80,
      double w = 320,
      double h = 220,
      Map<String, dynamic> payload = const {},
      int z = 0}) {
    return db.into(db.boardWidgets).insert(BoardWidgetsCompanion.insert(
        boardId: boardId,
        type: type,
        x: Value(x),
        y: Value(y),
        w: Value(w),
        h: Value(h),
        payloadJson: Value(jsonEncode(payload)),
        z: Value(z)));
  }

  Future<void> moveWidget(int id, double x, double y) =>
      (db.update(db.boardWidgets)..where((t) => t.id.equals(id)))
          .write(BoardWidgetsCompanion(x: Value(x), y: Value(y)));

  Future<void> resizeWidget(int id, double w, double h) =>
      (db.update(db.boardWidgets)..where((t) => t.id.equals(id)))
          .write(BoardWidgetsCompanion(w: Value(w), h: Value(h)));

  Future<void> updateWidgetPayload(int id, Map<String, dynamic> payload) =>
      (db.update(db.boardWidgets)..where((t) => t.id.equals(id))).write(
          BoardWidgetsCompanion(payloadJson: Value(jsonEncode(payload))));

  Future<void> deleteWidget(int id) =>
      (db.delete(db.boardWidgets)..where((t) => t.id.equals(id))).go();

  Stream<List<BoardStroke>> watchStrokes(int boardId) => (db
        .select(db.boardStrokes)
        ..where((t) => t.boardId.equals(boardId)))
      .watch();

  Future<void> addStroke(int boardId,
      {required String tool,
      required List<List<double>> points,
      required String color,
      required double width,
      double opacity = 1}) {
    return db.into(db.boardStrokes).insert(BoardStrokesCompanion.insert(
        boardId: boardId,
        tool: tool,
        pointsJson: jsonEncode(points),
        color: color,
        width: width,
        opacity: Value(opacity)));
  }

  Future<List<BoardStroke>> latestStrokes(int boardId, int n) =>
      (db.select(db.boardStrokes)
            ..where((t) => t.boardId.equals(boardId))
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(n))
          .get();

  Future<void> deleteStroke(int id) =>
      (db.delete(db.boardStrokes)..where((t) => t.id.equals(id))).go();

  Future<void> restoreStroke(BoardStroke s) => db
      .into(db.boardStrokes)
      .insert(BoardStrokesCompanion.insert(
          boardId: s.boardId,
          tool: s.tool,
          pointsJson: s.pointsJson,
          color: s.color,
          width: s.width,
          opacity: Value(s.opacity)));

  Future<void> clearStrokes(int boardId) =>
      (db.delete(db.boardStrokes)..where((t) => t.boardId.equals(boardId)))
          .go();

  Stream<List<BoardShape>> watchShapes(int boardId) => (db
        .select(db.boardShapes)
        ..where((t) => t.boardId.equals(boardId)))
      .watch();

  Future<int> addShape(int boardId,
      {required String kind,
      required double x,
      required double y,
      required double w,
      required double h,
      Map<String, dynamic> style = const {}}) {
    return db.into(db.boardShapes).insert(BoardShapesCompanion.insert(
        boardId: boardId,
        kind: kind,
        x: x,
        y: y,
        w: w,
        h: h,
        styleJson: Value(jsonEncode(style))));
  }

  Future<void> moveShape(int id, double x, double y) =>
      (db.update(db.boardShapes)..where((t) => t.id.equals(id)))
          .write(BoardShapesCompanion(x: Value(x), y: Value(y)));

  Future<void> deleteShape(int id) =>
      (db.delete(db.boardShapes)..where((t) => t.id.equals(id))).go();
}
