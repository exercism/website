export function checkVoidTagClosure(html: string): void {
  const voidRegex =
    /<(area|base|br|col|embed|hr|img|input|link|meta|source|track|wbr|circle|ellipse|line|path|polygon|polyline|rect|stop|use|image)\b[^<>]*?(?!>)$/gim

  const malformedVoidTag = html.match(voidRegex)

  if (malformedVoidTag) {
    throw new Error(`Unclosed void tag: ${malformedVoidTag[0]}`)
  }
}
