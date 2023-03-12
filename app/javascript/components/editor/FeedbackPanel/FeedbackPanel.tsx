import React from 'react'
import { GraphicalIcon, Tab } from '@/components/common'
import { TabsContext } from '../../Editor'
import { Iteration, MentorDiscussion, Exercise, Track } from '../../types'
import { AutomatedFeedback } from './FeedbackPanelAutomatedFeedback'
import { MentoringDiscussion } from './FeedbackPanelMentoringDiscussion'

export type FeedbackPanelProps = {
  iteration?: Pick<Iteration, 'analyzerFeedback' | 'representerFeedback'>
  exercise: Pick<Exercise, 'title'>
  track: Pick<Track, 'title' | 'iconUrl'>
  automatedFeedbackInfoLink: string
  mentorDiscussionsLink: string
  discussion?: MentorDiscussion
}
export const FeedbackPanel = ({
  iteration,
  exercise,
  track,
  automatedFeedbackInfoLink,
  mentorDiscussionsLink,
  discussion,
}: FeedbackPanelProps): JSX.Element => {
  const AutomatedFeedbackProps = { iteration, track, automatedFeedbackInfoLink }

  const HasFeedback =
    discussion || iteration?.analyzerFeedback || iteration?.representerFeedback

  return (
    <Tab.Panel id="feedback" context={TabsContext}>
      <section className="feedback-pane">
        {HasFeedback ? (
          <>
            <AutomatedFeedback {...AutomatedFeedbackProps} />
            <MentoringDiscussion discussion={discussion} />
          </>
        ) : (
          <RequestMentoring
            track={track}
            exercise={exercise}
            mentorDiscussionsLink={mentorDiscussionsLink}
          />
        )}
      </section>
    </Tab.Panel>
  )
}

function RequestMentoring({
  exercise,
  track,
  mentorDiscussionsLink,
}: Pick<
  FeedbackPanelProps,
  'exercise',
  'track',
  'mentorDiscussionsLink'
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
            height="110"
            width="110"
            className="ml-48 mt-20"
          />
        </div>
        <div className="flex">
          <a className="btn-primary btn-m mb-8" href={mentorDiscussionsLink}>
            Submit for code review
          </a>
          <div className="ml-16 px-16 bg-lightOrange rounded-8 flex items-center justify-center text-h6 leading-120 h-[48px] text-center">
            It&apos;s 100% free! 😲
          </div>
        </div>
      </div>

      <h3 className="text-h4 mb-8">Why get feedback?</h3>
      <div className="mb-12">
        <h4 className="text-h6 mb-4">Attain real fluency in {track.title}</h4>
        <p className="text-p-base">
          Learning a language is more than being able to use it, it's about
          being able to <strong className="font-semibold">think</strong> in it.
          Our mentors will help develop your perceptions.
        </p>
      </div>

      <div className="mb-12">
        <h4 className="text-h6 mb-4"> You don't know what you don't know</h4>
        <p className="text-p-base">
          It's hard to progress when you don't know what's missing. Our mentors
          will help you discover the gaps in your {track.title} knowledge.
        </p>
      </div>

      <div className="mb-12">
        <h4 className="text-h6 mb-4">Get your questions answered</h4>
        <p className="text-p-base">
          {' '}
          Whatever your questions, our mentors will be able to help you. Make
          sure you ask what's on your mind when requesting a mentor.
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
