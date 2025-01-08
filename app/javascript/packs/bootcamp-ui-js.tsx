import React from 'react'
import { lazy, Suspense } from 'react'
import { initReact } from '../utils/react-bootloader'
import '@hotwired/turbo-rails'
import { camelizeKeysAs } from '@/utils/camelize-keys-as'

const SolveExercisePage = lazy(
  () => import('../components/bootcamp/SolveExercisePage/SolveExercisePage')
)

declare global {
  interface Window {
    turboLoaded: boolean
  }
}
// As we're sensitive to the order of things across different packs
// we set a window-level constant to record when turbo has loaded
// so that other packs that haven't yet rendered events can respond to them
document.addEventListener('turbo:load', () => (window.turboLoaded = true))

const mappings = {
  'bootcamp-solve-exercise-page': (
    data: SolveExercisePageProps
  ): JSX.Element => (
    <Suspense>
      <SolveExercisePage {...camelizeKeysAs<SolveExercisePageProps>(data)} />
    </Suspense>
  ),
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact(mappings)
