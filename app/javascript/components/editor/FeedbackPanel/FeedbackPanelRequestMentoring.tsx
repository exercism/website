import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { FeedbackPanelProps } from './FeedbackPanel'

export function RequestMentoring({
  exercise,
  track,
  mentorDiscussionsLink,
}: Pick<
  FeedbackPanelProps,
  'exercise' | 'track' | 'mentorDiscussionsLink'
>): JSX.Element {
  return (
    <section className="pt-10">
      <div className="pb-20 mb-20 border-b-1 border-borderColor5">
        <div className="flex items-start">
          <div>
            <h2 className="text-h4 mb-4">
              Take your solution to the next level
            </h2>
            <p className="text-p-base mb-16">
              Get feedback on your solution to {exercise.title} by a{' '}
              {track.title} mentor and discover new ways to approach the
              problem, and expand and deepen your {track.title} knowledge.
            </p>
          </div>
          <GraphicalIcon
            icon="mentoring-prompt"
            category="graphics"
            height={110}
            width={110}
            className="ml-48 mt-20"
          />
        </div>
        <div className="flex">
          <a className="btn-primary btn-m mb-8" href={mentorDiscussionsLink}>
            Submit for code review
          </a>
          <div className="ml-16 px-16 text-midnightBlue bg-lightOrange rounded-8 flex items-center justify-center text-h6 leading-120 h-[48px] text-center">
            It&apos;s 100% free! 😲
          </div>
        </div>
      </div>

      <h3 className="text-h4 mb-8">Why get feedback?</h3>
      <div className="mb-12">
        <h4 className="text-h6 mb-4">Attain real fluency in {track.title}</h4>
        <p className="text-p-base">
          Learning a language is more than being able to use it, it&apos;s about
          being able to <strong className="font-semibold">think</strong> in it.
          Our mentors will help develop your perceptions.
        </p>
      </div>

      <div className="mb-12">
        <h4 className="text-h6 mb-4">
          {' '}
          You don&apos;t know what you don&apos;t know
        </h4>
        <p className="text-p-base">
          It&apos;s hard to progress when you don&apos;t know what&apos;s
          missing. Our mentors will help you discover the gaps in your{' '}
          {track.title} knowledge.
        </p>
      </div>

      <div className="mb-12">
        <h4 className="text-h6 mb-4">Get your questions answered</h4>
        <p className="text-p-base">
          {' '}
          Whatever your questions, our mentors will be able to help you. Make
          sure you ask what&apos;s on your mind when requesting a mentor.
        </p>
      </div>

      <div className="mb-12">
        <h4 className="text-h6 mb-4"> Push yourself</h4>
        <p className="text-p-base">
          {' '}
          However confident you feel in {track.title}, there will always be more
          to learn. Push yourself further with an Exercism mentor.
        </p>
      </div>
    </section>
  )
}
