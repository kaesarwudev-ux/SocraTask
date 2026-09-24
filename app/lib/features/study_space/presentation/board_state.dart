import 'package:flutter/material.dart';

/// Transient board interaction state (v2). Research applied (tldraw state
/// machine): idle -> drawing | shaping | texting | dragging. All transient
/// state lives here in memory; Drift commits happen ONLY on gesture end.
/// The page widget listens to this, NOT to pointer moves — pointer moves
/// update [liveStroke] (a ValueNotifier) which repaints just the ink layer.
enum BoardTool {
  select,
  marker,
  pencil,
  brush,
  highlighter,
  eraser,
  text,
  shapeRect,
  shapeRoundRect,
  shapeCircle,
  shapeEllipse,
  shapeTriangle,
  shapeLine,
  shapeArrow,
  flowProcess,
  flowDecision,
  flowData,
}

enum EraserMode { stroke, pixel }

extension BoardToolX on BoardTool {
  bool get isPen =>
      this == BoardTool.marker ||
      this == BoardTool.pencil ||
      this == BoardTool.brush ||
      this == BoardTool.highlighter;
  bool get isShape => name.startsWith('shape') || name.startsWith('flow');
  String get shapeKind {
    switch (this) {
      case BoardTool.shapeRect:
        return 'rect';
      case BoardTool.shapeRoundRect:
        return 'roundRect';
      case BoardTool.shapeCircle:
        return 'circle';
      case BoardTool.shapeEllipse:
        return 'ellipse';
      case BoardTool.shapeTriangle:
        return 'triangle';
      case BoardTool.shapeLine:
        return 'line';
      case BoardTool.shapeArrow:
        return 'arrow';
      case BoardTool.flowProcess:
        return 'flowProcess';
      case BoardTool.flowDecision:
        return 'flowDecision';
      case BoardTool.flowData:
        return 'flowData';
      default:
        return 'rect';
    }
  }
}

class BoardState extends ChangeNotifier {
  BoardTool tool = BoardTool.select;
  Color color = const Color(0xFF1A1A1A);
  double width = 4;
  EraserMode eraserMode = EraserMode.stroke;

  String font = 'Roboto';
  double fontSize = 16;
  bool bold = false;
  bool italic = false;
  bool underline = false;
  bool strike = false;

  /// Selected widget/shape ids. Shift-click toggles, plain click replaces.
  Set<int> selected = {};

  /// Live stroke buffer. Mutated in place + notifyLive() so ONLY the
  /// LiveInk repaint boundary rebuilds (60fps, no page rebuild).
  final ValueNotifier<List<List<double>>> liveStroke = ValueNotifier(const []);

  /// True while the user is panning/zooming the canvas (set by the board
  /// via InteractiveViewer callbacks). Drives grab -> grabbing cursor.
  final ValueNotifier<bool> panning = ValueNotifier(false);

  /// Shape / text drag preview rect (canvas coords).
  Rect? previewRect;

  void setTool(BoardTool t) {
    tool = t;
    notifyListeners();
  }

  void beginStroke(double x, double y, double pressure) {
    liveStroke.value = [
      [x, y, pressure]
    ];
  }

  void appendStroke(double x, double y, double pressure) {
    liveStroke.value = [...liveStroke.value, [x, y, pressure]];
  }

  List<List<double>> takeStroke() {
    final pts = liveStroke.value;
    liveStroke.value = const [];
    return pts;
  }

  void setPreview(Rect? r) {
    previewRect = r;
    notifyListeners();
  }

  void selectOnly(List<int> ids) {
    selected = ids.toSet();
    notifyListeners();
  }

  void toggleSelect(List<int> ids) {
    final next = Set<int>.from(selected);
    for (final id in ids) {
      if (!next.remove(id)) next.add(id);
    }
    selected = next;
    notifyListeners();
  }

  void clearSelection() {
    if (selected.isEmpty) return;
    selected = {};
    notifyListeners();
  }

  void deselect(int id) {
    if (selected.remove(id)) notifyListeners();
  }

  @override
  void dispose() {
    liveStroke.dispose();
    panning.dispose();
    super.dispose();
  }
}
