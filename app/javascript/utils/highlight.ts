import * as highlighter from 'highlight.js'
import { useLayoutEffect, useRef } from 'react'
import { isLookbehindSupported } from './regex-check'
import setupABAP from 'highlightjs-sap-abap'
import setupCobol from 'highlightjs-cobol'
import setupBqn from 'highlightjs-bqn'
import setupZig from 'highlightjs-zig'
import setupLean from 'highlightjs-lean'
import setupGleam from '@gleam-lang/highlight.js-gleam'
import setupChapel from 'highlightjs-chapel'
import setupGDScript from '@exercism/highlightjs-gdscript'
import setupJq from 'highlightjs-jq'
import setupArturo from '@exercism/highlightjs-arturo'
import setupUiua from '@exercism/highlightjs-uiua'
import setupJikiscript from '@exercism/highlightjs-jikiscript'
import setupFuthark from '@exercism/highlightjs-futhark'
import setupOdin from '@exercism/highlightjs-odin'
import setupSqlite from '@exercism/highlightjs-sqlite'
import setupEuphoria from '@exercism/highlightjs-euphoria'
import setupFactor from '@exercism/highlightjs-factor'
import setup8th from '@exercism/highlightjs-8th'
import setupRoc from '@exercism/highlightjs-roc'
import setupYAMLScript from '@exercism/highlightjs-yamlscript'
import setupRaku from '@exercism/highlightjs-raku'
import setupCairo from '@exercism/highlightjs-cairo'
import setupV from '@exercism/highlightjs-v'
import setupPureScript from '@exercism/highlightjs-purescript'
import setupUnison from '@exercism/highlightjs-unison'
import setupIdris from '@exercism/highlightjs-idris'
import setupCFML from '@exercism/highlightjs-cfml'
import setupRacket from '@exercism/highlightjs-racket'
import setupLFE from '@exercism/highlightjs-lfe'
import setupReScript from 'highlightjs-rescript'

if (isLookbehindSupported()) {
  highlighter.default.registerLanguage('abap', setupABAP)
  highlighter.default.registerLanguage('arturo', setupArturo)
  highlighter.default.registerLanguage('cobol', setupCobol)
  highlighter.default.registerLanguage('bqn', setupBqn)
  highlighter.default.registerLanguage('zig', setupZig)
  highlighter.default.registerLanguage('lean', setupLean)
  highlighter.default.registerLanguage('gleam', setupGleam)
  highlighter.default.registerLanguage('chapel', setupChapel)
  highlighter.default.registerLanguage('gdscript', setupGDScript)
  highlighter.default.registerLanguage('jq', setupJq)
  highlighter.default.registerLanguage('uiua', setupUiua)
  highlighter.default.registerLanguage('jikiscript', setupJikiscript)
  highlighter.default.registerLanguage('futhark', setupFuthark)
  highlighter.default.registerLanguage('odin', setupOdin)
  highlighter.default.registerLanguage('sqlite', setupSqlite)
  highlighter.default.registerLanguage('euphoria', setupEuphoria)
  highlighter.default.registerLanguage('factor', setupFactor)
  highlighter.default.registerLanguage('8th', setup8th)
  highlighter.default.registerLanguage('roc', setupRoc)
  highlighter.default.registerLanguage('yamlscript', setupYAMLScript)
  highlighter.default.registerLanguage('raku', setupRaku)
  highlighter.default.registerLanguage('cairo', setupCairo)
  highlighter.default.registerLanguage('vlang', setupV)
  highlighter.default.registerLanguage('purescript', setupPureScript)
  highlighter.default.registerLanguage('unison', setupUnison)
  highlighter.default.registerLanguage('idris', setupIdris)
  highlighter.default.registerLanguage('cfml', setupCFML)
  highlighter.default.registerLanguage('racket', setupRacket)
  highlighter.default.registerLanguage('lfe', setupLFE)
  highlighter.default.registerLanguage('rescript', setupReScript)

  // These packages contain lookbehind regex patterns that cause parse-time
  // SyntaxErrors on browsers without lookbehind support. Dynamic imports
  // ensure they are loaded in separate chunks, only after confirming support.
  import('@exercism/highlightjs-pyret').then((m) => {
    highlighter.default.registerLanguage('pyret', m.default)
  })
  import('highlightjs-redbol').then((m) => {
    highlighter.default.registerLanguage('red', m.default)
  })
  import('@ballerina/highlightjs-ballerina').then((m) => {
    highlighter.default.registerLanguage('ballerina', m.default)
  })
}

highlighter.default.configure({
  throwUnescapedHTML: false,
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
  if (!isLookbehindSupported()) return
  parent.querySelectorAll<HTMLElement>('pre code').forEach((block) => {
    if (block.dataset.highlighted === 'true') {
      return
    }

    highlightBlock(block)
  })
}

export const highlightAllAlways = (parent: ParentNode = document): void => {
  if (!isLookbehindSupported()) return
  parent.querySelectorAll<HTMLElement>('pre code').forEach((block) => {
    block.removeAttribute('data-highlighted')
    highlightBlock(block)
  })
}

// this will be replaced by the one in @/hooks. after all conflicts are resolved
// and is missing 'html' dependency which is needed so it actually highlights code block when parsed html arrives
export const useHighlighting = <T>(): React.MutableRefObject<T | null> => {
  const parentRef = useRef<T | null>(null)

  useLayoutEffect(() => {
    if (!parentRef.current) {
      return
    }

    highlightAll(parentRef.current as unknown as ParentNode)
  }, [])

  return parentRef
}
