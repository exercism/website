import { initLocalePrefLinks } from '@/utils/locale-pref-cookie'
import { initLocaleBanner } from '@/utils/locale-banner'
initLocalePrefLinks()
initLocaleBanner()

import { annotateLanding } from '../utils/annotate-landing'
annotateLanding()

const siteFooter = document.getElementById('site-footer')
if (siteFooter) {
  siteFooter.style.display = 'block'
}
