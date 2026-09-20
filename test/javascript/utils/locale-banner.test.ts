import { initLocaleBanner } from '@/utils/locale-banner'

const BANNER =
  '<div data-locale-banner="hu"><button data-locale-banner-dismiss>Dismiss</button></div>'

beforeEach(() => {
  window.localStorage.clear()
  document.body.innerHTML = BANNER
})

test('dismissing hides the banner and remembers it', () => {
  initLocaleBanner()
  const banner = document.querySelector<HTMLElement>('[data-locale-banner]')!

  document.querySelector<HTMLButtonElement>('[data-locale-banner-dismiss]')!.click()

  expect(banner.hidden).toBe(true)

  document.body.innerHTML = BANNER
  initLocaleBanner()

  expect(
    document.querySelector<HTMLElement>('[data-locale-banner]')!.hidden
  ).toBe(true)
})

test('dismissal is remembered per offered language', () => {
  initLocaleBanner()
  document.querySelector<HTMLButtonElement>('[data-locale-banner-dismiss]')!.click()

  document.body.innerHTML = BANNER.replace('"hu"', '"es-419"')
  initLocaleBanner()

  expect(
    document.querySelector<HTMLElement>('[data-locale-banner]')!.hidden
  ).toBe(false)
})
