import hljs from 'highlight.js/lib/core'
import { useLayoutEffect, useRef } from 'react'
import { isLookbehindSupported } from './regex-check'
import { aliases, grammars } from './highlight-grammars'

hljs.configure({
  throwUnescapedHTML: false,
})

// highlight.js reads a block's language from its class or its parent's class,
// e.g. "language-ruby", "lang-ruby" or just "ruby". This mirrors its rules.
const LANGUAGE_CLASS = /\blang(?:uage)?-([\w-]+)\b/i

const registrations = new Map<string, Promise<void>>()
const registered = new Set<string>()

function grammarName(language: string): string | undefined {
  const name = language.toLowerCase()
  if (Object.prototype.hasOwnProperty.call(grammars, name)) return name
  if (Object.prototype.hasOwnProperty.call(aliases, name)) return aliases[name]
  return undefined
}

// A grammar can embed others (e.g. HTML embeds CSS and JavaScript), and those
// can embed it back, so this collects the whole set before loading any of it.
function grammarsNeededFor(language: string): string[] {
  const needed = new Set<string>()
  const visit = (name: string | undefined) => {
    if (name === undefined || needed.has(name)) return
    needed.add(name)
    grammars[name].requires?.forEach((dependency) =>
      visit(grammarName(dependency))
    )
  }
  visit(grammarName(language))
  return [...needed]
}

// Each grammar is fetched once per page. Blocks that ask for it while it is
// still loading wait on the same request. If the request fails (for example
// after a deploy), the next block to ask will try again.
function registerGrammar(name: string): Promise<void> {
  let registration = registrations.get(name)
  if (registration) return registration

  registration = grammars[name]
    .load()
    .then((module) => {
      hljs.registerLanguage(name, module.default)
      registered.add(name)
    })
    .catch((error) => {
      registrations.delete(name)
      throw error
    })
  registrations.set(name, registration)
  return registration
}

function loadLanguage(language: string): Promise<void> {
  if (!isLookbehindSupported()) return Promise.resolve()

  return Promise.all(grammarsNeededFor(language).map(registerGrammar)).then(
    () => undefined
  )
}

function blockLanguage(block: HTMLElement): string | undefined {
  const parent = block.parentElement
  const classes = `${block.className} ${parent ? parent.className : ''}`

  const match = LANGUAGE_CLASS.exec(classes)
  if (match) return match[1]

  return classes.split(/\s+/).find((name) => grammarName(name) !== undefined)
}

function isLoaded(language: string): boolean {
  return grammarsNeededFor(language).every((name) => registered.has(name))
}

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

function highlightBlock(block: HTMLElement): void {
  const hasLineNumbers =
    block.dataset.highlightLineNumbers === '' ||
    block.dataset.highlightLineNumbers === 'true'

  let lineNumberStart
  if (block.dataset.highlightLineNumberStart) {
    lineNumberStart = parseInt(block.dataset.highlightLineNumberStart)
  }

  hljs.highlightElement(block)

  if (hasLineNumbers) {
    block.innerHTML = wrapLineNumbers(block.innerHTML, lineNumberStart)
  }

  block.dataset.highlighted = 'true'
}

// The latest request for each block. If a block is asked to re-highlight while
// its grammar is loading, only the last request runs once the grammar arrives.
const pendingRequests = new WeakMap<HTMLElement, symbol>()

// Highlights the block straight away if its grammar is already loaded.
// Otherwise it loads the grammar first. If the grammar fails to load, the
// block stays as plain text.
function highlightWhenReady(block: HTMLElement, force: boolean): Promise<void> {
  const request = Symbol()
  pendingRequests.set(block, request)

  const run = () => {
    if (pendingRequests.get(block) !== request) return
    pendingRequests.delete(block)

    if (force) {
      block.removeAttribute('data-highlighted')
    } else if (block.dataset.highlighted === 'true') {
      return
    }
    highlightBlock(block)
  }

  const language = blockLanguage(block)
  if (language === undefined || isLoaded(language)) {
    run()
    return Promise.resolve()
  }

  return loadLanguage(language).then(run, () => {
    if (pendingRequests.get(block) === request) pendingRequests.delete(block)
  })
}

// Both functions highlight synchronously when every grammar they need is
// already loaded. The first time a page needs a language, they highlight once
// its grammar has loaded. The returned promise resolves when every block is
// done, for callers (and tests) that need to wait.
export const highlightAll = (parent: ParentNode = document): Promise<void> => {
  if (!isLookbehindSupported()) return Promise.resolve()

  const blocks = Array.from(
    parent.querySelectorAll<HTMLElement>('pre code')
  ).filter((block) => block.dataset.highlighted !== 'true')

  return Promise.all(
    blocks.map((block) => highlightWhenReady(block, false))
  ).then(() => undefined)
}

export const highlightAllAlways = (
  parent: ParentNode = document
): Promise<void> => {
  if (!isLookbehindSupported()) return Promise.resolve()

  const blocks = Array.from(parent.querySelectorAll<HTMLElement>('pre code'))

  return Promise.all(
    blocks.map((block) => highlightWhenReady(block, true))
  ).then(() => undefined)
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
