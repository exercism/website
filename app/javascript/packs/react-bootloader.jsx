import React from 'react'
import ReactDOM from 'react-dom'
import { createPopper } from '@popperjs/core'

export const initReact = (mappings) => {
  document.addEventListener('turbolinks:load', () => {
    renderComponents(mappings)
    renderTooltips(mappings)
    renderDropdowns(mappings)
  })
}

const render = (elem, component) => {
  ReactDOM.render(<React.StrictMode>{component}</React.StrictMode>, elem)

  const unloadOnce = () => {
    ReactDOM.unmountComponentAtNode(elem)
    document.removeEventListener('turbolinks:before-render', unloadOnce)
  }
  document.addEventListener('turbolinks:before-render', unloadOnce)
}

const renderComponents = (mappings) => {
  for (const [name, generator] of Object.entries(mappings)) {
    const selector = '[data-react-' + name + ']'
    document.querySelectorAll(selector).forEach((elem) => {
      const data = JSON.parse(elem.dataset.reactData)
      render(elem, generator(data, elem))
    })
  }
}

const renderTooltips = (mappings) => {
  document
    .querySelectorAll('[data-tooltip-type][data-endpoint]')
    .forEach((elem) => {
      const name = elem.dataset['tooltipType'] + '-tooltip'
      const generator = mappings[name]
      const component = generator(elem.dataset, elem)

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
}

const renderDropdowns = (mappings) => {
  document
    .querySelectorAll(
      '[data-dropdown-type][data-endpoint],[data-dropdown-type][data-prerendered]'
    )
    .forEach((elem) => {
      const name = elem.dataset['dropdownType'] + '-dropdown'
      const generator = mappings[name]
      const component = generator(elem.dataset, elem)

      // Create an element render the React component in
      const dropdownElem = document.createElement('div')
      elem.insertAdjacentElement('afterend', dropdownElem)

      // Link the dropdown element with the reference element
      const popperOptions = {
        placement: elem.dataset['placement'] || 'bottom-end',

        // TODO Set the default skidding to 50% and the default
        // offset to 20px (https://popper.js.org/docs/v2/modifiers/offset/)
      }
      createPopper(elem, dropdownElem, popperOptions)

      let dropdownShown = false
      const showDropdown = () => {
        render(dropdownElem, component)
        dropdownShown = true
      }
      const hideDropdown = () => {
        ReactDOM.unmountComponentAtNode(dropdownElem)
        dropdownShown = false
      }
      const toggleDropdown = () =>
        dropdownShown ? hideDropdown() : showDropdown()
      document.addEventListener('click', (event) => {
        event.preventDefault()

        if (elem.contains(event.target)) {
          toggleDropdown()
        } else {
          hideDropdown()
        }
      })
    })
}
