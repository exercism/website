/* eslint-disable @typescript-eslint/no-explicit-any */
// Absolute, module imports
import React, { Suspense, lazy } from 'react'
import { camelizeKeys } from 'humps'
import currency from 'currency.js'
import { initReact } from '@/utils/react-bootloader'
import { camelizeKeysAs } from '@/utils'
import 'easymde/dist/easymde.min.css'

// Type imports
import type {
  Iteration,
  MentorSessionRequest,
  MentorSessionTrack,
  MentorSessionExercise,
  MentorDiscussion,
  MentoredTrack,
  SolutionForStudent,
  CommunitySolution,
  MentoredTrackExercise,
  CommunicationPreferences,
  User,
  MentoringSessionExemplarFile,
  SharePlatform,
  CompleteRepresentationData,
  Guidance,
} from '@/components/types'
import type { Links as TryMentoringButtonLinks } from '@/components/mentoring/TryMentoringButton'
import type { Links as MentoringQueueLinks } from '@/components/mentoring/Queue'

import type { Student as MentoringSessionStudent } from '@/components/types'
import type {
  Links as MentoringSessionLinks,
  Scratchpad as MentoringSessionScratchpad,
} from '@/components/mentoring/Session'
import type {
  Mentor as StudentMentoringSessionMentor,
  Video as StudentMentoringSessionVideo,
  Links as StudentMentoringSessionLinks,
} from '@/components/student/MentoringSession'
import type { Links as RequestMentoringButtonLinks } from '@/components/student/RequestMentoringButton'
import type { Track as MentoringTestimonialsListTrack } from '@/components/mentoring/TestimonialsList'
import type { Category as JourneyPageCategory } from '@/components/journey/JourneyPage'
import type { Links as TrackMenuLinks } from '@/components/dropdowns/TrackMenu'
import type {
  Track as IterationsListTrack,
  Exercise as IterationsListExercise,
  Links as IterationsListLinks,
  IterationsListRequest,
} from '@/components/student/IterationsList'
import type {
  SolutionSummaryLinks,
  Track as SolutionSummaryTrack,
  SolutionSummaryRequest,
} from '@/components/student/SolutionSummary'
import type {
  Links as NudgeLinks,
  Track as NudgeTrack,
} from '@/components/student/Nudge'
import type { Links as PublishedSolutionLinks } from '@/components/student/PublishedSolution'
import type { Links as NotificationsListLinks } from '@/components/notifications/NotificationsList'
import type { Request } from '@/hooks'
import type { Request as MentoringInboxRequest } from '@/components/mentoring/Inbox'
import type { AutomationProps } from '@/components/mentoring/automation/Representation'
import type { ThemePreferenceLinks } from '@/components/settings/ThemePreferenceForm'

import type { Props as EditorProps } from '@/components/editor/Props'
import type {
  CommentsPreferenceFormProps,
  UserPreferences,
} from '@/components/settings'
import type { FooterFormProps } from '@/components/donations/FooterForm'

// Component imports
const Editor = lazy(() => import('@/components/Editor'))
const SubmissionsSummaryTable = lazy(() => import('@/components/maintaining'))
const Inbox = lazy(() => import('@/components/mentoring/Inbox'))
const Queue = lazy(() => import('@/components/mentoring/Queue'))
const Session = lazy(() => import('@/components/mentoring/Session'))
const Representation = lazy(
  () => import('@/components/mentoring/Representation')
)
const TestimonialsList = lazy(
  () => import('@/components/mentoring/TestimonialsList')
)
const TryMentoringButton = lazy(
  () => import('@/components/mentoring/TryMentoringButton')
)
const RepresentationsWithFeedback = lazy(
  () => import('@/components/mentoring/automation/RepresentationsWithFeedback')
)
const RepresentationsWithoutFeedback = lazy(
  () =>
    import('@/components/mentoring/automation/RepresentationsWithoutFeedback')
)
const RepresentationsAdmin = lazy(
  () => import('@/components/mentoring/automation/RepresentationsAdmin')
)

const PublishSolutionButton = lazy(
  () => import('@/components/student/PublishSolutionButton')
)
const RequestMentoringButton = lazy(
  () => import('@/components/student/RequestMentoringButton')
)
const PublishedSolution = lazy(
  () => import('@/components/student/PublishedSolution')
)

const UpdateExerciseNotice = lazy(
  () => import('@/components/student/UpdateExerciseNotice')
)

const StudentNudge = lazy(() => import('@/components/student/Nudge'))

