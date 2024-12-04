import React, { useContext } from 'react'
import { TrackContext } from '../TrackWelcomeModal'

export function BootcampRecommendationView() {
  const { hideBootcampRecommendationView, track, links } =
    useContext(TrackContext)
  return (
    <>
      <h4 className="text-h4">You might find the Bootcamp is a better fit</h4>

      {/* TODO: Add copy */}
      <p className="mb-16">Here's why:</p>
      <ul className="flex flex-col gap-4 text-14 font-medium">
        <li>✅ You're new to {track.title}</li>
        <li>✅ You want a structured learning path</li>
        <li>✅ You want to build projects</li>
      </ul>

      <div className="grid grid-cols-2 gap-12 items-center">
        <a
          data-capy-element="go-to-bootcamp-button"
          href={links.bootcampLanding}
          className="btn-m btn-primary"
        >
          Go to bootcamp
        </a>
        <button
          onClick={hideBootcampRecommendationView}
          className="btn-m btn-secondary"
          data-capy-element="continue-anyway-button"
        >
          Continue anyway
        </button>
      </div>
    </>
  )
}
