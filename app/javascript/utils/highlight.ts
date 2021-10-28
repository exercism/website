import * as highlighter from 'highlight.js'
import React, { useEffect, useRef } from 'react'
import setupABAP from 'highlightjs-sap-abap'

highlighter.default.registerLanguage('abap', setupABAP)

highlighter.default.configure({
  throwUnescapedHTML: true,
})

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

function wrapLineNumbers(code: string, start = 1) {
  const element = document.createElement('div')
  element.innerHTML = code

  /*
    Highlight JS wraps multiline code (e.g. comments) in one parent node.
    Since we need to append line numbers to every line, this method recursively
    expands the tree and wraps each line in the multiline node with the class of
    the parent node.
  */
  duplicateMultilineNodes(element)

  const rows = getLines(element.innerHTML)
    .map((line, i) => {
      return `<li>
          <div class="idx">${start + i}</div>
          <div class="loc">${line}</div>
        </li>`
    })
    .join('')

  return `<ul>${rows}</ul>`
}

const highlightBlock = (block: HTMLElement): void => {
  const hasLineNumbers =
    block.dataset.highlightLineNumbers === '' ||
    block.dataset.highlightLineNumbers === 'true'

  let lineNumberStart
  if (block.dataset.highlightLineNumberStart) {
    lineNumberStart = parseInt(block.dataset.highlightLineNumberStart)
  }

  highlighter.default.highlightElement(block)

  if (hasLineNumbers) {
    block.innerHTML = wrapLineNumbers(block.innerHTML, lineNumberStart)
  }

  block.dataset.highlighted = 'true'
}

export const highlightAll = (parent: ParentNode = document): void => {
  parent.querySelectorAll<HTMLElement>('pre code').forEach((block) => {
    if (block.dataset.highlighted === 'true') {
      return
    }

    highlightBlock(block)
  })
}

export const useHighlighting = <T>() => {
  const parentRef = useRef<T | null>(null)

  useEffect(() => {
    if (!parentRef.current) {
      return
    }

    highlightAll((parentRef.current as unknown) as ParentNode)
  }, [])

  return parentRef
}
