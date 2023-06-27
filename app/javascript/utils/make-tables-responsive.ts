import { debounce } from './debounce'

export function makeTablesResponsive(): void {
  let originalParents = new Map()

  const applyTableStyles = () => {
    const tables = Array.from(
      document.querySelectorAll('.c-textual-content table')
    ) as HTMLTableElement[]

    tables.forEach((table) => {
      if (!table) {
        return
      }

      // skip if table is already wrapped
      if (table.parentElement?.classList.contains('responsive-wrapper')) {
        return
      }

      const div = document.createElement('div')
      div.classList.add('responsive-wrapper')
      div.style.overflowX = 'auto'
      div.style.maxWidth = '100%'

      // shadow-base spread and compensation
      div.style.padding = '24px'
      div.style.margin = '-12px -24px'

      const parent = table.parentNode

      if (parent) {
        parent.insertBefore(div, table)
        div.appendChild(table)
        originalParents.set(table, parent)
      } else {
        return
      }
    })
  }

  const removeTableStyles = () => {
    originalParents.forEach((originalParent, table) => {
      const currentParent = table.parentNode

      if (currentParent) {
        originalParent.insertBefore(table, currentParent)
        originalParent.removeChild(currentParent)
      }
    })

    originalParents = new Map()
  }

  const resizeFunc = debounce(() => {
    if (window.innerWidth <= 1023) {
      applyTableStyles()
    } else {
      removeTableStyles()
    }
  }, 500)

  document.addEventListener('turbo:load', resizeFunc)
  window.addEventListener('resize', resizeFunc)
}
