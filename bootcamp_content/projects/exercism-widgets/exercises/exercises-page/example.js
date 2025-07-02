let exercises = null
let solutions = null
const exercisesContainer = document.querySelector('#exercises')
const searchBar = document.querySelector('input')
const filters = Array.from(document.querySelectorAll('.filter'))

function loadExercises(data) {
  exercises = data['exercises']
  solutions = data['solutions']
  exercises.forEach((exercise) => {
    exercise.status = statusForExercise(exercise)
  })
  showExercises()

  filters.forEach((filter) => {
    const status = filter.dataset['status']
    const count = exercises.reduce((acc, exercise) => {
      return exerciseHasStatus(exercise, status) ? acc + 1 : acc
    }, 0)
    filter.querySelector('.count').innerHTML = count
  })
}

const solutionForExercise = (e) =>
  solutions.find((s) => s.exercise.slug == e.slug)

function showExercises() {
  const selectedStatus =
    document.querySelector('.filter.selected').dataset['status']
  const exercisesToShow = exercises.filter((exercise) => {
    return exerciseHasStatus(exercise, selectedStatus)
  })
  exercisesContainer.innerHTML = ''

  exercisesToShow.forEach((exercise) => {
    const solution = solutionForExercise(exercise)
    const numIterations = solution?.num_iterations || 0
    log(numIterations)
    const html = `<a class="exercise ${exercise.status}" href="${
      exercise.links.self
    }">
      <img src="${exercise.icon_url}" />
      <div class="info">
        <div class="title">${exercise.title}</div>
        <div class="tags">
          <div class="tag status available">Available</div>
          <div class="tag status in-progress">In Progress</div>
          <div class="tag status completed">Completed</div>
          <div class="tag status published">Published</div>
          <div class="tag difficulty easy">Easy</div>
          ${
            numIterations > 0
              ? `<div class="iterations">
            <img src="https://assets.exercism.org/assets/icons/iteration-cbd4b704343ebd63c734d97103ef805b15ae2409.svg" alt="" class="c-icon">
              ${numIterations} ${numIterations > 1 ? 'iterations' : 'iteration'}
            </div>`
              : ''
          }
        </div>
      <div class="description">${exercise.blurb}</div>
      </div>
    </a>`
    const template = document.createElement('template')
    template.innerHTML = html
    exercisesContainer.appendChild(template.content.firstElementChild)
  })
}

const loadData = () => {
  const criteria = searchBar.value
  const opts = { sideload: 'solutions' }
  if (criteria != '') {
    opts['criteria'] = criteria
  }

  const params = Object.entries(opts)
    .map(([k, v]) => `${k}=${encodeURIComponent(v)}`)
    .join('&')
  const url = `https://exercism.org/api/v2/tracks/ruby/exercises?${params}`
  fetchObject(url, {}, loadExercises)
}
searchBar.addEventListener('keyup', loadData)

function statusForExercise(exercise) {
  const solution = solutionForExercise(exercise)
  if (solution) {
    if (solution.published_at) return 'published'
    if (solution.completed_at) return 'completed'
    return 'in-progress'
  }
  return exercise.is_unlocked ? 'available' : 'locked'
}

function exerciseHasStatus(exercise, status) {
  if (status == 'all') return true
  if (status == 'completed')
    return exercise.status == 'completed' || exercise.status == 'published'

  return status == exercise.status
}

function changeFilter(filter) {
  filters.forEach((filter) => {
    filter.classList.remove('selected')
  })
  filter.classList.add('selected')

  const status = filter.dataset['status']
  showExercises()
}
filters.forEach((filter) => {
  filter.addEventListener('click', () => changeFilter(filter))
})
loadData()
