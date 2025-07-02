const trackNameElem = document.querySelector('#track-name')
const tracksElem = document.querySelector('#tracks')

function drawTrack(track) {
  const lastTouchedAt = Date.parse(track.last_touched_at)
  const now = new Date().getTime()
  const lastTouchDaysAgo = Math.floor(
    (now - lastTouchedAt) / 1000 / 60 / 60 / 24
  )
  const progressPercentage =
    (track.num_completed_exercises / track.num_exercises) * 100
  const html = `
    <a href="${track.web_url}" class="track">
      <div class="title-row">
        <img src="${track.icon_url}">
        <div class="track-name">${track.title}</div>
      </div>
      <div class="progress-info">
        <div class="exercises-info">
          <img src="https://assets.exercism.org/assets/icons/exercises-8a7df249fbfb76cc18efbbee844d9bd742830404.svg"/>
          <div class="count">${track.num_completed_exercises}/${track.num_exercises} exercises</div>
        </div>
        <div class="concepts-info">
          <img src="https://assets.exercism.org/assets/icons/concepts-982e268a7b685697712765d69d08e624c07a611a.svg"/>
          <div class="count">${track.num_learnt_concepts}/${track.num_concepts} concepts</div>
        </div>
      </div>
      <div class="progress-bar">
        <div class="complete" style="width: ${progressPercentage}%"></div>
      </div>
      <div class="last-touched">Last touched ${lastTouchDaysAgo} days ago</div>
    </a>
  `
  const template = document.createElement('template')
  template.innerHTML = html.trim()
  const trackElem = template.content.firstElementChild
  tracksElem.appendChild(trackElem)
}

function updateTracks(tracksData) {
  tracksElem.innerHTML = ''
  tracksData['tracks'].forEach(drawTrack)
}

function searchTracks() {
  const criteria = encodeURIComponent(trackNameElem.value)

  const url = `https://exercism.org/api/v2/tracks?criteria=${criteria}&page=1`
  fetchObject(url, {}, updateTracks)
}

trackNameElem.addEventListener('keyup', searchTracks)
searchTracks()
