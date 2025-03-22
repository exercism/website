import Lottie from 'lottie-web'
import arrowAnimation from './lottiefiles/arrow-animation.json'
import arrow3 from './lottiefiles/arrow-3.json'

const animationContainers = document.querySelectorAll('.arrow-animation')

function getAnimationData(id) {
  switch (id) {
    case 'rhodri':
    case 'jiki':
      return arrow3
    default:
      return arrowAnimation
  }
}

const observer = new IntersectionObserver(
  (entries, observer) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        Lottie.loadAnimation({
          container: entry.target,
          renderer: 'svg',
          loop: false,
          autoplay: true,
          animationData: getAnimationData(entry.target.id),
        })
        observer.unobserve(entry.target)
      }
    })
  },
  // animationContainer must be in the upper ~2/3 of the viewport
  { rootMargin: '0px 0px -30% 0px' }
)

animationContainers.forEach((animationContainer) => {
  observer.observe(animationContainer)
})
