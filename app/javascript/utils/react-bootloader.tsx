import React from 'react'
import { createRoot } from 'react-dom/client'
import * as Sentry from '@sentry/react'
import { ExercismTippy } from '../components/misc/ExercismTippy'
import { QueryClientProvider } from '@tanstack/react-query'

type ErrorBoundaryType = React.ComponentType<any>

type GeneratorFunc = (data: any, elem: HTMLElement) => JSX.Element
type Mappings = Record<string, GeneratorFunc>

type TurboFrameRenderDetail = {
  fetchResponse: {
    response: {
      headers: {
        get: (name: string) => string | null
      }
    }
  }
}

if (process.env.SENTRY_DSN) {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.NODE_ENV,
    enabled: process.env.NODE_ENV === 'production',
    sendDefaultPii: false,
    beforeSend: (event) => {
      // Drop non-actionable dynamic import failures (network issues, stale chunks)
      const isDynamicImportError = event.exception?.values?.some((ex) =>
        ex.value?.includes('Failed to fetch dynamically imported module')
      )
      if (isDynamicImportError) return null

      // Drop non-actionable Cloudflare Turnstile widget errors (browser extensions, privacy settings, etc.)
      const isTurnstileError = event.exception?.values?.some(
        (ex) =>
          ex.type?.includes('TurnstileError') ||
          ex.value?.includes('TurnstileError') ||
          ex.value?.includes('[Cloudflare Turnstile]')
      )
      if (isTurnstileError) return null

      const tag = document.querySelector<HTMLMetaElement>(
        'meta[name="user-id"]'
      )

      if (tag) {
        event.user = { id: tag.content }
        return event
      }

      // Sample 1% of errors from logged-out users
      return Math.random() < 0.01 ? event : null
    },
  })
}

let ErrorBoundary: ErrorBoundaryType = ({ children }) => <>{children}</>
if (process.env.SENTRY_DSN) {
  ErrorBoundary = Sentry.ErrorBoundary
}

// Asynchronously appends a stylesheet to the head and resolves
// the promise when it's finished loading.
let loadStylesheet = function (url) {
  return new Promise((resolve, reject) => {
    let link = document.createElement('link')
    link.type = 'text/css'
    link.rel = 'stylesheet'
    link.onload = resolve
    link.href = url

    document.getElementsByTagName('head')[0].appendChild(link)
  })
}

function initEventListeners() {
  // As we have conditional stylesheets per page, we need to extract and
  // render those when the frame changes. We want the CSS to load BEFORE
  // then HTML renders, so we get any stylesheets downloaded and THEN render
  // continnue processing the frame render.
  document.addEventListener('turbo:before-frame-render', (e: Event) => {
    if (!(e instanceof CustomEvent)) return

    const hrefs = Array.from(
      e.detail.newFrame.querySelectorAll('link[rel="stylesheet"]')
    ).map((link) => (link as HTMLLinkElement).getAttribute('href'))

    // If we have no stylesheets, just continue
    if (hrefs.length == 0) {
      return
    }

    // Pause rendering until stylesheets are loaded
    e.preventDefault()

    // Load stylesheets in parallel asynchronously
    const promises = hrefs.map((href) => loadStylesheet(href))

    // When they're all loaded, resume
    Promise.all(promises).then(() => e.detail.resume())
  })

  // This changes any extra things that need changing from the
  // turbo frame, such as body class or page title
  document.addEventListener('turbo:frame-render', (e) => {
    const event = e as CustomEvent<TurboFrameRenderDetail>
    const bodyClass = event.detail.fetchResponse.response.headers.get(
      'exercism-body-class'
    )
    if (bodyClass) {
      document.body.className = bodyClass
    }
  })

  document.addEventListener('turbo:before-fetch-request', () => {
    setTurboStyle('* { cursor:wait !important }')
  })

  document.addEventListener('turbo:before-render', () => {
    window.scrollTo({
      top: 0,
      left: 0,
      behavior: 'auto',
    })
    setTurboStyle('')
  })
}

/********************************************************/
/** Add a loading cursor when a turbo-frame is loading **/
/********************************************************/
const styleElemId = 'turbo-style'
const setTurboStyle = (style: string) => {
  let styleElem = document.getElementById(styleElemId)
  if (!styleElem) {
    styleElem = document.createElement('style')
    styleElem.id = styleElemId
    document.head.appendChild(styleElem)
  }
  styleElem.textContent = style
}

export function initReact(mappings: Mappings): void {
  const renderThings = () => {
    renderComponents(document.body, mappings)
    renderTooltips(document.body, mappings)
  }

  // This adds rendering for all future turbo clicks
  document.addEventListener('turbo:load', () => {
    renderThings()
  })

  // This renders if turbo has already finished at the
  // point at which this calls. See packs/core.tsx
  if (window.turboLoaded) {
    renderThings()
  }
}

