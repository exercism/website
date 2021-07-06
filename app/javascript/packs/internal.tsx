import 'easymde/dist/easymde.min.css'

import React from 'react'
import { initReact } from '../utils/react-bootloader.jsx'

import {
  Iteration,
  // Track,
  // Exercise,
  MentorSessionRequest,
  MentorSessionTrack,
  MentorSessionExercise,
  MentorDiscussion,
  MentoredTrack,
  // SolutionForStudent,
  CommunitySolution,
  Testimonial,
  MentoredTrackExercise,
  // User,
  // SiteUpdate,
  CommunicationPreferences,
  // TrackContribution,
} from '../components/types'

import * as Maintaining from '../components/maintaining'
import * as Mentoring from '../components/mentoring'
import * as Student from '../components/student'
import { Links as TryMentoringButtonLinks } from '../components/mentoring/TryMentoringButton'
import { Links as MentoringQueueLinks } from '../components/mentoring/Queue'

import { Student as MentoringSessionStudent } from '../components/types'
import {
  Links as MentoringSessionLinks,
  Scratchpad as MentoringSessionScratchpad,
} from '../components/mentoring/Session'
import {
  MentoringSession as StudentMentoringSession,
  Mentor as StudentMentoringSessionMentor,
  Video as StudentMentoringSessionVideo,
  Links as StudentMentoringSessionLinks,
} from '../components/student/MentoringSession'
import { Links as RequestMentoringButtonLinks } from '../components/student/RequestMentoringButton'
import { Track as MentoringTestimonialsListTrack } from '../components/mentoring/TestimonialsList'

import * as JourneyComponents from '../components/journey'
import { Category as JourneyPageCategory } from '../components/journey/JourneyPage'
import * as Settings from '../components/settings'
import { MarkdownEditor } from '../components/common/MarkdownEditor'

import { Request } from '../hooks/request-query'
import { camelizeKeys } from 'humps'
function camelizeKeysAs<T>(object: any): T {
  return (camelizeKeys(object) as unknown) as T
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  'common-markdown-editor': (data: any) => (
    <MarkdownEditor contextId={data.context_id} />
  ),

  'maintaining-submissions-summary-table': (data: any) => (
    <Maintaining.SubmissionsSummaryTable
      submissions={data.submissions.map((s: any) => {
        return camelizeKeys(s)
      })}
    />
  ),
  'mentoring-inbox': (data: any) => (
    <Mentoring.Inbox
      discussionsRequest={data.discussions_request}
      tracksRequest={data.tracks_request}
      sortOptions={data.sort_options}
    />
  ),
  'mentoring-queue': (data: any) => (
    <Mentoring.Queue
      queueRequest={camelizeKeysAs<Request>(data.queue_request)}
      tracksRequest={camelizeKeysAs<Request>(data.tracks_request)}
      defaultTrack={camelizeKeysAs<MentoredTrack>(data.default_track)}
      defaultExercise={camelizeKeysAs<MentoredTrackExercise>(
        data.default_exercise
      )}
      links={camelizeKeysAs<MentoringQueueLinks>(data.links)}
      sortOptions={data.sort_options}
    />
  ),
  'mentoring-session': (data: any) => (
    <Mentoring.Session
      userHandle={data.user_handle}
      discussion={camelizeKeysAs<MentorDiscussion>(data.discussion)}
      mentorSolution={camelizeKeysAs<CommunitySolution>(data.mentor_solution)}
      student={camelizeKeysAs<MentoringSessionStudent>(data.student)}
      track={camelizeKeysAs<MentorSessionTrack>(data.track)}
      exercise={camelizeKeysAs<MentorSessionExercise>(data.exercise)}
      iterations={camelizeKeysAs<Iteration[]>(data.iterations)}
      links={camelizeKeysAs<MentoringSessionLinks>(data.links)}
      request={camelizeKeysAs<MentorSessionRequest>(data.request)}
      scratchpad={camelizeKeysAs<MentoringSessionScratchpad>(data.scratchpad)}
      notes={data.notes}
      outOfDate={data.out_of_date}
    />
  ),
  'mentoring-try-mentoring-button': (data: any) => (
    <Mentoring.TryMentoringButton
      links={camelizeKeysAs<TryMentoringButtonLinks>(data.links)}
    />
  ),
  'mentoring-testimonials-list': (data: any) => (
    <Mentoring.TestimonialsList
      request={camelizeKeysAs<Request>(data.request)}
      tracks={camelizeKeysAs<readonly MentoringTestimonialsListTrack[]>(
        data.tracks
      )}
    />
  ),
  'student-mentoring-session': (data: any) => (
    <StudentMentoringSession
      userHandle={data.user_handle}
      discussion={camelizeKeysAs<MentorDiscussion>(data.discussion)}
      iterations={camelizeKeysAs<Iteration[]>(data.iterations)}
      mentor={camelizeKeysAs<StudentMentoringSessionMentor>(data.mentor)}
      track={camelizeKeysAs<MentorSessionTrack>(data.track)}
      exercise={camelizeKeysAs<MentorSessionExercise>(data.exercise)}
      trackObjectives={data.track_objectives}
      videos={camelizeKeysAs<StudentMentoringSessionVideo[]>(data.videos)}
      request={camelizeKeysAs<MentorSessionRequest>(data.request)}
      links={camelizeKeysAs<StudentMentoringSessionLinks>(data.links)}
    />
  ),
  'student-request-mentoring-button': (data: any) => (
    <Student.RequestMentoringButton
      request={data.request}
      links={camelizeKeysAs<RequestMentoringButtonLinks>(data.links)}
    />
  ),

  'journey-journey-page': (data: any) => (
    <JourneyComponents.JourneyPage
      categories={camelizeKeysAs<readonly JourneyPageCategory[]>(
        data.categories
      )}
      defaultCategory={data.default_category}
    />
  ),
  'settings-profile-form': (data: any) => (
    <Settings.ProfileForm defaultUser={data.user} links={data.links} />
  ),
  'settings-pronouns-form': (data: any) => (
    <Settings.PronounsForm
      handle={data.handle}
      defaultPronounParts={data.pronoun_parts}
      links={data.links}
    />
  ),
  'settings-handle-form': (data: any) => (
    <Settings.HandleForm defaultHandle={data.handle} links={data.links} />
  ),
  'settings-email-form': (data: any) => (
    <Settings.EmailForm defaultEmail={data.email} links={data.links} />
  ),
  'settings-password-form': (data: any) => (
    <Settings.PasswordForm links={data.links} />
  ),
  'settings-token-form': (data: any) => (
    <Settings.TokenForm defaultToken={data.token} links={data.links} />
  ),
  'settings-communication-preferences-form': (data: any) => (
    <Settings.CommunicationPreferencesForm
      defaultPreferences={camelizeKeysAs<CommunicationPreferences>(
        data.preferences
      )}
      links={data.links}
    />
  ),
  'settings-delete-account-button': (data: any) => (
    <Settings.DeleteAccountButton handle={data.handle} links={data.links} />
  ),
  'settings-reset-account-button': (data: any) => (
    <Settings.ResetAccountButton handle={data.handle} links={data.links} />
  ),
})
