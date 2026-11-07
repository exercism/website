import {
  CodeCheck,
  closeDialog,
  openDialog,
  seniorityForCodeCheck,
  showJikiVariant,
  type Seniority,
} from '@/utils/code-check'
import { seniorityForLevel, type Level } from '@/utils/sign-up-flow'

/**
 * The pop-up for people who signed up before the sign-up page asked their
 * level. It asks the same question and routes them the same way:
 *
 *   I'm a beginner       -> Jiki pop-up          (absolute_beginner)
 *   I'm a developer      -> "Thanks!"            (senior)
 *   I can code a little  -> code check
 *     Easy               -> "Thanks!"            (junior)
 *     Tricky/Impossible  -> Jiki pop-up          (beginner)
 *
 * The answer is saved as their seniority as soon as it's known, so the
 * pop-up doesn't come back. Its markup is
 * app/views/components/_returning_user_modal.html.haml.
 */

type Step = 'level' | 'code' | 'thanks' | 'jiki'

const THANKS_DURATION_MS = 3000

export function initReturningUserModal(): void {
  if (typeof document === 'undefined') return

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setUp, { once: true })
  } else {
    setUp()
  }
  document.addEventListener('turbo:load', setUp)
}

function setUp(): void {
  const root = document.getElementById('returning-user-modal')
  if (!root || root.dataset.modalInitialised === 'true') return
  root.dataset.modalInitialised = 'true'

  new ReturningUserModal(root)
}

class ReturningUserModal {
  private root: HTMLElement
  private level: Level | null = null

  constructor(root: HTMLElement) {
    this.root = root

    this.bindLevel()
    this.bindCodeCheck()
    this.bindJiki()

    this.show('level')
  }

  private bindLevel() {
    const save = this.continueButton('level')

    this.root
      .querySelectorAll<HTMLInputElement>(
        'input[type="radio"][name="returning_user_level"]'
      )
      .forEach((radio) =>
        radio.addEventListener('change', () => {
          this.level = radio.value as Level
          if (save) save.disabled = false
        })
      )

    save?.addEventListener('click', () => {
      if (!this.level) return

      const seniority = seniorityForLevel(this.level)
      if (seniority === null) {
        this.show('code')
      } else {
        this.finish(seniority)
      }
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

    continueButton?.addEventListener('click', () => {
      if (!codeCheck.complete) return

      this.finish(
        seniorityForCodeCheck(codeCheck.answer!),
        codeCheck.trackTitle
      )
    })
  }

  private bindJiki() {
    this.dialog('jiki')
      ?.querySelectorAll<HTMLButtonElement>('[data-jiki-dismiss]')
      .forEach((button) =>
        button.addEventListener('click', () => this.closeAll())
      )
  }

  private finish(seniority: Seniority, language = '') {
    this.save(seniority)

    if (seniority === 'absolute_beginner' || seniority === 'beginner') {
      const jiki = this.dialog('jiki')
      if (jiki)
        showJikiVariant(
          jiki,
          seniority,
          'returning-user-jiki-heading',
          language
        )
      this.show('jiki')
    } else {
      this.show('thanks')
      window.setTimeout(() => this.closeAll(), THANKS_DURATION_MS)
    }
  }

  private save(seniority: Seniority) {
    const url = `${this.root.dataset.apiUserUrl}?${encodeURIComponent(
      'user[seniority]'
    )}=${seniority}`

    fetch(url, {
      method: 'PATCH',
      headers: { Accept: 'application/json' },
    }).catch(() => {
      // If this fails the pop-up simply shows again on their next visit.
    })
  }

  private show(step: Step) {
    ;(['level', 'code', 'thanks', 'jiki'] as Step[]).forEach((other) => {
      const dialog = this.dialog(other)
      if (dialog && other !== step) closeDialog(dialog)
    })

    const dialog = this.dialog(step)
    if (dialog) openDialog(dialog)
  }

  private closeAll() {
    this.root
      .querySelectorAll<HTMLDialogElement>('dialog')
      .forEach((dialog) => closeDialog(dialog))
  }

  private dialog(step: Step) {
    return this.root.querySelector<HTMLDialogElement>(
      `dialog[data-returning-step="${step}"]`
    )
  }

  private continueButton(step: 'level' | 'code') {
    return this.root.querySelector<HTMLButtonElement>(
      `[data-continue="${step}"]`
    )
  }
}
