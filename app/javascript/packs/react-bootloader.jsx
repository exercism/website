import React from 'react'
import ReactDOM from 'react-dom'

const render = (elem, component) => {
  ReactDOM.render(component, elem)

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
      console.log(selector)
      document.querySelectorAll(selector).forEach((elem) => {
        const data = JSON.parse(elem.dataset.reactData)
        render(elem, generator(data))
      })
    }
  })
}
