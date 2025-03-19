import Lottie from 'lottie-web'
import hamsterJSON from './lottiefiles/hamster.json'

const hamsterContainer = document.getElementById('hamster-animation-container')
const scrollingTestimonials = document.querySelector('.scrolling-testimonials')

Lottie.loadAnimation({
  container: hamsterContainer,
  renderer: 'svg',
  loop: true,
  autoplay: true,
  animationData: hamsterJSON,
})

scrollingTestimonials.addEventListener('mouseover', () => {
  Lottie.setSpeed(2)
})

scrollingTestimonials.addEventListener('mouseout', () => {
  Lottie.setSpeed(1)
})
