import React from 'react'
import ReactDOM from 'react-dom'
import Bugsnag from '@bugsnag/js'
import BugsnagPluginReact from '@bugsnag/plugin-react'
import { ExercismTippy } from '../components/misc/ExercismTippy'
import { ReactQueryCacheProvider } from 'react-query'

let ErrorBoundary = null
if (process.env.BUGSNAG_API_KEY) {
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
  ErrorBoundary = Bugsnag.getPlugin('react').createErrorBoundary(React)
} else {
  ErrorBoundary = <></>
}

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
const styleElemId = 'turbo-style'
const setTurboStyle = (style) => {
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
  window.scrollTo({
    top: 0,
    left: 0,
    behavior: 'auto',
  })
  setTurboStyle('')
})

export const initReact = (mappings) => {
  // console.log(Date.now(), 'initReact')
  const renderThings = (parentElement) => {
    renderComponents(parentElement, mappings)
    renderTooltips(parentElement, mappings)
  }

  // document.addEventListener('turbo:before-fetch-response', (e) => {
  //   console.log(Date.now(), 'turbo:before-fetch-response')
  // })
  // document.addEventListener('turbo:render', (e) => {
  //   console.log(Date.now(), 'turbo:render')
  // })

  // This adds rendering for all future turbo clicks
  document.addEventListener('turbo:load', () => {
    // console.log(Date.now(), 'turbo:load')
    renderThings()
  })

  // This renders if turbo has already finished at the
  // point at which this calls. See packs/core.tsx
  if (window.turboLoaded) {
    // console.log(Date.now(), 'Loading React from DOM Load')
    renderThings()
  }
}

const render = (elem, component) => {
  const callback = () => {
    // console.log(Date.now(), 'rendered')
    elem.classList.add('--hydrated')
  }
  // console.log(Date.now(), 'rendering')
  const hydrate = elem.dataset['reactHydrate'] == 'true'
  if (hydrate) {
    //console.log('hydrating')
    ReactDOM.hydrate(<>{component}</>, elem, callback)
  } else {
    ReactDOM.render(
      <React.StrictMode>
        <ReactQueryCacheProvider queryCache={window.queryCache}>
          <ErrorBoundary>{component}</ErrorBoundary>
        </ReactQueryCacheProvider>
      </React.StrictMode>,
      elem,
      callback
    )
  }

  const unloadOnce = () => {
    ReactDOM.unmountComponentAtNode(elem)
    document.removeEventListener('turbo:before-render', unloadOnce)
  }
  // document.addEventListener('turbo:before-render', unloadOnce)
}

export function renderComponents(parentElement, mappings) {
  //console.log(Date.now(), 'renderComponents()')
  if (!parentElement) {
    parentElement = document.body
  }
  // As getElementsByClassName returns a live collection, it is recommended to use Array.from
  // when iterating through it, otherwise the number of elements may change mid-loop.
  const elems = Array.from(
    parentElement.getElementsByClassName('c-react-component')
  )
  for (let elem of elems) {
    const reactId = elem.dataset['reactId']
    const generator = mappings[reactId]
    if (!generator) {
      continue
    }
    const data = JSON.parse(elem.dataset.reactData)
    render(elem, generator(data, elem))
  }
}

function renderTooltip(mappings, elem) {
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
      interactive={elem.dataset.interactive}
      renderReactComponents={elem.dataset.renderReactComponents}
      content={component}
      reference={elem}
    />
  )
}

function renderTooltips(parentElement, mappings) {
  if (!parentElement) {
    parentElement = document.body
  }

  parentElement
    .querySelectorAll('[data-tooltip-type][data-endpoint]')
    .forEach((elem) => renderTooltip(mappings, elem))
}
