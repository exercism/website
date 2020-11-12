import React from 'react'
import ReactDOM from 'react-dom'
import { createPopper } from '@popperjs/core'

const render = (elem, component) => {
  ReactDOM.render(<React.StrictMode>{component}</React.StrictMode>, elem)

  const unloadOnce = () => {
    ReactDOM.unmountComponentAtNode(elem)
    document.removeEventListener('turbolinks:before-render', unloadOnce)
  }
  document.addEventListener('turbolinks:before-render', unloadOnce)
}

export const initReact = (mappings) => {
  document.addEventListener('turbolinks:load', () => {
    for (const [name, generator] of Object.entries(mappings)) {
      const selector = '[data-react-' + name + ']'
      document.querySelectorAll(selector).forEach((elem) => {
        const data = JSON.parse(elem.dataset.reactData)
        render(elem, generator(data))
      })
    }

    document
      .querySelectorAll('[data-tooltip-type][data-tooltip-url]')
      .forEach((elem) => {
        const name = elem.dataset['tooltipType'] + '-tooltip'
        const generator = mappings[name]

        const componentData = { endpoint: elem.dataset['tooltipUrl'] }
        const component = generator(componentData)

        // Create an element render the React component in
        const tooltipElem = document.createElement('div')
        elem.insertAdjacentElement('afterend', tooltipElem)

        // Link the tooltip element with the reference element
        const popperOptions = {
          placement: elem.dataset['placement'] || 'auto',

          // TODO Set the default skidding to 50% and the default
          // offset to 20px (https://popper.js.org/docs/v2/modifiers/offset/)
        }
        createPopper(elem, tooltipElem, popperOptions)

        const showTooltip = () => render(tooltipElem, component)
        const hideTooltip = () => ReactDOM.unmountComponentAtNode(tooltipElem)

        elem.addEventListener('mouseenter', () => showTooltip())
        elem.addEventListener('onfocus', () => showTooltip())

        elem.addEventListener('mouseleave', () => hideTooltip())
        elem.addEventListener('onblur', () => hideTooltip())
      })
  })
}
