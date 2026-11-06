import {
  initSignUpFlow,
  seniorityForCodeCheck,
  seniorityForLevel,
} from '@/utils/sign-up-flow'

jest.mock('@/utils/highlight', () => ({ highlightAll: jest.fn() }))

const PAGE = (initialStep = 'level') => `
  <div id="sign-up-flow" data-initial-step="${initialStep}" data-snippet-url="/api/v2/tracks/TRACK_SLUG/sign_up_snippet">
    <nav class="progress" hidden>
      <button data-progress-step="1" disabled></button>
      <button data-progress-step="2" disabled></button>
      <button data-progress-step="3" disabled></button>
    </nav>
    <section data-step="level" hidden>
      <h1>Where are you on your coding journey?</h1>
      <input type="radio" name="sign_up_level" value="total_beginner">
      <input type="radio" name="sign_up_level" value="confident_developer">
      <input type="radio" name="sign_up_level" value="in_between">
      <button data-continue="level" disabled></button>
    </section>
    <section data-step="code" hidden>
      <h1>Let's check where to start</h1>
      <span id="label">I mostly code in</span>
      <select data-language-select aria-labelledby="label">
        <option value="">choose a language</option>
        <option value="go">Go</option>
        <option value="ruby">Ruby</option>
      </select>
      <p class="code-check-question" hidden></p>
      <div data-code-placeholder></div>
      <div data-code-loading hidden></div>
      <div data-code-error hidden></div>
      <pre data-code-sample hidden><code></code></pre>
      <div class="code-check-answers" hidden>
        <input type="radio" name="sign_up_code_check" value="easy">
        <input type="radio" name="sign_up_code_check" value="tricky">
        <input type="radio" name="sign_up_code_check" value="impossible">
      </div>
      <button data-continue="code" disabled></button>
    </section>
    <section data-step="form">
      <h1>Create your Exercism account</h1>
      <form id="github">
        <input type="hidden" name="seniority" data-sign-up-answer="seniority">
        <input type="hidden" name="sign_up_track_slug" data-sign-up-answer="sign_up_track_slug">
      </form>
      <form id="email">
        <input type="hidden" name="user[seniority]" data-sign-up-answer="seniority">
        <input type="hidden" name="user[sign_up_track_slug]" data-sign-up-answer="sign_up_track_slug">
      </form>
    </section>
  </div>
  <dialog id="sign-up-jiki-dialog">
    <button data-jiki-dismiss></button>
    <div data-jiki-variant="absolute_beginner" hidden><h2 id="sign-up-jiki-heading-absolute_beginner"></h2></div>
    <div data-jiki-variant="beginner" hidden><h2 id="sign-up-jiki-heading-beginner"></h2></div>
    <a data-jiki-variant="absolute_beginner" hidden></a>
    <a data-jiki-variant="beginner" hidden></a>
  </dialog>
`

function setUpPage(initialStep = 'level') {
  document.body.innerHTML = PAGE(initialStep)
  initSignUpFlow()
}

const root = () => document.getElementById('sign-up-flow') as HTMLElement
const section = (step: string) =>
  document.querySelector<HTMLElement>(`[data-step="${step}"]`)!
const visibleStep = () =>
  Array.from(document.querySelectorAll<HTMLElement>('[data-step]'))
    .filter((element) => !element.hidden)
    .map((element) => element.dataset.step)
const dialog = () =>
  document.getElementById('sign-up-jiki-dialog') as HTMLDialogElement
const answers = (name: string) =>
  Array.from(
    document.querySelectorAll<HTMLInputElement>(
      `[data-sign-up-answer="${name}"]`
    )
  ).map((input) => input.value)
const dot = (number: number) =>
  document.querySelector<HTMLButtonElement>(`[data-progress-step="${number}"]`)!

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

function mockSnippet(ok = true) {
  global.fetch = jest.fn().mockResolvedValue({
    ok,
    status: ok ? 200 : 404,
    json: () =>
      Promise.resolve({
        snippet: 'package main',
        highlightjs_language: 'go',
      }),
  }) as jest.Mock
}

beforeEach(() => {
  mockSnippet()
})

describe('seniority mapping', () => {
  test('the level question', () => {
    expect(seniorityForLevel('total_beginner')).toBe('absolute_beginner')
    expect(seniorityForLevel('confident_developer')).toBe('senior')
    expect(seniorityForLevel('in_between')).toBeNull()
  })

  test('the code check', () => {
    expect(seniorityForCodeCheck('easy')).toBe('junior')
    expect(seniorityForCodeCheck('tricky')).toBe('beginner')
    expect(seniorityForCodeCheck('impossible')).toBe('beginner')
  })
})

