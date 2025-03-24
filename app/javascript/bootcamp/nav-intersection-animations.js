const navFixed = document.querySelector('#nav-fixed')
const navSticky = document.querySelector('#nav-sticky')
const navContents = document.querySelector('#nav-contents')
const hero = document.querySelector('.hero')
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

if (rockSolid) navObserver.observe(rockSolid)
if (tagline) navObserver.observe(tagline)
if (videoContainer) navObserver.observe(videoContainer)
if (bootcamp) bootcampObserver.observe(bootcamp)

/* helper fns */
function smoothOpacityChange(opacity) {
  navSticky.style.opacity = `${opacity}`
}

function makeSticky() {
  navSticky.style.height = 'auto'
  navSticky.style.padding = '10px'
  navSticky.append(navContents)
}

function makeInline() {
  navSticky.style.height = '0px'
  navSticky.style.padding = '0px'
  navFixed.append(navContents)
}

function addOnPurpleClass() {
  exercismFace.style.filter = 'invert(1)'
  navSticky.classList.add(ON_PURPLE_CLASS)
}

function removeOnPurpleClass() {
  exercismFace.style.filter = ''
  navSticky.classList.remove(ON_PURPLE_CLASS)
}
