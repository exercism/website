import {
  CodeCheck,
  closeDialog,
  openDialog,
  seniorityForCodeCheck,
  showJikiVariant,
  type Seniority,
} from '@/utils/code-check'

/**
 * The questions before the sign-up form, which send beginners to Jiki.
 *
 * Every step is rendered by the server in
 * app/views/devise/registrations/new.html.haml, with only the form showing.
 * This shows one step at a time, records the answers in the hidden fields
 * that both sign-up forms submit, and opens the Jiki pop-up.
 *
 * The onboarding page (app/views/user_onboarding/questions.html.haml) asks
 * the same questions of people who signed up through GitHub without them.
 * It has no form step. Instead, answering submits its hidden answers form,
 * straight away or once the Jiki pop-up is dismissed.
 *
 *   I'm a beginner       -> form + Jiki pop-up   (absolute_beginner)
 *   I'm a developer      -> form                 (senior)
 *   I can code a little  -> code check
 *     Easy               -> form                 (junior)
 *     Tricky/Impossible  -> form + Jiki pop-up   (beginner)
 *
 * Without JavaScript the page is the plain form, so nobody gets stuck.
 */

export { seniorityForCodeCheck }
export type { Seniority }
export type Step = 'level' | 'code' | 'form'
export type Level = 'total_beginner' | 'confident_developer' | 'in_between'

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
  private answersForm: HTMLFormElement | null
  private codeCheck: CodeCheck | null = null

  private step: Step = 'level'
  private level: Level | null = null

  constructor(root: HTMLElement) {
    this.root = root
    this.dialog = document.getElementById(
      'sign-up-jiki-dialog'
    ) as HTMLDialogElement | null
    this.answersForm = root.querySelector<HTMLFormElement>(
      'form[data-sign-up-answers-form]'
    )

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

    this.root
      .querySelectorAll<HTMLInputElement>(
        'input[type="radio"][name="sign_up_level"]'
      )
      .forEach((radio) =>
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

      this.finish(seniority, null)
    })
  }

  private bindCodeCheck() {
    const root = this.root.querySelector<HTMLElement>('.c-code-check')
    if (!root) return

    const continueButton = this.continueButton('code')
    const codeCheck = new CodeCheck(root, {
      snippetUrl: this.root.dataset.snippetUrl || '',
      onChange: () => {
        if (continueButton) continueButton.disabled = !codeCheck.complete
      },
    })
    this.codeCheck = codeCheck

    continueButton?.addEventListener('click', () => {
      if (!codeCheck.complete) return

      this.finish(
        seniorityForCodeCheck(codeCheck.answer!),
        codeCheck.trackSlug,
        codeCheck.trackTitle
      )
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
    const dialog = this.dialog
    if (!dialog) return

    dialog
      .querySelectorAll<HTMLButtonElement>('[data-jiki-dismiss]')
      .forEach((button) =>
        button.addEventListener('click', () => {
          closeDialog(dialog)
          this.answersForm?.submit()
        })
      )

    // The only way out is "No thanks", so Esc doesn't close it.
    dialog.addEventListener('cancel', (event) => event.preventDefault())
    dialog.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') event.preventDefault()
    })
  }

  private finish(
    seniority: Seniority,
    trackSlug: string | null,
    language = ''
  ) {
    this.setAnswer('seniority', seniority)
    this.setAnswer('sign_up_track_slug', trackSlug || '')
    if (!this.answersForm) this.show('form')

    if (this.dialog && JIKI_SENIORITIES.includes(seniority)) {
      showJikiVariant(this.dialog, seniority, 'sign-up-jiki-heading', language)
      openDialog(this.dialog)
      return
    }

    this.answersForm?.submit()
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

  private setAnswer(name: string, value: string) {
    document
      .querySelectorAll<HTMLInputElement>(`[data-sign-up-answer="${name}"]`)
      .forEach((input) => (input.value = value))
  }

  private continueButton(step: Step) {
    return this.root.querySelector<HTMLButtonElement>(
      `[data-continue="${step}"]`
    )
  }
}
