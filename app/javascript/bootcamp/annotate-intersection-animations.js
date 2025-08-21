import { annotate } from 'rough-notation'
const defaultIntersectionOptions = { rootMargin: '0px 0px -30% 0px' }
function createAnnotateObserver(
  options,
  intersectionOptions = defaultIntersectionOptions
) {
  return new IntersectionObserver((entries, observer) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        annotate(entry.target, options).show()
        observer.unobserve(entry.target)
      }
    })
  }, intersectionOptions)
}
const highlightConfig = {
  type: 'highlight',
  color: '#FFF176',
  strokeWidth: 6,
  iterations: 1,
  multiline: true,
  animationDuration: 500,
  padding: 8,
  roughness: 2,
}

const underlineConfig = {
  type: 'underline',
  animationDuration: 500,
  color: 'rgb(112, 42, 244)',
  multiline: true,
  iterations: 1,
  padding: -4,
  roughness: 1,
}

const wavingObserver = new IntersectionObserver(
  ([wavingHandEntry], observer) => {
    if (wavingHandEntry.isIntersecting) {
      wavingHandEntry.target.classList.add('waving-hand-animation')
      observer.disconnect()
    }
  },
  defaultIntersectionOptions
)

const roughUnderlineObserver = createAnnotateObserver(underlineConfig)
const roughHighlightObserver = createAnnotateObserver(highlightConfig)

const roughUnderlineElements = document.querySelectorAll('.rough-underline')
const roughHighlightElements = document.querySelectorAll('.rough-highlight')
const wavingElement = document.querySelector('.waving-hand')

if (wavingElement) wavingObserver.observe(wavingElement)

roughUnderlineElements.forEach((element) => {
  roughUnderlineObserver.observe(element)
})
roughHighlightElements.forEach((element) => {
  roughHighlightObserver.observe(element)
})
