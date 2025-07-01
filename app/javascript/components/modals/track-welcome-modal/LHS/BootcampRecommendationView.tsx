import React, { useContext } from 'react'
import { TrackContext } from '../TrackWelcomeModal'
import { Icon } from '@/components/common'

export function BootcampRecommendationView() {
  const { hideBootcampRecommendationView, links } = useContext(TrackContext)
  return (
    <>
      <h4
        data-capy-element="bootcamp-recommendation-header"
        className="text-h4 mb-8"
      >
        Coding Fundamentals might be better for you…
      </h4>

      <p className="mb-8">
        Exercism's tracks are designed for people who{' '}
        <strong className="font-semibold text-black">
          already know how to code
        </strong>{' '}
        and are practicing or learning new languages.
      </p>
      <p className="mb-8">
        If you're just starting out on your coding journey,{' '}
        <strong className="font-semibold text-black">
          our Coding Fundamentals Course might be a better fit for you.
        </strong>{' '}
      </p>
      <p className="mb-6">
        In 12 weeks, you'll go from zero to making these...
      </p>
      <div className="grid grid-cols-4 gap-10 mb-16">
        <Icon
          category="bootcamp"
          alt="Image of a space invaders game"
          icon="space-invaders.gif"
          className="w-full"
        />
        <Icon
          category="bootcamp"
          alt="Image of a tic-tac-toe game"
          icon="tic-tac-toe.gif"
          className="w-full"
        />
        <Icon
          category="bootcamp"
          alt="Image of a breakout game"
          icon="breakout.gif"
          className="w-full"
        />
        <Icon
          category="bootcamp"
          alt="Image of a maze game"
          icon="maze.gif"
          className="w-full"
        />
      </div>
      <p className="mb-12">
        It's self-paced and <strong>priced affordably</strong>, with discounts
        available for students, people who are unemployed, and those living in
        emerging economies.
      </p>

      <div className="flex gap-12 items-center w-full">
        <a
          href={links.codingFundamentalsCourse}
          data-capy-element="go-to-bootcamp-button"
          className="btn-m btn-primary grow"
        >
          Check out the Course ✨
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