const StudentIterationsList = lazy(
  () => import('@/components/student/IterationsList')
)
const StudentSolutionSummary = lazy(
  () => import('@/components/student/SolutionSummary')
)

const StudentMentoringSession = lazy(
  () => import('@/components/student/MentoringSession')
)

const JourneyPage = lazy(() => import('@/components/journey/JourneyPage'))

const ProfileForm = lazy(() => import('@/components/settings/ProfileForm'))
const PhotoForm = lazy(() => import('@/components/settings/PhotoForm'))
const DeleteProfileForm = lazy(
  () => import('@/components/settings/DeleteProfileForm')
)
const PronounsForm = lazy(() => import('@/components/settings/PronounsForm'))
const HandleForm = lazy(() => import('@/components/settings/HandleForm'))
const EmailForm = lazy(() => import('@/components/settings/EmailForm'))
const PasswordForm = lazy(() => import('@/components/settings/PasswordForm'))
const UserPreferencesForm = lazy(
  () => import('@/components/settings/UserPreferencesForm')
)
const TokenForm = lazy(() => import('@/components/settings/TokenForm'))
const ThemePreferenceForm = lazy(
  () => import('@/components/settings/ThemePreferenceForm')
)
const CommentsPreferenceForm = lazy(
  () =>
    import(
      '@/components/settings/comments-preference-form/CommentsPreferenceForm'
    )
)

const CommunicationPreferencesForm = lazy(
  () => import('@/components/settings/CommunicationPreferencesForm')
)

const DeleteAccountButton = lazy(
  () => import('@/components/settings/DeleteAccountButton')
)
const ResetAccountButton = lazy(
  () => import('@/components/settings/ResetAccountButton')
)

const ShowOnSupportersPageButton = lazy(
  () => import('@/components/settings/ShowOnSupportersPageButton')
)

const MarkdownEditor = lazy(() => import('@/components/common/MarkdownEditor'))

const NotificationsDropdown = lazy(
  () => import('@/components/dropdowns/Notifications')
)

const ReputationDropdown = lazy(
  () => import('@/components/dropdowns/Reputation')
)

const TrackMenuDropdown = lazy(() => import('@/components/dropdowns/TrackMenu'))

const IterationSummaryWithWebsockets = lazy(
  () => import('@/components/track/IterationSummary')
)

const NotificationsList = lazy(
  () => import('@/components/notifications/NotificationsList')
)

const WelcomeModal = lazy(() => import('@/components/modals/WelcomeModal'))
const WelcomeToInsidersModal = lazy(
  () => import('@/components/modals/WelcomeToInsidersModal')
)
const DonationsFooterForm = lazy(
  () => import('@/components/donations/FooterForm')
)
const DonationsFormWithModal = lazy(
  () => import('@/components/donations/FormWithModal')
)

const DonationsSubscriptionForm = lazy(
  () => import('@/components/donations/SubscriptionForm')
)

