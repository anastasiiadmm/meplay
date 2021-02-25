String shorten(String string, int length, {String ellipsis: "\u2026"}) {
  if (string.length > length) {
    return (string.substring(0, length - ellipsis.length) + ellipsis);
  }
  return string;
}
