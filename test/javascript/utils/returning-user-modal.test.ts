import { initReturningUserModal } from '@/utils/returning-user-modal'

jest.mock('@/utils/highlight', () => ({ highlightAll: jest.fn() }))

const PAGE = `
  <div id="returning-user-modal" data-api-user-url="/api/v2/user" data-snippet-url="/api/v2/tracks/TRACK_SLUG/sign_up_snippet">
    <dialog data-returning-step="level">
      <input type="radio" name="returning_user_level" value="total_beginner">
      <input type="radio" name="returning_user_level" value="in_between">
      <input type="radio" name="returning_user_level" value="confident_developer">
      <button data-continue="level" disabled></button>
    </dialog>
    <dialog data-returning-step="code">
      <div class="c-code-check">
        <span id="label">I mostly code in</span>
        <select data-language-select aria-labelledby="label">
          <option value="">choose a language</option>
          <option value="go">Go</option>
        </select>
        <p class="code-check-question" hidden></p>
        <div data-code-placeholder></div>
        <div data-code-loading hidden></div>
        <div data-code-error hidden></div>
        <pre data-code-sample hidden><code></code></pre>
        <div class="code-check-answers" hidden>
          <input type="radio" name="code_check_answer" value="easy">
          <input type="radio" name="code_check_answer" value="tricky">
          <input type="radio" name="code_check_answer" value="impossible">
        </div>
      </div>
      <button data-continue="code" disabled></button>
    </dialog>
    <dialog data-returning-step="thanks"></dialog>
    <dialog data-returning-step="jiki">
      <button class="close" data-jiki-dismiss></button>
      <div data-jiki-variant="absolute_beginner" hidden></div>
      <div data-jiki-variant="beginner" hidden>master <span data-jiki-language></span></div>
      <p class="jiki-note" data-jiki-variant="beginner" hidden></p>
      <p class="later">No thanks, take me back to <button class="later-link" data-jiki-dismiss>Exercism</button></p>
    </dialog>
  </div>
`

const dialog = (step: string) =>
  document.querySelector<HTMLDialogElement>(
    `dialog[data-returning-step="${step}"]`
  )!
const openSteps = () =>
  Array.from(document.querySelectorAll<HTMLDialogElement>('dialog'))
    .filter((d) => d.hasAttribute('open'))
    .map((d) => d.dataset.returningStep)
const shownVariants = () =>
  Array.from(
    dialog('jiki').querySelectorAll<HTMLElement>('[data-jiki-variant]')
  )
    .filter((element) => !element.hidden)
    .map((element) => element.className || element.tagName.toLowerCase())

function pick(name: string, value: string) {
  const radio = document.querySelector<HTMLInputElement>(
    `input[name="${name}"][value="${value}"]`
  )!
  radio.checked = true
  radio.dispatchEvent(new Event('change'))
}

function clickContinue(step: string) {
  document
    .querySelector<HTMLButtonElement>(`[data-continue="${step}"]`)!
    .click()
}

function chooseLanguage(slug: string) {
  const select = document.querySelector<HTMLSelectElement>(
    '[data-language-select]'
  )!
  select.value = slug
  select.dispatchEvent(new Event('change'))
}

const flush = () => new Promise((resolve) => setTimeout(resolve, 0))

let fetchMock: jest.Mock

beforeEach(() => {
  fetchMock = jest.fn((url: string) =>
    Promise.resolve({
      ok: true,
      status: 200,
      json: () =>
        Promise.resolve(
          url.includes('sign_up_snippet')
            ? { snippet: 'package main', highlightjs_language: 'go' }
            : {}
        ),
    })
  )
  global.fetch = fetchMock as unknown as typeof fetch

  document.body.innerHTML = PAGE
  initReturningUserModal()
})

afterEach(() => {
  jest.useRealTimers()
})

const savedSeniorities = () =>
  fetchMock.mock.calls
    .filter(([, options]) => options?.method === 'PATCH')
    .map(([url]) => decodeURIComponent(url as string))

describe('initReturningUserModal', () => {
  test('opens on the level question with Save disabled', () => {
    expect(openSteps()).toEqual(['level'])
    expect(
      document.querySelector<HTMLButtonElement>('[data-continue="level"]')!
        .disabled
    ).toBe(true)
  })

  test("I'm a developer saves senior and thanks them, then closes", () => {
    jest.useFakeTimers()

    pick('returning_user_level', 'confident_developer')
    clickContinue('level')

    expect(savedSeniorities()).toEqual(['/api/v2/user?user[seniority]=senior'])
    expect(openSteps()).toEqual(['thanks'])

    jest.advanceTimersByTime(3000)
    expect(openSteps()).toEqual([])
  })

  test("I'm a beginner saves absolute_beginner and offers Jiki", () => {
    pick('returning_user_level', 'total_beginner')
    clickContinue('level')

    expect(savedSeniorities()).toEqual([
      '/api/v2/user?user[seniority]=absolute_beginner',
    ])
    expect(openSteps()).toEqual(['jiki'])
    expect(shownVariants()).toEqual(['div'])
    expect(dialog('jiki').getAttribute('aria-labelledby')).toBe(
      'returning-user-jiki-heading-absolute_beginner'
    )
  })

  test('I can code a little goes to the code check without saving', () => {
    pick('returning_user_level', 'in_between')
    clickContinue('level')

    expect(openSteps()).toEqual(['code'])
    expect(savedSeniorities()).toEqual([])
  })

  test('Easy saves junior and thanks them', async () => {
    pick('returning_user_level', 'in_between')
    clickContinue('level')
    chooseLanguage('go')
    await flush()

    pick('code_check_answer', 'easy')
    clickContinue('code')

    expect(savedSeniorities()).toEqual(['/api/v2/user?user[seniority]=junior'])
    expect(openSteps()).toEqual(['thanks'])
  })

  test.each(['tricky', 'impossible'])(
    '%s saves beginner and offers Jiki with the games note',
    async (answer) => {
      pick('returning_user_level', 'in_between')
      clickContinue('level')
      chooseLanguage('go')
      await flush()

      pick('code_check_answer', answer)
      clickContinue('code')

      expect(savedSeniorities()).toEqual([
        '/api/v2/user?user[seniority]=beginner',
      ])
      expect(openSteps()).toEqual(['jiki'])
      expect(shownVariants()).toEqual(['div', 'jiki-note'])
      expect(
        dialog('jiki').querySelector('[data-jiki-language]')!.textContent
      ).toBe('Go')
    }
  )

  test('Continue on the code check waits for a language and an answer', async () => {
    pick('returning_user_level', 'in_between')
    clickContinue('level')
    const continueButton = document.querySelector<HTMLButtonElement>(
      '[data-continue="code"]'
    )!

    chooseLanguage('go')
    await flush()
    expect(continueButton.disabled).toBe(true)

    pick('code_check_answer', 'easy')
    expect(continueButton.disabled).toBe(false)
  })

  test.each(['.close', '.later-link'])(
    '%s closes the Jiki pop-up',
    (selector) => {
      pick('returning_user_level', 'total_beginner')
      clickContinue('level')

      dialog('jiki').querySelector<HTMLButtonElement>(selector)!.click()

      expect(openSteps()).toEqual([])
    }
  )

  test('does nothing without the modal on the page', () => {
    document.body.innerHTML = '<div></div>'

    expect(() => initReturningUserModal()).not.toThrow()
  })
})
