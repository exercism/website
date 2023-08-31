import React from 'react'
import { createRoot } from 'react-dom/client'
import Bugsnag from '@bugsnag/js'
import BugsnagPluginReact from '@bugsnag/plugin-react'
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

let ErrorBoundary: ErrorBoundaryType = () => <></>

if (process.env.BUGSNAG_API_KEY) {
  Bugsnag.start({
    apiKey: process.env.BUGSNAG_API_KEY,
    releaseStage: process.env.NODE_ENV,
    plugins: [new BugsnagPluginReact()],
    enabledReleaseStages: ['production'],
    collectUserIp: false,
    onError: function (event) {
      const tag = document.querySelector<HTMLMetaElement>(
        'meta[name="user-id"]'
      )

      if (!tag) {
        return true
      }

      event.setUser(tag.content)
    },
  })
  const reactPlugin = Bugsnag.getPlugin('react')
  if (reactPlugin) {
    ErrorBoundary = reactPlugin.createErrorBoundary(React)
  } else {
    throw new Error("Failed to load Bugsnag's react plugin")
  }
}

function initEventListeners() {
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

const render = (elem: HTMLElement, component: React.ReactNode) => {
  const root = createRoot(elem)
  root.render(
    <React.StrictMode>
      <QueryClientProvider client={window.queryClient}>
        <ErrorBoundary>{component}</ErrorBoundary>
      </QueryClientProvider>
    </React.StrictMode>
  )
  document.addEventListener('turbo:before-frame-render', () => {
    root.unmount()
  })
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

    const reactId = elem.dataset['reactId']
    const reactData = elem.dataset.reactData
    const generator = reactId ? mappings[reactId] : null

    if (reactId && generator && reactData) {
      const data = JSON.parse(reactData)
      render(elem, generator(data, elem))
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
