String cleanText(String? rawAddress) {
  if (rawAddress == null || rawAddress.isEmpty) return '';
  return rawAddress
      .replaceAll(RegExp(r'[\r\n]+'), ', ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}