import React, { useContext } from 'react'
import { TrackContext } from '../TrackWelcomeModal'
import { GraphicalIcon } from '@/components/common'

export function BootcampRecommendationView() {
  const { hideBootcampRecommendationView, links } = useContext(TrackContext)

  // EDIT COPY
  // shown on TrackWelcomeModal

  return (
    <>
      <h4
        data-capy-element="bootcamp-recommendation-header"
        className="text-h4 mb-8"
      >
        Our Bootcamp might be better for you…
      </h4>

      <p className="mb-8">
        Exercism's tracks are designed for people who{' '}
        <strong className="font-medium">already know how to code</strong> and
        are practicing or learning new languages.
      </p>
      <p className="mb-8">
        If you're just starting out on your coding journey,{' '}
        <strong className="font-semibold">
          our Bootcamp might be a better fit for you.
        </strong>{' '}
        It offers:
      </p>
      <ul className="flex flex-col gap-2 text-14 font-medium mb-8">
        <li className="flex items-center">
          <GraphicalIcon
            icon="wave"
            category="bootcamp"
            className="mr-8 w-[20px]"
          />
          Expert teaching and mentoring support
        </li>
        <li className="flex items-center">
          <GraphicalIcon
            icon="fun"
            category="bootcamp"
            className="mr-8 w-[20px]"
          />
          Hands-on project based learning
        </li>
        <li className="flex items-center">
          <GraphicalIcon
            icon="complete"
            category="bootcamp"
            className="mr-8 w-[20px]"
          />
          A complete Learn to Code syllabus
        </li>
        <li className="flex items-center">
          <GraphicalIcon
            icon="certificate"
            category="bootcamp"
            className="mr-8 w-[20px]"
          />
          A formal certificate on completion
        </li>
      </ul>
      <p className="mb-16">
        It's part time, remote, and priced affordably, with discounts available
        for students, people who are unemployed, and those living in emerging
        economies.
      </p>

      <div className="flex gap-12 items-center w-full">
        <a
          href={links.bootcampLanding}
          data-capy-element="go-to-bootcamp-button"
          className="btn-m btn-primary flex-grow"
        >
          Check out the Bootcamp
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
