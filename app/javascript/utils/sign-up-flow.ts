import { initSearchableSelect } from '@/utils/searchable-select'

/**
 * The questions before the sign-up form, which send beginners to Jiki.
 *
 * Every step is rendered by the server in
 * app/views/devise/registrations/new.html.haml, with only the form showing.
 * This shows one step at a time, records the answers in the hidden fields
 * that both sign-up forms submit, and opens the Jiki pop-up.
 *
 *   I'm a beginner       -> form + Jiki pop-up   (absolute_beginner)
 *   I'm a developer      -> form                 (senior)
 *   I can code a little  -> code check
 *     Easy               -> form                 (junior)
 *     Tricky/Impossible  -> form + Jiki pop-up   (beginner)
 *
 * Without JavaScript the page is the plain form, so nobody gets stuck.
 */

export type Step = 'level' | 'code' | 'form'
export type Level = 'total_beginner' | 'confident_developer' | 'in_between'
export type CodeCheck = 'easy' | 'tricky' | 'impossible'
export type Seniority = 'absolute_beginner' | 'beginner' | 'junior' | 'senior'

const STEP_NUMBERS: Record<Step, number> = { level: 1, code: 2, form: 3 }
const JIKI_SENIORITIES: Seniority[] = ['absolute_beginner', 'beginner']

export function seniorityForLevel(level: Level): Seniority | null {
  switch (level) {
    case 'total_beginner':
      return 'absolute_beginner'
    case 'confident_developer':
      return 'senior'
    case 'in_between':
      return null
  }
}

export function seniorityForCodeCheck(check: CodeCheck): Seniority {
  return check === 'easy' ? 'junior' : 'beginner'
}

export function initSignUpFlow(): void {
  if (typeof document === 'undefined') return

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setUp, { once: true })
  } else {
    setUp()
  }
  document.addEventListener('turbo:load', setUp)
}

function setUp(): void {
  const root = document.getElementById('sign-up-flow')
  if (!root || root.dataset.flowInitialised === 'true') return
  root.dataset.flowInitialised = 'true'

  new SignUpFlow(root)
}

class SignUpFlow {
  private root: HTMLElement
  private dialog: HTMLDialogElement | null
  private languageSelect: HTMLSelectElement | null
  private snippetUrl: string
  private snippets = new Map<
    string,
    Promise<{ snippet: string; highlightjs_language: string }>
  >()

  private step: Step = 'level'
  private level: Level | null = null
  private trackSlug: string | null = null
  private check: CodeCheck | null = null

  constructor(root: HTMLElement) {
    this.root = root
    this.dialog = document.getElementById(
      'sign-up-jiki-dialog'
    ) as HTMLDialogElement | null
    this.languageSelect = root.querySelector<HTMLSelectElement>(
      '[data-language-select]'
    )
    this.snippetUrl = root.dataset.snippetUrl || ''

    this.bindLevel()
    this.bindCodeCheck()
    this.bindProgress()
    this.bindDialog()

    root.querySelector<HTMLElement>('.progress')?.removeAttribute('hidden')
    this.show(root.dataset.initialStep === 'form' ? 'form' : 'level', {
      focus: false,
    })
  }

  private bindLevel() {
    const continueButton = this.continueButton('level')

    this.radios('sign_up_level').forEach((radio) =>
      radio.addEventListener('change', () => {
        this.level = radio.value as Level
        if (continueButton) continueButton.disabled = false
      })
    )

    continueButton?.addEventListener('click', () => {
      if (!this.level) return

      const seniority = seniorityForLevel(this.level)
      if (seniority === null) {
        this.show('code')
        return
      }

      this.trackSlug = null
      this.finish(seniority)
    })
  }

  private bindCodeCheck() {
    const continueButton = this.continueButton('code')

    if (this.languageSelect) {
      initSearchableSelect(this.languageSelect)
      this.languageSelect.addEventListener('change', () =>
        this.chooseTrack(this.languageSelect!.value)
      )
    }

    this.radios('sign_up_code_check').forEach((radio) =>
      radio.addEventListener('change', () => {
        this.check = radio.value as CodeCheck
        if (continueButton) continueButton.disabled = false
      })
    )

    continueButton?.addEventListener('click', () => {
      if (!this.check || !this.trackSlug) return

      this.finish(seniorityForCodeCheck(this.check))
    })
  }

  private bindProgress() {
    this.root
      .querySelectorAll<HTMLButtonElement>('[data-progress-step]')
      .forEach((dot) =>
        dot.addEventListener('click', () => {
          const step = (['level', 'code', 'form'] as Step[])[
            Number(dot.dataset.progressStep) - 1
          ]
          if (step) this.show(step)
        })
      )
  }

