import { isVoidElement } from '../voidElements'

export function checkNonVoidSelfClose(html: string): void {
  const selfClosingRegex = /<([a-zA-Z][a-zA-Z0-9-]*)\b[^<>]*?\/>/g

  let match
  while ((match = selfClosingRegex.exec(html)) !== null) {
    const tagName = match[1]

    if (!isVoidElement(tagName)) {
      throw new Error(`Non-void element <${tagName}/> cannot be self-closed.`)
    }
  }
}
