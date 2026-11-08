/// The connector families the app draws a glyph for.
///
/// Stored values arrive as database codes such as `TYPE_2_AC` or `CCS2`; the
/// mapping from a stored code lives in [ConnectorKindLabel] in the formatting
/// layer so no screen has to know a database value.
enum ConnectorKind { ccs2, type2, chademo, plug }
