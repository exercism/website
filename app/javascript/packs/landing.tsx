import { annotateLanding } from '../utils/annotate-landing'
annotateLanding()

const siteFooter = document.getElementById('site-footer')
if (siteFooter) {
  siteFooter.style.display = 'block'
}
