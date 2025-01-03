/*
 *
 * {"message":"error.syntax.MissingLeftBraceToStartIfBody","type":"MissingLeftBraceToStartIfBody","location":{"line":2,"relative":{"begin":11,"end":12},"absolute":{"begin":35,"end":36}}}
 *
 */

import type { StaticError } from '@/interpreter/error'

export function describeError(error: StaticError) {
  let output = `<h2>${error.type}</h2>`
  output += `<div class="content"><p>${error.message}</p>`
  if (error.context && error.context.didYouMean) {
    if (error.context.didYouMean.variable) {
      output += `<p>Did you mean <code>${error.context.didYouMean.variable}</code>?</p>`
    }
    if (error.context.didYouMean.function) {
      output += `<p>Did you mean to call the <code>${error.context.didYouMean.function}</code> function?</p>`
    }
  }
  output += `</div>`
  return output
}
