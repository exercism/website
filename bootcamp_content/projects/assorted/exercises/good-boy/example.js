const dogs = [
  {
    elem: document.querySelector('#dog-1'),
    button: document.querySelector('#dog-1 button'),
    spinner: document.querySelector('#dog-1 svg'),
    img: document.querySelector('#dog-1 img'),
    video: document.querySelector('#dog-1 video'),
    success: document.querySelector('#dog-1 .success'),
  },
  {
    elem: document.querySelector('#dog-2'),
    button: document.querySelector('#dog-2 button'),
    spinner: document.querySelector('#dog-2 svg'),
    img: document.querySelector('#dog-2 img'),
    video: document.querySelector('#dog-2 video'),
    success: document.querySelector('#dog-2 .success'),
  },
]

function fetchDog(successFunction) {
  fetchObject('https://random.dog/woof.json', {}, successFunction)
}

function updateDog(idx, callback) {
  dogs[idx].img.style.display = 'none'
  dogs[idx].video.style.display = 'none'
  dogs[idx].spinner.style.display = 'block'

  fetchDog((data) => {
    if (data.url.endsWith('.mp4')) {
      dogs[idx].video.addEventListener(
        'loadeddata',
        () => {
          dogs[idx].spinner.style.display = 'none'
          dogs[idx].video.style.display = 'block'
          callback()
        },
        { once: true }
      )
      dogs[idx].video.src = data.url
    } else {
      dogs[idx].img.addEventListener(
        'load',
        () => {
          dogs[idx].spinner.style.display = 'none'
          dogs[idx].img.style.display = 'block'
          callback()
        },
        { once: true }
      )
      dogs[idx].img.src = data.url
    }
  })
}

function chooseDog(idx) {
  dogs[idx].success.style.display = 'grid'
  dogs.forEach((dog) => dog.button.setAttribute('disabled', true))

  const otherDog = idx == 0 ? 1 : 0
  updateDog(otherDog, () => {
    dogs[idx].success.style.display = 'none'
    dogs.forEach((dog) => dog.button.removeAttribute('disabled'))
  })
}

dogs[0].button.addEventListener('click', () => chooseDog(0))
dogs[1].button.addEventListener('click', () => chooseDog(1))

updateDog(0, () => {})
updateDog(1, () => {})
