export function normalizeHtmlText(html: string) {
  // remove comments
  html = html.replace(/<!--[\s\S]*?-->/g, '')
  // remove svg
  html = html.replace(/<svg[\s\S]*?<\/svg>/g, '')

  return html
}
