import {
  LOCALE_PREF_COOKIE,
  setLocalePrefCookie,
  initLocalePrefLinks,
} from '@/utils/locale-pref-cookie'

test('records the chosen locale', () => {
  setLocalePrefCookie('hu')

  expect(document.cookie).toContain(`${LOCALE_PREF_COOKIE}=hu`)
})

test('a click on a switcher link records the choice before navigating', () => {
  document.body.innerHTML =
    '<a href="/hu/tracks" data-locale-pref="hu"><span>magyar</span></a>'
  initLocalePrefLinks()

  document.querySelector('span')!.dispatchEvent(
    new MouseEvent('click', { bubbles: true })
  )

  expect(document.cookie).toContain(`${LOCALE_PREF_COOKIE}=hu`)
})