function onGoogleTranslateDetected(): void {
  // See: https://github.com/facebook/react/issues/11538#issuecomment-417504600
  if (typeof Node === 'function' && Node.prototype) {
    const originalRemoveChild: (child: Node) => Node =
      Node.prototype.removeChild
    Node.prototype.removeChild = function <T extends Node>(
      this: Node,
      child: T
    ): T {
      if (child.parentNode !== this) {
        if (console) {
          console.error(
            'Cannot remove a child from a different parent',
            child,
            this
          )
        }
        return child
      }
      return originalRemoveChild.apply(this, [child]) as T
    }

    const originalInsertBefore: (
      newNode: Node,
      referenceNode: Node | null
    ) => Node = Node.prototype.insertBefore
    Node.prototype.insertBefore = function <T extends Node>(
      this: Node,
      newNode: T,
      referenceNode: Node | null
    ): T {
      if (referenceNode && referenceNode.parentNode !== this) {
        if (console) {
          console.error(
            'Cannot insert before a reference node from a different parent',
            referenceNode,
            this
          )
        }
        return newNode
      }
      return originalInsertBefore.apply(this, [newNode, referenceNode]) as T
    }
  }
}

// Currently only Chrome produces this React bug, so let's not use this piece of code on other browsers
if (/Chrome/.test(navigator.userAgent)) {
  // We need to use MutationObserver here because translating almost only happens as a DOM mutation
  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (
        mutation.type === 'attributes' &&
        mutation.attributeName === 'class'
      ) {
        const htmlElement = document.documentElement
        const hasTranslationClasses =
          htmlElement.classList.contains('translated-ltr') ||
          htmlElement.classList.contains('translated-rtl')

        if (hasTranslationClasses) {
          onGoogleTranslateDetected()
        }
      }
    })
  })

  observer.observe(document.documentElement, {
    attributes: true,
    attributeFilter: ['class'],
  })
}

const roots = new WeakMap()
const eventListeners = new WeakSet()

const render = (elem: HTMLElement, component: React.ReactNode) => {
  let root = roots.get(elem)
  if (!root) {
    root = createRoot(elem)
    roots.set(elem, root)
  }

  root.render(
    <React.StrictMode>
      <QueryClientProvider client={window.queryClient}>
        <ErrorBoundary>{component}</ErrorBoundary>
      </QueryClientProvider>
    </React.StrictMode>
  )

  // make sure we only add the event listener once per element
  if (!eventListeners.has(elem)) {
    eventListeners.add(elem)
    document.addEventListener('turbo:before-frame-render', () => {
      if (elem.dataset.persistent === 'true') return
      const rootToCleanup = roots.get(elem)
      if (rootToCleanup) {
        rootToCleanup.unmount()
        roots.delete(elem)
        eventListeners.delete(elem)
      }
    })
  }
}

export function renderComponents(
  parentElement: HTMLElement,
  mappings: Mappings
): void {
  if (!parentElement) {
    parentElement = document.body
  }
  // As getElementsByClassName returns a live collection, it is recommended to use Array.from
  // when iterating through it, otherwise the number of elements may change mid-loop.
  const elems = Array.from(
    parentElement.getElementsByClassName('c-react-component')
  )
  for (const elem of elems) {
    // dataset doesn't exist on type `Element`
    if (!(elem instanceof HTMLElement)) continue

    if (
      elem.dataset.persistent === 'true' &&
      elem.dataset.rendered === 'true'
    ) {
      continue
    }

    const reactId = elem.dataset['reactId']
    const reactData = elem.dataset.reactData
    const generator = reactId ? mappings[reactId] : null

    if (reactId && generator && reactData) {
      const data = JSON.parse(reactData)
      render(elem, generator(data, elem))
      if (elem.dataset.persistent === 'true') {
        elem.dataset.rendered = 'true'
      }
    }
  }
}

function renderTooltips(parentElement: HTMLElement, mappings: Mappings) {
  if (!parentElement) {
    parentElement = document.body
  }
  parentElement
    .querySelectorAll('[data-tooltip-type][data-endpoint]')
    .forEach((elem) => renderTooltip(mappings, elem as HTMLElement))
}

function renderTooltip(mappings: Mappings, elem: HTMLElement) {
  const name = elem.dataset['tooltipType'] + '-tooltip'
  const generator = mappings[name]

  if (!generator) {
    return
  }
  const component = generator(elem.dataset, elem)

  const tooltipElem = document.createElement('span')
  elem.insertAdjacentElement('afterend', tooltipElem)

  render(
    tooltipElem,
    <ExercismTippy
      interactive={elem.dataset.interactive === 'true'}
      renderReactComponents={elem.dataset.renderReactComponents === 'true'}
      content={component}
      reference={elem}
    />
  )
}

initEventListeners()
