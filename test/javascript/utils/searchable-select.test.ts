import { initSearchableSelect } from '@/utils/searchable-select'

function setUpSelect() {
  document.body.innerHTML = `
    <span id="label">I mostly code in</span>
    <select data-search-placeholder="Search languages" data-no-results="No languages match" aria-labelledby="label">
      <option value="">choose a language</option>
      <option value="javascript" data-icon-url="/js.svg">JavaScript</option>
      <option value="typescript">TypeScript</option>
      <option value="python">Python</option>
      <option value="csharp">C#</option>
    </select>
    <button id="outside">Outside</button>
  `
  const select = document.querySelector('select') as HTMLSelectElement
  initSearchableSelect(select)

  const trigger = document.querySelector('.trigger') as HTMLButtonElement
  const panel = document.querySelector('.panel') as HTMLElement
  const search = document.querySelector('.search') as HTMLInputElement
  const options = () =>
    Array.from(document.querySelectorAll<HTMLLIElement>('.option'))
  const visibleTitles = () =>
    options()
      .filter((option) => !option.hidden)
      .map((option) => option.textContent)

  return { select, trigger, panel, search, options, visibleTitles }
}

function type(input: HTMLInputElement, value: string) {
  input.value = value
  input.dispatchEvent(new Event('input'))
}

function press(element: HTMLElement, key: string) {
  element.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true }))
}

describe('initSearchableSelect', () => {
  test('hides the native select and shows the placeholder on the button', () => {
    const { select, trigger, panel } = setUpSelect()

    expect(select.hidden).toBe(true)
    expect(trigger.textContent).toBe('choose a language')
    expect(trigger.getAttribute('aria-expanded')).toBe('false')
    expect(panel.hidden).toBe(true)
  })

  test('opening focuses the search box and lists every option', () => {
    const { trigger, panel, search, visibleTitles } = setUpSelect()

    trigger.click()

    expect(panel.hidden).toBe(false)
    expect(trigger.getAttribute('aria-expanded')).toBe('true')
    expect(document.activeElement).toBe(search)
    expect(visibleTitles()).toEqual([
      'JavaScript',
      'TypeScript',
      'Python',
      'C#',
    ])
  })

  test('typing filters by title and by value', () => {
    const { trigger, search, visibleTitles } = setUpSelect()
    trigger.click()

    type(search, 'script')
    expect(visibleTitles()).toEqual(['JavaScript', 'TypeScript'])

    type(search, 'c#')
    expect(visibleTitles()).toEqual(['C#'])

    type(search, 'CSHARP')
    expect(visibleTitles()).toEqual(['C#'])
  })

  test('shows a message when nothing matches', () => {
    const { trigger, search, visibleTitles } = setUpSelect()
    trigger.click()

    type(search, 'cobol')

    expect(visibleTitles()).toEqual([])
    const noResults = document.querySelector('.no-results') as HTMLElement
    expect(noResults.hidden).toBe(false)
    expect(noResults.textContent).toBe('No languages match')
    expect(search.hasAttribute('aria-activedescendant')).toBe(false)
  })

  test('the arrow keys move the highlight and Enter chooses it', () => {
    const { select, trigger, panel, search, options } = setUpSelect()
    const onChange = jest.fn()
    select.addEventListener('change', onChange)
    trigger.click()

    expect(search.getAttribute('aria-activedescendant')).toBe(options()[0].id)

    press(search, 'ArrowDown')
    press(search, 'ArrowDown')
    press(search, 'ArrowUp')
    expect(search.getAttribute('aria-activedescendant')).toBe(options()[1].id)

    press(search, 'Enter')

    expect(select.value).toBe('typescript')
    expect(onChange).toHaveBeenCalledTimes(1)
    expect(panel.hidden).toBe(true)
    expect(document.activeElement).toBe(trigger)
    expect(trigger.textContent).toBe('TypeScript')
    expect(options()[1].getAttribute('aria-selected')).toBe('true')
  })

  test('the highlight stays within the filtered options', () => {
    const { select, trigger, search } = setUpSelect()
    trigger.click()

    type(search, 'script')
    press(search, 'ArrowDown')
    press(search, 'ArrowDown')
    press(search, 'ArrowDown')
    press(search, 'Enter')

    expect(select.value).toBe('typescript')
  })

  test('clicking an option chooses it', () => {
    const { select, trigger, options } = setUpSelect()
    trigger.click()

    options()[0].click()

    expect(select.value).toBe('javascript')
    expect(trigger.textContent).toBe('JavaScript')
  })

  test('options show their icon in the list', () => {
    const { options } = setUpSelect()

    expect(options()[0].querySelector('img')?.getAttribute('src')).toBe(
      '/js.svg'
    )
    expect(options()[1].querySelector('img')).toBeNull()
  })

  test('choosing the current option again does not fire change', () => {
    const { select, trigger, options } = setUpSelect()
    trigger.click()
    options()[2].click()

    const onChange = jest.fn()
    select.addEventListener('change', onChange)
    trigger.click()
    options()[2].click()

    expect(onChange).not.toHaveBeenCalled()
  })

  test('Escape closes without choosing and returns focus to the button', () => {
    const { select, trigger, panel, search } = setUpSelect()
    trigger.click()

    press(search, 'Escape')

    expect(panel.hidden).toBe(true)
    expect(select.value).toBe('')
    expect(document.activeElement).toBe(trigger)
  })

  test('clicking outside closes the list', () => {
    const { trigger, panel } = setUpSelect()
    trigger.click()

    document
      .getElementById('outside')!
      .dispatchEvent(new MouseEvent('mousedown', { bubbles: true }))

    expect(panel.hidden).toBe(true)
  })

  test('the search box is a combobox that controls the list', () => {
    const { search } = setUpSelect()
    const list = document.querySelector('.options') as HTMLElement

    expect(search.getAttribute('role')).toBe('combobox')
    expect(search.getAttribute('aria-controls')).toBe(list.id)
    expect(list.getAttribute('role')).toBe('listbox')
    expect(list.getAttribute('aria-labelledby')).toBe('label')
  })

  test('initialising twice does nothing the second time', () => {
    const { select } = setUpSelect()

    initSearchableSelect(select)

    expect(document.querySelectorAll('.c-searchable-select')).toHaveLength(1)
  })
})
