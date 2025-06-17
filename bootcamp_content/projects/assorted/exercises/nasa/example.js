const resultElem = document.querySelector('#result')
const titleElem = document.querySelector('h2')
const descElem = document.querySelector('p')
const bylineElem = document.querySelector('#byline')

function handleResult(data) {
  const item = data['collection']['items'][0]
  const itemData = item.data[0]
  const imgSrc = item['links'][0]['href']
  resultElem.style.backgroundImage = `url("${imgSrc}")`
  titleElem.innerText = itemData.title
  descElem.innerText = itemData.description
  if (itemData.photographer) {
    bylineElem.innerText = `By ${itemData.photographer}`
    bylineElem.style.display = 'block'
  } else {
    bylineElem.style.display = 'none'
  }
}

document.querySelector('form').addEventListener('submit', (e) => {
  e.preventDefault()

  const query = encodeURIComponent(document.querySelector('#query').value)
  const url = `https://images-api.nasa.gov/search?q=${query}&media_type=image`
  log(url)
  fetchObject(url, {}, handleResult)
})
