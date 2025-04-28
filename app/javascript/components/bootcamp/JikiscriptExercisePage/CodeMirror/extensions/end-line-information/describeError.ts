/*
 *
 * {"message":"error.syntax.MissingLeftBraceToStartIfBody","type":"MissingLeftBraceToStartIfBody","location":{"line":2,"relative":{"begin":11,"end":12},"absolute":{"begin":35,"end":36}}}
 *
 */

import { marked } from 'marked'

import type { StaticError } from '@/interpreter/error'
import { SyntaxError } from '@/interpreter/error'

export function describeError(
  error: StaticError,
  language: 'jikiscript' | 'javascript',
  context?: string
) {
  const who = language === 'jikiscript' ? 'Jiki' : 'We'
  let errorHeading
  if (error instanceof SyntaxError) {
    errorHeading = `${who} couldn't understand your code`
  } else if (error.type == 'LogicError') {
    errorHeading = "Something didn't go as expected!"
  } else {
    errorHeading = `${who} hit a problem running your code.`
  }
  if (context) {
    errorHeading = `${context}: ${errorHeading}`
  }

  const renderer = new marked.Renderer()

  renderer.code = (code) => {
    return `<pre><code class="language-jikiscript hljs">${code.text}</code></pre>`
  }
  marked.setOptions({ renderer })

  let output = `<h2>${errorHeading}</h2>`
  output += `<div class="content">${marked.parse(error.message ?? '')}`
  output += `</div>`
  return output
}
