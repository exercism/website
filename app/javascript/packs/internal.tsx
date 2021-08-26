import 'easymde/dist/easymde.min.css'

require('channels')

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
  SolutionForStudent,
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
import { Nudge as StudentNudge } from '../components/student/Nudge'
import { IterationsList as StudentIterationsList } from '../components/student/IterationsList'
import { SolutionSummary as StudentSolutionSummary } from '../components/student/SolutionSummary'
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

import { Notifications as NotificationsDropdown } from '../components/dropdowns/Notifications'
import { Reputation as ReputationDropdown } from '../components/dropdowns/Reputation'
import { TrackMenu as TrackMenuDropdown } from '../components/dropdowns/TrackMenu'
import { Links as TrackMenuLinks } from '../components/dropdowns/TrackMenu'

import {
  Track as IterationsListTrack,
  Exercise as IterationsListExercise,
  Links as IterationsListLinks,
  IterationsListRequest,
} from '../components/student/IterationsList'
import { IterationSummaryWithWebsockets } from '../components/track/IterationSummary'
import {
  SolutionSummaryLinks,
  Track as SolutionSummaryTrack,
  SolutionSummaryRequest,
} from '../components/student/SolutionSummary'
import {
  Links as NudgeLinks,
  Track as NudgeTrack,
} from '../components/student/Nudge'
import { Links as PublishedSolutionLinks } from '../components/student/PublishedSolution'

import { Links as NotificationsListLinks } from '../components/notifications/NotificationsList'
import * as Notifications from '../components/notifications'

import { Request } from '../hooks/request-query'
import { Request as MentoringInboxRequest } from '../components/mentoring/Inbox'
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
      discussionsRequest={camelizeKeysAs<MentoringInboxRequest>(
        data.discussions_request
      )}
      tracksRequest={camelizeKeysAs<MentoringInboxRequest>(data.tracks_request)}
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
      text={data.text}
      size={data.size}
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
      outOfDate={data.out_of_date}
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
  'dropdowns-notifications': (data: any) => (
    <NotificationsDropdown endpoint={data.endpoint} />
  ),
  'dropdowns-reputation': (data: any) => (
    <ReputationDropdown
      endpoint={data.endpoint}
      defaultIsSeen={data.is_seen}
      defaultReputation={data.reputation}
    />
  ),
  'dropdowns-track-menu': (data: any) => (
    <TrackMenuDropdown
      track={data.track}
      links={camelizeKeysAs<TrackMenuLinks>(data.links)}
    />
  ),
  'notifications-notifications-list': (data: any) => (
    <Notifications.NotificationsList
      request={camelizeKeysAs<Request>(data.request)}
      links={camelizeKeysAs<NotificationsListLinks>(data.links)}
    />
  ),
  'track-iteration-summary': (data: any) => (
    <IterationSummaryWithWebsockets
      iteration={camelizeKeysAs<Iteration>(data.iteration)}
      className={data.class_name}
      showSubmissionMethod={true}
      showTestsStatusAsButton={!!data.show_tests_status_as_button}
      showFeedbackIndicator={!!data.show_feedback_indicator}
    />
  ),
  'student-iterations-list': (data: any) => (
    <StudentIterationsList
      solutionUuid={data.solution_uuid}
      request={camelizeKeysAs<IterationsListRequest>(data.request)}
      exercise={camelizeKeysAs<IterationsListExercise>(data.exercise)}
      track={camelizeKeysAs<IterationsListTrack>(data.track)}
      links={camelizeKeysAs<IterationsListLinks>(data.links)}
    />
  ),
  'student-solution-summary': (data: any) => (
    <StudentSolutionSummary
      discussions={camelizeKeysAs<MentorDiscussion[]>(data.discussions)}
      solution={camelizeKeysAs<SolutionForStudent>(data.solution)}
      request={camelizeKeysAs<SolutionSummaryRequest>(data.request)}
      links={camelizeKeysAs<SolutionSummaryLinks>(data.links)}
      track={camelizeKeysAs<SolutionSummaryTrack>(data.track)}
      exerciseType={data.exercise_type}
    />
  ),

  'student-nudge': (data: any) => (
    <StudentNudge
      solution={camelizeKeysAs<SolutionForStudent>(data.solution)}
      track={camelizeKeysAs<NudgeTrack>(data.track)}
      discussions={camelizeKeysAs<readonly MentorDiscussion[]>(
        data.discussions
      )}
      request={camelizeKeysAs<SolutionSummaryRequest>(data.request)}
      iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
      exerciseType={data.exercise_type}
      links={camelizeKeysAs<NudgeLinks>(data.links)}
    />
  ),

  'student-publish-solution-button': (data: any) => (
    <Student.PublishSolutionButton
      endpoint={data.endpoint}
      iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
    />
  ),
  'student-published-solution': (data: any) => (
    <Student.PublishedSolution
      solution={camelizeKeysAs<CommunitySolution>(data.solution)}
      publishedIterationIdx={data.published_iteration_idx}
      iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
      links={camelizeKeysAs<PublishedSolutionLinks>(data.links)}
    />
  ),
  'student-update-exercise-notice': (data: any) => (
    <Student.UpdateExerciseNotice links={data.links} />
  ),
})
