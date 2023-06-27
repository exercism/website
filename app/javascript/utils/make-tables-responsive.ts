import { debounce } from './debounce'

const LG_BREAKPOINT = 1023
export function makeTablesResponsive(): void {
  let originalParents = new Map()

  const applyTableStyles = () => {
    const tables = Array.from(
      document.querySelectorAll('.c-textual-content table')
    ) as HTMLTableElement[]

    tables.forEach((table) => {
      // skip if !table / table is already wrapped
      if (
        !table ||
        table.parentElement?.classList.contains('c-responsive-table-wrapper')
      ) {
        return
      }

      const div = document.createElement('div')
      div.classList.add('c-responsive-table-wrapper')

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
    if (window.innerWidth <= LG_BREAKPOINT) {
      applyTableStyles()
    } else {
      removeTableStyles()
    }
  }, 500)

  document.addEventListener('turbo:load', resizeFunc)
  window.addEventListener('resize', resizeFunc)
}
