import React from 'react'
import ReactDOM from 'react-dom'
import Bugsnag from '@bugsnag/js'
import BugsnagPluginReact from '@bugsnag/plugin-react'
import { ExercismTippy } from '../components/misc/ExercismTippy'

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

export const initReact = (mappings) => {
  const renderThings = (parentElement) => {
    renderComponents(parentElement, mappings)
    renderTooltips(parentElement, mappings)
  }

  // This adds rendering for all future turbo clicks
  document.addEventListener('turbo:load', () => {
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
      <ErrorBoundary>{component}</ErrorBoundary>
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
