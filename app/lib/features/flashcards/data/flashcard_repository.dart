import 'package:drift/drift.dart';
import 'package:socra_task/core/data/database.dart';

class FlashcardRepository {
  FlashcardRepository(this.db);
  final AppDatabase db;

  // Decks

  Future<int> createDeck({required String title, String description = ''}) {
    return db.into(db.flashDecks).insert(
          FlashDecksCompanion.insert(
            title: title,
            description: Value(description),
          ),
        );
  }

  Future<void> updateDeck(int id, {String? title, String? description}) async {
    await (db.update(db.flashDecks)..where((t) => t.id.equals(id))).write(
      FlashDecksCompanion(
        title: title == null ? const Value.absent() : Value(title),
        description:
            description == null ? const Value.absent() : Value(description),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteDeck(int id) async {
    await (db.delete(db.flashCards)..where((t) => t.deckId.equals(id))).go();
    await (db.delete(db.flashDecks)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<FlashDeck>> watchDecks() =>
      (db.select(db.flashDecks)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();

  Future<List<FlashDeck>> fetchDecks() => db.select(db.flashDecks).get();

  // Cards

  Future<int> createCard(int deckId,
      {required String term,
      required String def,
      int? position,
      String type = 'basic',
      String highlights = '[]',
      String options = '[]',
      int answerIndex = -1}) async {
    final pos = position ?? await _nextPosition(deckId);
    return db.into(db.flashCards).insert(
          FlashCardsCompanion.insert(
            deckId: deckId,
            term: term,
            definition: def,
            position: Value(pos),
            type: Value(type),
            highlights: Value(highlights),
            options: Value(options),
            answerIndex: Value(answerIndex),
          ),
        );
  }

  Future<int> _nextPosition(int deckId) async {
    final q = await (db.selectOnly(db.flashCards)
          ..addColumns([db.flashCards.position.max()])
          ..where(db.flashCards.deckId.equals(deckId)))
        .getSingle();
    final m = q.read(db.flashCards.position.max());
    return (m ?? -1) + 1;
  }

  Future<void> updateCard(int id,
      {String? term,
      String? def,
      String? imageTerm,
      String? imageDef,
      String? type,
      String? highlights,
      String? options,
      int? answerIndex}) async {
    await (db.update(db.flashCards)..where((t) => t.id.equals(id))).write(
      FlashCardsCompanion(
        term: term == null ? const Value.absent() : Value(term),
        definition: def == null ? const Value.absent() : Value(def),
        imageTerm: imageTerm == null ? const Value.absent() : Value(imageTerm),
        imageDef: imageDef == null ? const Value.absent() : Value(imageDef),
        type: type == null ? const Value.absent() : Value(type),
        highlights: highlights == null ? const Value.absent() : Value(highlights),
        options: options == null ? const Value.absent() : Value(options),
        answerIndex: answerIndex == null ? const Value.absent() : Value(answerIndex),
      ),
    );
  }

  Future<void> deleteCard(int id) async {
    await (db.delete(db.flashCards)..where((t) => t.id.equals(id))).go();
  }

  Future<void> reorderCards(int deckId, List<int> orderedIds) async {
    for (var i = 0; i < orderedIds.length; i++) {
      await (db.update(db.flashCards)..where((t) => t.id.equals(orderedIds[i]))).write(
        FlashCardsCompanion(position: Value(i)),
      );
    }
  }

  Future<void> importCards(int deckId, List<({String term, String def})> items) async {
    for (final it in items) {
      await createCard(deckId, term: it.term, def: it.def);
    }
  }

  Stream<List<FlashCard>> watchCards(int deckId) =>
      (db.select(db.flashCards)..where((t) => t.deckId.equals(deckId))..orderBy([(t) => OrderingTerm.asc(t.position)])).watch();

  Future<List<FlashCard>> fetchCards(int deckId) =>
      (db.select(db.flashCards)..where((t) => t.deckId.equals(deckId))..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
}
