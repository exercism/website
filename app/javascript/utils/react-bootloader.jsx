import React from 'react'
import ReactDOM from 'react-dom'
import Bugsnag from '@bugsnag/js'
import BugsnagPluginReact from '@bugsnag/plugin-react'
import { ExercismTippy } from '../components/misc/ExercismTippy'
import { ReactQueryCacheProvider } from 'react-query'

Bugsnag.start({
  apiKey: process.env.BUGSNAG_API_KEY,
  releaseStage: process.env.NODE_ENV,
  plugins: [new BugsnagPluginReact()],
  enabledReleaseStages: ['production'],
  collectUserIp: false,
  onError: function (event) {
    const tag = document.querySelector('meta[name="user-id"]')

    if (!tag) {
      return true
    }

    event.setUser(tag.content)
  },
})

const ErrorBoundary = Bugsnag.getPlugin('react').createErrorBoundary(React)

// This changes any extra things that need changing from the
// turbo frame, such as body class or page title
document.addEventListener('turbo:frame-render', (e) => {
  const bodyClass = e.detail.fetchResponse.response.headers.get(
    'exercism-body-class'
  )
  document.querySelector('body').className = bodyClass
})

/********************************************************/
/** Add a loading cursor when a turbo-frame is loading **/
/********************************************************/
const setTurboStyle = (style) => {
  const styleElemId = 'turbo-style'
  if (!document.querySelector(`#${styleElemId}`)) {
    const elem = document.createElement('style')
    elem.id = styleElemId
    document.head.appendChild(elem)
  }

  document.querySelector(`#${styleElemId}`).textContent = style
}
document.addEventListener('turbo:before-fetch-request', () => {
  setTurboStyle('* { cursor:wait !important }')
})
document.addEventListener('turbo:before-render', () => {
  setTurboStyle('')
})

export const initReact = (mappings) => {
  console.log('Init React')
  const renderThings = (parentElement) => {
    renderComponents(parentElement, mappings)
    renderTooltips(parentElement, mappings)
  }

  // This adds rendering for all future turbo clicks
  document.addEventListener('turbo:load', (e) => {
    console.log('Loading React from Turbo Load')
    renderThings()
  })

  // This renders if turbo has already finished at the
  // point at which this calls. See packs/core.tsx
  if (window.turboLoaded) {
    console.log('Loading React from DOM Load')
    renderThings()
  }
}

const render = (elem, component) => {
  ReactDOM.render(
    <React.StrictMode>
      <ReactQueryCacheProvider queryCache={window.queryCache}>
        <ErrorBoundary>{component}</ErrorBoundary>
      </ReactQueryCacheProvider>
    </React.StrictMode>,
    elem,
    () => {
      setTimeout(() => {
        elem.classList.add('--hydrated')
      }, 1)
    }
  )

  const unloadOnce = () => {
    ReactDOM.unmountComponentAtNode(elem)
    document.removeEventListener('turbo:before-render', unloadOnce)
  }
  document.addEventListener('turbo:before-render', unloadOnce)
}

const renderComponents = (parentElement, mappings) => {
  if (!parentElement) {
    parentElement = document.body
  }

  for (const [name, generator] of Object.entries(mappings)) {
    const selector = '[data-react-' + name + ']'
    parentElement.querySelectorAll(selector).forEach((elem) => {
      const data = JSON.parse(elem.dataset.reactData)
      render(elem, generator(data, elem))
    })
  }
}

const renderTooltips = (parentElement, mappings) => {
  if (!parentElement) {
    parentElement = document.body
  }

  parentElement
    .querySelectorAll('[data-tooltip-type][data-endpoint]')
    .forEach((elem) => {
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
        <ExercismTippy content={component} reference={elem} />
      )
    })
}
