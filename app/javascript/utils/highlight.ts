import * as highlighter from 'highlight.js'

function duplicateMultilineNodes(element: HTMLElement) {
  element.childNodes.forEach((child) => {
    if (child.textContent === null) {
      return
    }

    if (getLinesCount(child.textContent) === 0) {
      return
    }

    if (child.childNodes.length === 0) {
      return duplicateMultilineNode(child.parentNode as HTMLElement)
    }

    duplicateMultilineNodes(child as HTMLElement)
  })
}

function duplicateMultilineNode(element: HTMLElement) {
  const isHighlightJSNode = /hljs-/.test(element.className)

  if (!isHighlightJSNode) {
    return
  }

  element.innerHTML = getLines(element.innerHTML)
    .map(
      (line) =>
        `<span class="${element.className}">${
          line.length > 0 ? line : ' '
        }</span>\n`
    )
    .join('')
    .trim()

  return
}

function getLines(text: string) {
  return text.split(/\r\n|\r|\n/g)
}

function getLinesCount(text: string) {
  return (text.trim().match(/\r\n|\r|\n/g) || []).length
}

function wrapLineNumbers(code: string) {
  const element = document.createElement('div')
  element.innerHTML = code.trim()

  duplicateMultilineNodes(element)

  const rows = getLines(element.innerHTML)
    .map((line, i) => {
      return `<tr>
          <td>${i + 1}</td>
          <td>${line}</td>
        </tr>`
    })
    .join('')

  return `<table>${rows}</table>`
}

export const highlight = (language: string, code: string): string => {
  const content = highlighter.highlight(language, code).value

  return wrapLineNumbers(content)
}
