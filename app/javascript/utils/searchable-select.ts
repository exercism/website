/**
 * Replaces a native <select> with a button that opens a searchable list.
 *
 * The native select stays in the page, hidden, and keeps the value. Choosing
 * an option sets its value and dispatches a "change" event on it, so code
 * that listens to the select works the same with or without this.
 *
 * The search box and list follow the WAI-ARIA combobox pattern: focus stays
 * in the search box while the arrow keys move the highlighted option, which
 * the box points at with aria-activedescendant.
 *
 * Options can carry a data-icon-url, which shows next to their title in
 * the list.
 */

type Option = {
  value: string
  title: string
  iconUrl: string | null
  element: HTMLLIElement
}

let uid = 0

const CHEVRON =
  '<svg class="chevron" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9l6 6 6-6" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"></path></svg>'

export function initSearchableSelect(select: HTMLSelectElement): void {
  if (select.dataset.searchableSelect === 'initialised') return
  select.dataset.searchableSelect = 'initialised'

  const id = `searchable-select-${++uid}`
  const labelledBy = select.getAttribute('aria-labelledby') || ''
  const placeholder =
    select.querySelector<HTMLOptionElement>('option[value=""]')

  const wrapper = document.createElement('div')
  wrapper.className = 'c-searchable-select'

  const trigger = document.createElement('button')
  trigger.type = 'button'
  trigger.className = 'trigger'
  trigger.id = `${id}-trigger`
  trigger.setAttribute('aria-haspopup', 'listbox')
  trigger.setAttribute('aria-expanded', 'false')
  trigger.setAttribute('aria-labelledby', `${labelledBy} ${trigger.id}`.trim())

  const panel = document.createElement('div')
  panel.className = 'panel'
  panel.hidden = true

  const search = document.createElement('input')
  search.type = 'text'
  search.className = 'search'
  search.autocomplete = 'off'
  search.spellcheck = false
  search.placeholder = select.dataset.searchPlaceholder || ''
  search.setAttribute('role', 'combobox')
  search.setAttribute('aria-expanded', 'true')
  search.setAttribute('aria-autocomplete', 'list')
  search.setAttribute('aria-controls', `${id}-list`)
  if (labelledBy) search.setAttribute('aria-labelledby', labelledBy)

  const list = document.createElement('ul')
  list.className = 'options'
  list.id = `${id}-list`
  list.setAttribute('role', 'listbox')
  if (labelledBy) list.setAttribute('aria-labelledby', labelledBy)

  const noResults = document.createElement('p')
  noResults.className = 'no-results'
  noResults.hidden = true
  noResults.textContent = select.dataset.noResults || ''

  const options: Option[] = Array.from(select.options)
    .filter((option) => option.value !== '')
    .map((option, index) => {
      const element = document.createElement('li')
      element.className = 'option'
      element.id = `${id}-option-${index}`
      element.setAttribute('role', 'option')
      element.setAttribute('aria-selected', 'false')
      element.dataset.value = option.value

      const iconUrl = option.dataset.iconUrl || null
      if (iconUrl) element.appendChild(icon(iconUrl))
      element.appendChild(document.createTextNode(option.text))

      list.appendChild(element)
      return { value: option.value, title: option.text, iconUrl, element }
    })

  panel.append(search, list, noResults)
  wrapper.append(trigger, panel)
  select.hidden = true
  select.insertAdjacentElement('afterend', wrapper)

  let visible: Option[] = options
  let active: Option | null = null

  function renderTrigger() {
    const chosen = options.find((option) => option.value === select.value)

    trigger.replaceChildren()

    const label = document.createElement('span')
    label.textContent = chosen ? chosen.title : placeholder?.text || ''
    trigger.appendChild(label)
    trigger.insertAdjacentHTML('beforeend', CHEVRON)

    options.forEach((option) =>
      option.element.setAttribute(
        'aria-selected',
        String(option.value === select.value)
      )
    )
  }

  function filter() {
    const query = search.value.trim().toLowerCase()
    visible = options.filter(
      (option) =>
        query === '' ||
        option.title.toLowerCase().includes(query) ||
        option.value.toLowerCase().includes(query)
    )

    options.forEach((option) => {
      option.element.hidden = !visible.includes(option)
    })
    noResults.hidden = visible.length > 0
    setActive(visible[0] || null)
  }

  function setActive(option: Option | null) {
    active?.element.classList.remove('--active')
    active = option

    if (option) {
      option.element.classList.add('--active')
      search.setAttribute('aria-activedescendant', option.element.id)
      option.element.scrollIntoView?.({ block: 'nearest' })
    } else {
      search.removeAttribute('aria-activedescendant')
    }
  }

  function moveActive(step: number) {
    if (visible.length === 0) return

    const index = active ? visible.indexOf(active) : -1
    const next = Math.min(Math.max(index + step, 0), visible.length - 1)
    setActive(visible[next])
  }

  function open() {
    if (!panel.hidden) return

    panel.hidden = false
    trigger.setAttribute('aria-expanded', 'true')
    search.value = ''
    filter()

    const chosen = options.find((option) => option.value === select.value)
    if (chosen) setActive(chosen)

    search.focus()
    document.addEventListener('mousedown', closeOnOutsideClick)
  }

  function close({ refocus }: { refocus: boolean }) {
    if (panel.hidden) return

    panel.hidden = true
    trigger.setAttribute('aria-expanded', 'false')
    document.removeEventListener('mousedown', closeOnOutsideClick)
    if (refocus) trigger.focus()
  }

  function choose(option: Option) {
    const changed = select.value !== option.value
    select.value = option.value
    renderTrigger()
    close({ refocus: true })

    if (changed) select.dispatchEvent(new Event('change', { bubbles: true }))
  }

  function closeOnOutsideClick(event: MouseEvent) {
    if (!wrapper.contains(event.target as Node)) close({ refocus: false })
  }

  trigger.addEventListener('click', () =>
    panel.hidden ? open() : close({ refocus: true })
  )
  trigger.addEventListener('keydown', (event) => {
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault()
      open()
    }
  })

  search.addEventListener('input', filter)
  search.addEventListener('keydown', (event) => {
    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        moveActive(1)
        break
      case 'ArrowUp':
        event.preventDefault()
        moveActive(-1)
        break
      case 'Home':
        event.preventDefault()
        setActive(visible[0] || null)
        break
      case 'End':
        event.preventDefault()
        setActive(visible[visible.length - 1] || null)
        break
      case 'Enter':
        event.preventDefault()
        if (active) choose(active)
        break
      case 'Escape':
        event.preventDefault()
        close({ refocus: true })
        break
      case 'Tab':
        close({ refocus: false })
        break
    }
  })

  options.forEach((option) => {
    // Keep focus in the search box while the mouse is down.
    option.element.addEventListener('mousedown', (event) =>
      event.preventDefault()
    )
    option.element.addEventListener('mousemove', () => {
      if (active !== option) setActive(option)
    })
    option.element.addEventListener('click', () => choose(option))
  })

  // Keep the button in step when something else sets the select's value.
  select.addEventListener('change', renderTrigger)

  renderTrigger()
}

function icon(url: string): HTMLImageElement {
  const img = document.createElement('img')
  img.src = url
  img.alt = ''
  img.setAttribute('aria-hidden', 'true')
  return img
}
