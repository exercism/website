import React from 'react'

export function renderLog(logArgs: unknown[]) {
  let line = logArgs
    .map((arg) => {
      const type = typeof arg

      if (arg === null) return 'null'
      if (arg === undefined) return 'undefined'

      if (type === 'string') return `"${arg}"`
      if (type === 'number' || type === 'boolean') return String(arg)
      if (type === 'bigint') return `${arg.toString()}n`
      if (type === 'symbol') return arg.toString()
      if (type === 'function') {
        const name = (arg as Function).name
        return `[Function${name ? `: ${name}` : ''}]`
      }

      if (arg instanceof Date) {
        return arg.toISOString()
      }

      if (arg instanceof Error) {
        return `Error: ${(arg as Error).message}`
      }

      if (arg instanceof RegExp) {
        return arg.toString()
      }

      if (arg instanceof Promise) {
        return `[Promise]`
      }

      if (typeof HTMLElement !== 'undefined' && arg instanceof HTMLElement) {
        return `<${arg.tagName.toLowerCase()}>`
      }

      try {
        return verboseStringify(arg)
      } catch {
        return '[Unrenderable object]'
      }
    })
    .join(' ')

  return <code className="language-javascript hljs">{line}</code>
}
function verboseStringify(obj) {
  return JSON.stringify(
    obj,
    (key, value) => {
      return value === undefined ? '__undefined__' : value
    },
    2
  ).replace(/"__undefined__"/g, 'undefined')
}
