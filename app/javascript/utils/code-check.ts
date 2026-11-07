import { initSearchableSelect } from '@/utils/searchable-select'

/**
 * The code check from app/views/components/sign_up/_code_check.html.haml:
 * pick a language, read a short snippet, say how it feels.
 *
 * The sign-up page and the returning-user modal both use it. Each snippet is
 * fetched when its language is picked, from a URL with TRACK_SLUG in it.
 */

export type CodeCheckAnswer = 'easy' | 'tricky' | 'impossible'
export type Seniority = 'absolute_beginner' | 'beginner' | 'junior' | 'senior'

export function seniorityForCodeCheck(answer: CodeCheckAnswer): Seniority {
  return answer === 'easy' ? 'junior' : 'beginner'
}

type Snippet = { snippet: string; highlightjs_language: string }

export class CodeCheck {
  trackSlug: string | null = null
  answer: CodeCheckAnswer | null = null

  private root: HTMLElement
  private snippetUrl: string
  private onChange: () => void
  private snippets = new Map<string, Promise<Snippet>>()

  constructor(
    root: HTMLElement,
    { snippetUrl, onChange }: { snippetUrl: string; onChange: () => void }
  ) {
    this.root = root
    this.snippetUrl = snippetUrl
    this.onChange = onChange

    const select = root.querySelector<HTMLSelectElement>(
      '[data-language-select]'
    )
    if (select) {
      initSearchableSelect(select)
      select.addEventListener('change', () => this.chooseTrack(select.value))
    }

    this.radios().forEach((radio) =>
      radio.addEventListener('change', () => {
        this.answer = radio.value as CodeCheckAnswer
        this.onChange()
      })
    )
  }

  /** The name of the chosen language, as the picker shows it. */
  get trackTitle(): string {
    const select = this.root.querySelector<HTMLSelectElement>(
      '[data-language-select]'
    )
    const option = select?.selectedOptions[0]
    return option && option.value ? option.text : ''
  }

  get complete(): boolean {
    return this.trackSlug !== null && this.answer !== null
  }

  private chooseTrack(slug: string) {
    this.trackSlug = slug || null
    this.answer = null
    this.radios().forEach((radio) => (radio.checked = false))
    this.onChange()

    if (!slug) return

    this.render('loading')
    this.fetchSnippet(slug)
      .then(({ snippet, highlightjs_language }) => {
        // Someone may have picked another language while this loaded.
        if (this.trackSlug !== slug) return

        this.render('code', snippet, highlightjs_language)
      })
      .catch(() => {
        if (this.trackSlug !== slug) return

        this.snippets.delete(slug)
        this.render('error')
      })
  }

  private fetchSnippet(slug: string): Promise<Snippet> {
    let request = this.snippets.get(slug)
    if (!request) {
      const url = this.snippetUrl.replace(
        'TRACK_SLUG',
        encodeURIComponent(slug)
      )
      request = fetch(url, { headers: { Accept: 'application/json' } }).then(
        (response) => {
          if (!response.ok) throw new Error(`HTTP ${response.status}`)
          return response.json()
        }
      )
      this.snippets.set(slug, request)
    }
    return request
  }

  private render(
    state: 'loading' | 'code' | 'error',
    snippet = '',
    language = ''
  ) {
    const find = (selector: string) =>
      this.root.querySelector<HTMLElement>(selector)
    const pre = find('[data-code-sample]')

    const placeholder = find('[data-code-placeholder]')
    if (placeholder) placeholder.hidden = true
    const visibility: [HTMLElement | null, boolean][] = [
      [find('[data-code-loading]'), state === 'loading'],
      [find('[data-code-error]'), state === 'error'],
      [pre, state === 'code'],
      [find('.code-check-question'), state === 'code'],
      [find('.code-check-answers'), state === 'code'],
    ]
    visibility.forEach(([element, shown]) => {
      if (element) element.hidden = !shown
    })

    if (state !== 'code' || !pre) return

    const code = document.createElement('code')
    if (language) code.className = `language-${language}`
    code.dataset.highlightLineNumbers = 'true'
    code.textContent = snippet
    pre.replaceChildren(code)
    pre.scrollTop = 0

    import('@/utils/highlight')
      .then((module) => module.highlightAll(pre))
      .catch(() => {
        // The code still reads fine without colours.
      })
  }

  private radios() {
    return this.root.querySelectorAll<HTMLInputElement>(
      'input[type="radio"][name="code_check_answer"]'
    )
  }
}

/** Opens a <dialog> as a modal and focuses it as a whole. */
export function openDialog(dialog: HTMLDialogElement): void {
  if (typeof dialog.showModal === 'function') {
    if (!dialog.open) dialog.showModal()
  } else {
    dialog.setAttribute('open', '')
  }

  // Focusing the dialog itself means it reads from the top and no button
  // starts with a focus ring.
  dialog.focus()
}

export function closeDialog(dialog: HTMLDialogElement): void {
  if (typeof dialog.close === 'function') {
    dialog.close()
  } else {
    dialog.removeAttribute('open')
  }
}

/**
 * Shows the parts of a Jiki pop-up that belong to this seniority, and fills
 * in the language they picked wherever the copy names it.
 */
export function showJikiVariant(
  dialog: HTMLElement,
  seniority: Seniority,
  headingIdPrefix: string,
  language = ''
): void {
  dialog
    .querySelectorAll<HTMLElement>('[data-jiki-language]')
    .forEach((element) => (element.textContent = language))

  dialog
    .querySelectorAll<HTMLElement>('[data-jiki-variant]')
    .forEach((element) => {
      element.hidden = element.dataset.jikiVariant !== seniority
    })
  dialog.setAttribute('aria-labelledby', `${headingIdPrefix}-${seniority}`)
}