describe('initSignUpFlow', () => {
  test('starts on the level question with continue disabled', () => {
    setUpPage()

    expect(visibleStep()).toEqual(['level'])
    expect(root().dataset.currentStep).toBe('level')
    expect(document.querySelector<HTMLElement>('.progress')!.hidden).toBe(false)
    expect(
      document.querySelector<HTMLButtonElement>('[data-continue="level"]')!
        .disabled
    ).toBe(true)
  })

  test('a re-rendered failed submission starts on the form', () => {
    setUpPage('form')

    expect(visibleStep()).toEqual(['form'])
    expect(dot(1).disabled).toBe(false)
    expect(dot(2).disabled).toBe(true)
  })

  test("I'm a beginner goes to the form with the Jiki pop-up", () => {
    setUpPage()

    pick('sign_up_level', 'total_beginner')
    clickContinue('level')

    expect(visibleStep()).toEqual(['form'])
    expect(answers('seniority')).toEqual([
      'absolute_beginner',
      'absolute_beginner',
    ])
    expect(answers('sign_up_track_slug')).toEqual(['', ''])
    expect(dialog().hasAttribute('open')).toBe(true)
    expect(dialog().getAttribute('aria-labelledby')).toBe(
      'sign-up-jiki-heading-absolute_beginner'
    )

    const variants = Array.from(
      dialog().querySelectorAll<HTMLElement>('[data-jiki-variant]')
    )
    expect(
      variants.filter((v) => !v.hidden).map((v) => v.dataset.jikiVariant)
    ).toEqual(['absolute_beginner', 'absolute_beginner'])
  })

  test("I'm a developer goes to the form without the pop-up", () => {
    setUpPage()

    pick('sign_up_level', 'confident_developer')
    clickContinue('level')

    expect(visibleStep()).toEqual(['form'])
    expect(answers('seniority')).toEqual(['senior', 'senior'])
    expect(dialog().hasAttribute('open')).toBe(false)
  })

  test('I can code a little goes to the code check', () => {
    setUpPage()

    pick('sign_up_level', 'in_between')
    clickContinue('level')

    expect(visibleStep()).toEqual(['code'])
    expect(dot(1).disabled).toBe(false)
  })

  test('choosing a language loads its snippet', async () => {
    setUpPage()
    pick('sign_up_level', 'in_between')
    clickContinue('level')

    chooseLanguage('go')
    expect(
      document.querySelector<HTMLElement>('[data-code-loading]')!.hidden
    ).toBe(false)
    await flush()

    expect(global.fetch).toHaveBeenCalledWith(
      '/api/v2/tracks/go/sign_up_snippet',
      expect.anything()
    )
    const pre = document.querySelector<HTMLElement>('[data-code-sample]')!
    expect(pre.hidden).toBe(false)
    expect(pre.querySelector('code')!.textContent).toBe('package main')
    expect(pre.querySelector('code')!.className).toBe('language-go')
    expect(pre.querySelector('code')!.dataset.highlightLineNumbers).toBe('true')
    expect(
      document.querySelector<HTMLElement>('.code-check-answers')!.hidden
    ).toBe(false)
  })

  test('each snippet is only fetched once', async () => {
    setUpPage()
    pick('sign_up_level', 'in_between')
    clickContinue('level')

    chooseLanguage('go')
    await flush()
    chooseLanguage('ruby')
    await flush()
    chooseLanguage('go')
    await flush()

    expect(global.fetch).toHaveBeenCalledTimes(2)
  })

  test('a failed snippet shows the error', async () => {
    mockSnippet(false)
    setUpPage()
    pick('sign_up_level', 'in_between')
    clickContinue('level')

    chooseLanguage('go')
    await flush()

    expect(
      document.querySelector<HTMLElement>('[data-code-error]')!.hidden
    ).toBe(false)
    expect(
      document.querySelector<HTMLElement>('.code-check-answers')!.hidden
    ).toBe(true)
  })

  test('Easy goes to the form as a junior, with the track', async () => {
    setUpPage()
    pick('sign_up_level', 'in_between')
    clickContinue('level')
    chooseLanguage('go')
    await flush()

    pick('sign_up_code_check', 'easy')
    clickContinue('code')

    expect(visibleStep()).toEqual(['form'])
    expect(answers('seniority')).toEqual(['junior', 'junior'])
    expect(answers('sign_up_track_slug')).toEqual(['go', 'go'])
    expect(dialog().hasAttribute('open')).toBe(false)
    expect(dot(2).disabled).toBe(false)
  })

  test.each(['tricky', 'impossible'])(
    '%s goes to the form as a beginner, with the pop-up',
    async (check) => {
      setUpPage()
      pick('sign_up_level', 'in_between')
      clickContinue('level')
      chooseLanguage('go')
      await flush()

      pick('sign_up_code_check', check)
      clickContinue('code')

      expect(answers('seniority')).toEqual(['beginner', 'beginner'])
      expect(answers('sign_up_track_slug')).toEqual(['go', 'go'])
      expect(dialog().getAttribute('aria-labelledby')).toBe(
        'sign-up-jiki-heading-beginner'
      )
    }
  )

  test('changing language clears the code check answer', async () => {
    setUpPage()
    pick('sign_up_level', 'in_between')
    clickContinue('level')
    chooseLanguage('go')
    await flush()
    pick('sign_up_code_check', 'easy')

    chooseLanguage('ruby')

    expect(
      document.querySelector<HTMLButtonElement>('[data-continue="code"]')!
        .disabled
    ).toBe(true)
  })

  test('the dismiss button closes the pop-up and leaves the form', () => {
    setUpPage()
    pick('sign_up_level', 'total_beginner')
    clickContinue('level')

    dialog().querySelector<HTMLButtonElement>('[data-jiki-dismiss]')!.click()

    expect(dialog().hasAttribute('open')).toBe(false)
    expect(visibleStep()).toEqual(['form'])
  })

  test('the first progress dot goes back to the level question', () => {
    setUpPage()
    pick('sign_up_level', 'confident_developer')
    clickContinue('level')

    expect(dot(2).disabled).toBe(true)
    dot(1).click()

    expect(visibleStep()).toEqual(['level'])
  })

  test('does nothing without the flow on the page', () => {
    document.body.innerHTML = '<form></form>'

    expect(() => initSignUpFlow()).not.toThrow()
  })

  test('only initialises once', () => {
    setUpPage()
    document.dispatchEvent(new Event('turbo:load'))

    pick('sign_up_level', 'in_between')
    clickContinue('level')

    expect(visibleStep()).toEqual(['code'])
    expect(section('code').hidden).toBe(false)
  })
})