  private bindDialog() {
    this.dialog
      ?.querySelectorAll<HTMLButtonElement>('[data-jiki-dismiss]')
      .forEach((button) =>
        button.addEventListener('click', () => this.closeJikiDialog())
      )
  }

  private closeJikiDialog() {
    const dialog = this.dialog
    if (!dialog) return

    if (typeof dialog.close === 'function') {
      dialog.close()
    } else {
      dialog.removeAttribute('open')
    }
  }

  private finish(seniority: Seniority) {
    this.setAnswer('seniority', seniority)
    this.setAnswer('sign_up_track_slug', this.trackSlug || '')
    this.show('form')

    if (JIKI_SENIORITIES.includes(seniority)) this.openJikiDialog(seniority)
  }

  private show(step: Step, { focus = true }: { focus?: boolean } = {}) {
    this.step = step
    this.root.dataset.currentStep = step

    this.root
      .querySelectorAll<HTMLElement>('[data-step]')
      .forEach((section) => {
        section.hidden = section.dataset.step !== step
      })

    this.renderProgress()

    if (!focus) return

    window.scrollTo?.(0, 0)
    const heading = this.root.querySelector<HTMLElement>(
      `[data-step="${step}"] h1`
    )
    if (heading) {
      heading.tabIndex = -1
      heading.focus({ preventScroll: true })
    }
  }

  private renderProgress() {
    const current = STEP_NUMBERS[this.step]

    this.root
      .querySelectorAll<HTMLButtonElement>('[data-progress-step]')
      .forEach((dot) => {
        const number = Number(dot.dataset.progressStep)

        dot.classList.toggle('--current', number === current)
        dot.classList.toggle('--done', number < current)
        if (number === current) {
          dot.setAttribute('aria-current', 'step')
        } else {
          dot.removeAttribute('aria-current')
        }

        // People can go back to a step they've passed. The code check only
        // counts as passed for those who went through it.
        dot.disabled = !(
          number < current &&
          (number !== STEP_NUMBERS.code || this.level === 'in_between')
        )
      })
  }

  private chooseTrack(slug: string) {
    this.trackSlug = slug || null
    this.check = null
    this.radios('sign_up_code_check').forEach(
      (radio) => (radio.checked = false)
    )
    const continueButton = this.continueButton('code')
    if (continueButton) continueButton.disabled = true

    if (!slug) return

    this.renderCode('loading')
    this.fetchSnippet(slug)
      .then(({ snippet, highlightjs_language }) => {
        // Someone may have picked another language while this loaded.
        if (this.trackSlug !== slug) return

        this.renderCode('code', snippet, highlightjs_language)
      })
      .catch(() => {
        if (this.trackSlug !== slug) return

        this.snippets.delete(slug)
        this.renderCode('error')
      })
  }

  private fetchSnippet(slug: string) {
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

  private renderCode(
    state: 'loading' | 'code' | 'error',
    snippet = '',
    language = ''
  ) {
    const placeholder = this.root.querySelector<HTMLElement>(
      '[data-code-placeholder]'
    )
    const loading = this.root.querySelector<HTMLElement>('[data-code-loading]')
    const error = this.root.querySelector<HTMLElement>('[data-code-error]')
    const pre = this.root.querySelector<HTMLElement>('[data-code-sample]')
    const question = this.root.querySelector<HTMLElement>(
      '.code-check-question'
    )
    const answers = this.root.querySelector<HTMLElement>('.code-check-answers')

    if (placeholder) placeholder.hidden = true
    if (loading) loading.hidden = state !== 'loading'
    if (error) error.hidden = state !== 'error'
    if (pre) pre.hidden = state !== 'code'
    if (question) question.hidden = state !== 'code'
    if (answers) answers.hidden = state !== 'code'

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

  private openJikiDialog(seniority: Seniority) {
    const dialog = this.dialog
    if (!dialog) return

    dialog
      .querySelectorAll<HTMLElement>('[data-jiki-variant]')
      .forEach((element) => {
        element.hidden = element.dataset.jikiVariant !== seniority
      })
    dialog.setAttribute('aria-labelledby', `sign-up-jiki-heading-${seniority}`)

    if (typeof dialog.showModal === 'function') {
      dialog.showModal()
    } else {
      dialog.setAttribute('open', '')
    }

    // Focus the pop-up as a whole so it reads from the top and no button
    // starts with a focus ring.
    dialog.focus()
  }

  private setAnswer(name: string, value: string) {
    document
      .querySelectorAll<HTMLInputElement>(`[data-sign-up-answer="${name}"]`)
      .forEach((input) => (input.value = value))
  }

  private radios(name: string) {
    return this.root.querySelectorAll<HTMLInputElement>(
      `input[type="radio"][name="${name}"]`
    )
  }

  private continueButton(step: Step) {
    return this.root.querySelector<HTMLButtonElement>(
      `[data-continue="${step}"]`
    )
  }
}