import { renderLoader } from './application'

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  'common-markdown-editor': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <MarkdownEditor contextId={data.context_id} />
    </Suspense>
  ),

  editor: (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <Editor {...camelizeKeysAs<EditorProps>(data)} />
    </Suspense>
  ),

  'modals-welcome-modal': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <WelcomeModal endpoint={data.endpoint} />
    </Suspense>
  ),

  'modals-welcome-to-insiders-modal': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <WelcomeToInsidersModal endpoint={data.endpoint} />
    </Suspense>
  ),

  'maintaining-submissions-summary-table': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <SubmissionsSummaryTable
        submissions={data.submissions.map((s: any) => {
          return camelizeKeys(s)
        })}
      />
    </Suspense>
  ),
  'mentoring-inbox': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <Inbox
        discussionsRequest={camelizeKeysAs<MentoringInboxRequest>(
          data.discussions_request
        )}
        tracksRequest={camelizeKeysAs<MentoringInboxRequest>(
          data.tracks_request
        )}
        sortOptions={data.sort_options}
        links={data.links}
      />
    </Suspense>
  ),
  'mentoring-queue': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <Queue
        queueRequest={camelizeKeysAs<Request>(data.queue_request)}
        tracksRequest={camelizeKeysAs<Request>(data.tracks_request)}
        defaultTrack={camelizeKeysAs<MentoredTrack>(data.default_track)}
        defaultExercise={camelizeKeysAs<MentoredTrackExercise>(
          data.default_exercise
        )}
        links={camelizeKeysAs<MentoringQueueLinks>(data.links)}
        sortOptions={data.sort_options}
      />
    </Suspense>
  ),
  'mentoring-session': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <Session
        userHandle={data.user_handle}
        discussion={camelizeKeysAs<MentorDiscussion>(data.discussion)}
        mentorSolution={camelizeKeysAs<CommunitySolution>(data.mentor_solution)}
        exemplarFiles={camelizeKeysAs<readonly MentoringSessionExemplarFile[]>(
          data.exemplar_files
        )}
        student={camelizeKeysAs<MentoringSessionStudent>(data.student)}
        track={camelizeKeysAs<MentorSessionTrack>(data.track)}
        exercise={camelizeKeysAs<MentorSessionExercise>(data.exercise)}
        iterations={camelizeKeysAs<Iteration[]>(data.iterations)}
        instructions={data.instructions}
        testFiles={data.test_files}
        links={camelizeKeysAs<MentoringSessionLinks>(data.links)}
        request={camelizeKeysAs<MentorSessionRequest>(data.request)}
        scratchpad={camelizeKeysAs<MentoringSessionScratchpad>(data.scratchpad)}
        guidance={camelizeKeysAs<
          Pick<Guidance, 'exercise' | 'track' | 'links'>
        >(data.guidance)}
        outOfDate={data.out_of_date}
        downloadCommand={data.download_command}
      />
    </Suspense>
  ),
  'mentoring-representations-with-feedback': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <RepresentationsWithFeedback
        data={camelizeKeysAs<AutomationProps>(data)}
      />
    </Suspense>
  ),
  'mentoring-representations-admin': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <RepresentationsAdmin data={camelizeKeysAs<AutomationProps>(data)} />
    </Suspense>
  ),
  'mentoring-representations-without-feedback': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <RepresentationsWithoutFeedback
        data={camelizeKeysAs<AutomationProps>(data)}
      />
    </Suspense>
  ),
  'mentoring-try-mentoring-button': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <TryMentoringButton
        text={data.text}
        size={data.size}
        links={camelizeKeysAs<TryMentoringButtonLinks>(data.links)}
      />
    </Suspense>
  ),
  'mentoring-testimonials-list': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <TestimonialsList
        request={camelizeKeysAs<Request>(data.request)}
        tracks={camelizeKeysAs<readonly MentoringTestimonialsListTrack[]>(
          data.tracks
        )}
        platforms={camelizeKeysAs<readonly SharePlatform[]>(data.platforms)}
      />
    </Suspense>
  ),
  'mentoring-representation': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <Representation data={camelizeKeysAs<CompleteRepresentationData>(data)} />
    </Suspense>
  ),
  'student-mentoring-session': (data: any) => (
    <Suspense fallback={renderLoader()}>
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
    </Suspense>
  ),
  'student-request-mentoring-button': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <RequestMentoringButton
        request={data.request}
        links={camelizeKeysAs<RequestMentoringButtonLinks>(data.links)}
      />
    </Suspense>
  ),

  'journey-journey-page': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <JourneyPage
        categories={camelizeKeysAs<readonly JourneyPageCategory[]>(
          data.categories
        )}
        defaultCategory={data.default_category}
      />
    </Suspense>
  ),
  'settings-profile-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <ProfileForm
        defaultUser={data.user}
        defaultProfile={data.profile}
        links={data.links}
      />
    </Suspense>
  ),
  'settings-photo-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <PhotoForm
        defaultUser={camelizeKeysAs<User>(data.user)}
        links={data.links}
      />
    </Suspense>
  ),
  'settings-delete-profile-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <DeleteProfileForm links={data.links} />
    </Suspense>
  ),
  'settings-pronouns-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <PronounsForm
        handle={data.handle}
        defaultPronounParts={data.pronoun_parts}
        links={data.links}
      />
    </Suspense>
  ),
  'settings-handle-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <HandleForm defaultHandle={data.handle} links={data.links} />
    </Suspense>
  ),
  'settings-email-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <EmailForm defaultEmail={data.email} links={data.links} />
    </Suspense>
  ),
  'settings-password-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <PasswordForm links={data.links} />
    </Suspense>
  ),
  'settings-token-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <TokenForm defaultToken={data.token} links={data.links} />
    </Suspense>
  ),
  'settings-user-preferences-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <UserPreferencesForm
        defaultPreferences={camelizeKeysAs<UserPreferences>(data.preferences)}
        links={data.links}
      />
    </Suspense>
  ),
  'settings-theme-preference-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <ThemePreferenceForm
        defaultThemePreference={data.default_theme_preference}
        insidersStatus={data.insiders_status}
        links={camelizeKeysAs<ThemePreferenceLinks>(data.links)}
      />
    </Suspense>
  ),
  'settings-comments-preference-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <CommentsPreferenceForm
        {...camelizeKeysAs<CommentsPreferenceFormProps>(data)}
      />
    </Suspense>
  ),
  'settings-communication-preferences-form': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <CommunicationPreferencesForm
        defaultPreferences={camelizeKeysAs<CommunicationPreferences>(
          data.preferences
        )}
        links={data.links}
      />
    </Suspense>
  ),
  'settings-delete-account-button': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <DeleteAccountButton handle={data.handle} links={data.links} />
    </Suspense>
  ),
  'settings-reset-account-button': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <ResetAccountButton handle={data.handle} links={data.links} />
    </Suspense>
  ),
  'settings-show-on-supporters-page-button': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <ShowOnSupportersPageButton
        defaultValue={data.value}
        links={data.links}
      />
    </Suspense>
  ),
  'dropdowns-notifications': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <NotificationsDropdown endpoint={data.endpoint} />
    </Suspense>
  ),
  'dropdowns-reputation': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <ReputationDropdown
        endpoint={data.endpoint}
        defaultIsSeen={data.is_seen}
        defaultReputation={data.reputation}
      />
    </Suspense>
  ),
  'dropdowns-track-menu': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <TrackMenuDropdown
        track={data.track}
        links={camelizeKeysAs<TrackMenuLinks>(data.links)}
      />
    </Suspense>
  ),
  'notifications-notifications-list': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <NotificationsList
        request={camelizeKeysAs<Request>(data.request)}
        links={camelizeKeysAs<NotificationsListLinks>(data.links)}
      />
    </Suspense>
  ),
  'track-iteration-summary': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <IterationSummaryWithWebsockets
        iteration={camelizeKeysAs<Iteration>(data.iteration)}
        className={data.class_name}
        showSubmissionMethod={true}
        showTestsStatusAsButton={!!data.show_tests_status_as_button}
        showFeedbackIndicator={!!data.show_feedback_indicator}
      />
    </Suspense>
  ),
  'student-iterations-list': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <StudentIterationsList
        solutionUuid={data.solution_uuid}
        request={camelizeKeysAs<IterationsListRequest>(data.request)}
        exercise={camelizeKeysAs<IterationsListExercise>(data.exercise)}
        track={camelizeKeysAs<IterationsListTrack>(data.track)}
        links={camelizeKeysAs<IterationsListLinks>(data.links)}
      />
    </Suspense>
  ),
  'student-solution-summary': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <StudentSolutionSummary
        discussions={camelizeKeysAs<MentorDiscussion[]>(data.discussions)}
        solution={camelizeKeysAs<SolutionForStudent>(data.solution)}
        request={camelizeKeysAs<SolutionSummaryRequest>(data.request)}
        links={camelizeKeysAs<SolutionSummaryLinks>(data.links)}
        track={camelizeKeysAs<SolutionSummaryTrack>(data.track)}
        exercise={data.exercise}
      />
    </Suspense>
  ),

  'student-nudge': (data: any) => (
    <Suspense fallback={renderLoader()}>
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
    </Suspense>
  ),

  'student-publish-solution-button': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <PublishSolutionButton
        endpoint={data.endpoint}
        iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
      />
    </Suspense>
  ),
  'student-published-solution': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <PublishedSolution
        solution={camelizeKeysAs<CommunitySolution>(data.solution)}
        publishedIterationIdx={data.published_iteration_idx}
        iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
        links={camelizeKeysAs<PublishedSolutionLinks>(data.links)}
      />
    </Suspense>
  ),
  'student-update-exercise-notice': (data: any) => (
    <Suspense fallback={renderLoader()}>
      <UpdateExerciseNotice links={data.links} />
    </Suspense>
  ),

  // Slow things at the end
  'donations-footer-form': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <DonationsFooterForm {...camelizeKeysAs<FooterFormProps>(data)} />
    </Suspense>
  ),

  'donations-with-modal-form': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <DonationsFormWithModal
        request={camelizeKeysAs<Request>(data.request)}
        links={data.links}
        userSignedIn={data.user_signed_in}
        captchaRequired={data.captcha_required}
        recaptchaSiteKey={data.recaptcha_site_key}
      />
    </Suspense>
  ),
  'donations-subscription-form': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <DonationsSubscriptionForm
        {...data}
        amount={currency(data.amount_in_cents, { fromCents: true })}
      />
    </Suspense>
  ),
})
