const nav = document.querySelector('#nav')
const bootcamp = document.querySelector('#bootcamp')
const rockSolid = document.querySelector('.rock-solid')
const tagline = document.querySelector('.tagline')
const videoContainer = document.querySelector('.video-container')
const exercismFace = document.querySelector('.exercism-face')

const ON_PURPLE_CLASS = 'on-purple'
const FLOATING_CLASS = 'floating'

// 1. leaving rock-solid => hide nav immediately
// 2. leaving tagline && rock-solid => make it sticky
// 3. leaving video-container => show nav smoothly
// same in reverse

let isRockSolidIntersecting
const intersectionCallback = (entries) => {
  entries.forEach((entry) => {
    switch (entry.target) {
      case rockSolid:
        entry.isIntersecting
          ? immediateOpacityChange(1)
          : immediateOpacityChange(0)
        isRockSolidIntersecting = entry.isIntersecting
        break
      case tagline:
        entry.isIntersecting || isRockSolidIntersecting
          ? makeInline()
          : makeSticky()
        break
      case videoContainer:
        entry.isIntersecting && !isRockSolidIntersecting
          ? smoothOpacityChange(0)
          : smoothOpacityChange(1)
        break
    }
  })
}

const bootcampObserverCb = (entries) => {
  entries[0].isIntersecting ? addOnPurpleClass() : removeOnPurpleClass()
}

// 90% of the bootcamp section is visible
const bootcampObserver = new IntersectionObserver(bootcampObserverCb, {
  rootMargin: '0px 0px -90% 0px',
})
const navObserver = new IntersectionObserver(intersectionCallback)

navObserver.observe(rockSolid)
navObserver.observe(tagline)
navObserver.observe(videoContainer)
bootcampObserver.observe(bootcamp)

/* helper fns */
function smoothOpacityChange(opacity) {
  // nav.style.transition = "opacity 0.3s ease-out";
  nav.style.opacity = `${opacity}`
}

function immediateOpacityChange(opacity) {
  nav.style.opacity = `${opacity}`
}

function makeSticky() {
  nav.classList.add(FLOATING_CLASS)
}

function makeInline() {
  nav.classList.remove(FLOATING_CLASS)
}

function addOnPurpleClass() {
  exercismFace.style.filter = 'invert(1)'
  nav.classList.add(ON_PURPLE_CLASS)
}

function removeOnPurpleClass() {
  exercismFace.style.filter = ''
  nav.classList.remove(ON_PURPLE_CLASS)
}
