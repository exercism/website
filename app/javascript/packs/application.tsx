/* eslint-disable @typescript-eslint/no-explicit-any */
import React, { lazy, Suspense } from 'react'
import { initReact } from '@/utils/react-bootloader'
import { camelizeKeys } from 'humps'
import { camelizeKeysAs, highlightAll } from '@/utils'
import 'focus-visible'
import 'tippy.js/animations/shift-away-subtle.css'
import 'tippy.js/dist/svg-arrow.css'
import 'abortcontroller-polyfill/dist/abortcontroller-polyfill-only'

import type { IConceptMap } from '@/components/concept-map/concept-map-types'
import type {
  Iteration,
  Track,
  Exercise,
  SolutionForStudent,
  CommunitySolution as CommunitySolutionProps,
  Testimonial,
  User,
  SiteUpdate,
  SharePlatform,
  Metric,
} from '@/components/types'
import type { Request as ContributingTasksRequest } from '@/components/contributing/TasksList'
import type { TrackData as ProfileCommunitySolutionsListTrackData } from '@/components/profile/CommunitySolutionsList'
import type { Category as ProfileContributionsListCategory } from '@/components/profile/ContributionsList'
import type { Links as SolutionViewLinks } from '@/components/common/SolutionView'
import type { Links as CommentsListLinks } from '@/components/community-solutions/CommentsList'
import type { Request } from '@/hooks'
import type { AutomationLockedTooltipProps } from '../components/tooltips/AutomationLockedTooltip'
import type { DigDeeperProps } from '@/components/track/DigDeeper'
import type { ChartData } from '@/components/impact/Chart'
import type { InsidersStatusData } from '../components/insiders/InsidersStatus'
import type { ThemeToggleButtonProps } from '@/components/common/ThemeToggleButton'
import type { PerksModalButtonProps } from '@/components/perks/PerksModalButton.js'
import type { PerksExternalModalButtonProps } from '@/components/perks/PerksExternalModalButton.js'
import type { VideoGridProps } from '@/components/community/video-grid/index.js'
import type { PaymentPendingProps } from '@/components/insiders/PaymentPending'

const CLIWalkthrough = lazy(() => import('@/components/common/CLIWalkthrough'))
const CLIWalkthroughButton = lazy(
  () => import('@/components/common/CLIWalkthroughButton')
)

const ImpactStat = lazy(() => import('@/components/impact/stat'))
const ImpactMap = lazy(() => import('@/components/impact/map'))
const ImpactChart = lazy(() => import('@/components/impact/Chart'))
const InsidersStatus = lazy(
  () => import('@/components/insiders/InsidersStatus')
)

import StudentTracksList from '@/components/student/TracksList'
import StudentExerciseList from '@/components/student/ExerciseList'

const ShareLink = lazy(() => import('@/components/common/ShareLink'))
const ConceptWidget = lazy(() => import('@/components/common/ConceptWidget'))
const SolutionView = lazy(() => import('@/components/common/SolutionView'))
const Expander = lazy(() => import('@/components/common/Expander'))
const Introducer = lazy(() => import('@/components/common/Introducer'))
const Modal = lazy(() => import('@/components/common/Modal'))
const CommunitySolution = lazy(
  () => import('@/components/common/CommunitySolution')
)
const Credits = lazy(() => import('@/components/common/Credits'))
const ExerciseWidget = lazy(() => import('@/components/common/ExerciseWidget'))
const ShareButton = lazy(() => import('@/components/common/ShareButton'))
const SiteUpdatesList = lazy(
  () => import('@/components/common/SiteUpdatesList')
)
const CopyToClipboardButton = lazy(
  () => import('@/components/common/CopyToClipboardButton')
)
const ThemeToggleButton = lazy(
  () => import('@/components/common/ThemeToggleButton')
)
const Icon = lazy(() => import('@/components/common/Icon'))
const GraphicalIcon = lazy(() => import('@/components/common/GraphicalIcon'))
const ProgressGraph = lazy(() => import('@/components/common/ProgressGraph'))

const ExerciseStatusChart = lazy(
  () => import('@/components/student/ExerciseStatusChart')
)
const ExerciseStatusDot = lazy(
  () => import('@/components/student/ExerciseStatusDot')
)
const OpenEditorButton = lazy(
  () => import('@/components/student/OpenEditorButton')
)
const CompleteExerciseButton = lazy(
  () => import('@/components/student/CompleteExerciseButton')
)
const VideoGrid = lazy(() => import('@/components/community/video-grid'))
const StoriesGrid = lazy(() => import('@/components/community/stories-grid'))

const ExerciseCommunitySolutionsList = lazy(
  () => import('@/components/track/ExerciseCommunitySolutionsList')
)
const DigDeeper = lazy(() => import('@/components/track/DigDeeper'))
const ConceptMakersButton = lazy(
  () => import('@/components/track/ConceptMakersButton')
)
const UnlockHelpButton = lazy(
  () => import('@/components/track/UnlockHelpButton')
)
const ExerciseMakersButton = lazy(
  () => import('@/components/track/ExerciseMakersButton')
)

const ConceptMap = lazy(() => import('@/components/concept-map/ConceptMap'))

// TODO: Move this out of /types, as this is not a type
import { TrackContribution } from '@/components/types'

const StudentTooltip = lazy(
  () => import('@/components/tooltips/StudentTooltip')
)
const UserTooltip = lazy(() => import('@/components/tooltips/UserTooltip'))
const ExerciseTooltip = lazy(
  () => import('@/components/tooltips/ExerciseTooltip')
)
const ToolingTooltip = lazy(
  () => import('@/components/tooltips/ToolingTooltip')
)
const ConceptTooltip = lazy(
  () => import('@/components/tooltips/ConceptTooltip')
)

const AutomationLockedTooltip = lazy(
  () => import('@/components/tooltips/AutomationLockedTooltip')
)
const Dropdown = lazy(() => import('@/components/dropdowns/Dropdown'))

const TestimonialsSummary = lazy(
  () => import('@/components/profile/TestimonialsSummary')
)
const CommunitySolutionsList = lazy(
  () => import('@/components/profile/CommunitySolutionsList')
)
const TestimonialsList = lazy(
  () => import('@/components/profile/TestimonialsList')
)
const ContributionsList = lazy(
  () => import('@/components/profile/ContributionsList')
)
const ContributionsSummary = lazy(
  () => import('@/components/profile/ContributionsSummary')
)
const AvatarSelector = lazy(() => import('@/components/profile/AvatarSelector'))
const NewProfileForm = lazy(() => import('@/components/profile/NewProfileForm'))
const FirstTimeModal = lazy(
  () => import('@/components/modals/profile/FirstTimeModal')
)

const StarButton = lazy(
  () => import('@/components/community-solutions/StarButton')
)
const CommentsList = lazy(
  () => import('@/components/community-solutions/CommentsList')
)
const ContributorsList = lazy(
  () => import('@/components/contributing/ContributorsList')
)
const TasksList = lazy(() => import('@/components/contributing/TasksList'))

const PaymentPending = lazy(
  () => import('@/components/insiders/PaymentPending')
)
const PerksModalButton = lazy(
  () => import('@/components/perks/PerksModalButton')
)
const PerksExternalModalButton = lazy(
  () => import('@/components/perks/PerksExternalModalButton')
)

export const renderLoader = (): JSX.Element => (
  <div className="c-loading-suspense" />
)

declare global {
  interface Window {
    Turbo: typeof import('@hotwired/turbo/dist/types/core/index')
    queryCache: QueryCache
  }
}

import { QueryCache } from 'react-query'
window.queryCache = new QueryCache()

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
export const mappings = {
  'share-link': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ShareLink
        title={data.title}
        shareTitle={data.share_title}
        shareLink={data.share_link}
        platforms={camelizeKeysAs<readonly SharePlatform[]>(data.platforms)}
      />
    </Suspense>
  ),
  'common-concept-widget': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ConceptWidget concept={data.concept} />
    </Suspense>
  ),

  'common-modal': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <Modal html={data.html} />
    </Suspense>
  ),
  'common-solution-view': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <SolutionView
        iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
        language={data.language}
        indentSize={data.indent_size}
        publishedIterationIdx={data.published_iteration_idx}
        publishedIterationIdxs={data.published_iteration_idxs}
        outOfDate={data.out_of_date}
        links={camelizeKeysAs<SolutionViewLinks>(data.links)}
      />
    </Suspense>
  ),
  'common-expander': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <Expander
        contentIsSafe={data.content_is_safe}
        content={data.content}
        buttonTextCompressed={data.button_text_compressed}
        buttonTextExpanded={data.button_text_expanded}
        className={data.class_name}
      />
    </Suspense>
  ),
  'common-community-solution': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <CommunitySolution
        solution={camelizeKeysAs<CommunitySolutionProps>(data.solution)}
        context={data.context}
      />
    </Suspense>
  ),
  'common-introducer': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <Introducer
        icon={data.icon}
        content={data.content}
        endpoint={data.endpoint}
      />
    </Suspense>
  ),
  'common-cli-walkthrough': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <CLIWalkthrough html={data.html} />
    </Suspense>
  ),
  'common-cli-walkthrough-button': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <CLIWalkthroughButton html={data.html} />
    </Suspense>
  ),

  'community-video-grid': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <VideoGrid {...camelizeKeysAs<VideoGridProps>(data)} />
    </Suspense>
  ),
  'community-stories-grid': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <StoriesGrid data={camelizeKeys(data)} />
    </Suspense>
  ),

  'track-exercise-community-solutions-list': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ExerciseCommunitySolutionsList
        request={camelizeKeysAs<Request>(data.request)}
      />
    </Suspense>
  ),

  'track-dig-deeper': (data: DigDeeperProps): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <DigDeeper data={camelizeKeysAs<DigDeeperProps>(data)} />
    </Suspense>
  ),

  'track-trophies': (data: TrophiesProps) => (
    <Trophies trophies={camelizeKeysAs<Trophy[]>(data.trophies)} />
  ),

  'unlock-help-button': (data: { unlock_url: string }): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <UnlockHelpButton unlockUrl={data.unlock_url} />
    </Suspense>
  ),

  'track-exercise-makers-button': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ExerciseMakersButton
        avatarUrls={camelizeKeysAs<readonly string[]>(data.avatar_urls)}
        numAuthors={data.num_authors}
        numContributors={data.num_contributors}
        links={data.links}
      />
    </Suspense>
  ),
  'track-concept-makers-button': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ConceptMakersButton
        avatarUrls={camelizeKeysAs<readonly string[]>(data.avatar_urls)}
        numAuthors={data.num_authors}
        numContributors={data.num_contributors}
        links={data.links}
      />
    </Suspense>
  ),
  'common-credits': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <Credits
        users={camelizeKeysAs<User[]>(data.users)}
        topCount={data.top_count}
        topLabel={data.top_label}
        bottomCount={data.bottom_count}
        bottomLabel={data.bottom_label}
      />
    </Suspense>
  ),
  'common-exercise-widget': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ExerciseWidget
        exercise={camelizeKeysAs<Exercise>(data.exercise)}
        track={camelizeKeysAs<Track>(data.track)}
        solution={camelizeKeysAs<SolutionForStudent>(data.solution)}
        links={data.links}
        renderAsLink={data.render_as_link}
        renderBlurb={data.render_blurb}
        isSkinny={data.skinny}
      />
    </Suspense>
  ),
  'common-share-button': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ShareButton
        title={data.title}
        shareTitle={data.share_title}
        shareLink={data.share_link}
        platforms={camelizeKeysAs<readonly SharePlatform[]>(data.platforms)}
      />
    </Suspense>
  ),
  'common-site-updates-list': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <SiteUpdatesList
        updates={camelizeKeysAs<readonly SiteUpdate[]>(data.updates)}
        context={data.context}
      />
    </Suspense>
  ),
  'contributing-contributors-list': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ContributorsList
        request={camelizeKeysAs<Request>(data.request)}
        tracks={camelizeKeysAs<readonly Track[]>(data.tracks)}
      />
    </Suspense>
  ),
  'contributing-tasks-list': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <TasksList
        request={camelizeKeysAs<ContributingTasksRequest>(data.request)}
        tracks={camelizeKeysAs<readonly Track[]>(data.tracks)}
      />
    </Suspense>
  ),
  'student-tracks-list': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <StudentTracksList request={data.request} tagOptions={data.tag_options} />
    </Suspense>
  ),
  'student-exercise-list': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <StudentExerciseList
        request={camelizeKeysAs<Request>(data.request)}
        defaultStatus={data.status}
      />
    </Suspense>
  ),
  'student-exercise-status-chart': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ExerciseStatusChart
        exercisesData={data.exercises_data}
        links={data.links}
      />
    </Suspense>
  ),
  'student-exercise-status-dot': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ExerciseStatusDot
        exerciseStatus={data.exercise_status}
        type={data.type}
        links={data.links}
      />
    </Suspense>
  ),
  'student-open-editor-button': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <OpenEditorButton
        editorEnabled={data.editor_enabled}
        status={data.status}
        links={data.links}
        command={data.command}
      />
    </Suspense>
  ),
  'student-complete-exercise-button': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <CompleteExerciseButton
        endpoint={data.endpoint}
        iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
      />
    </Suspense>
  ),
  'concept-map': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ConceptMap {...camelizeKeysAs<IConceptMap>(data.graph)} />
    </Suspense>
  ),

  'mentored-student-tooltip': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <StudentTooltip endpoint={data.endpoint} />
    </Suspense>
  ),
  'user-tooltip': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <UserTooltip endpoint={data.endpoint} />
    </Suspense>
  ),
  'exercise-tooltip': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ExerciseTooltip endpoint={data.endpoint} />
    </Suspense>
  ),

  'tooling-tooltip': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ToolingTooltip endpoint={data.endpoint} />
    </Suspense>
  ),

  'concept-tooltip': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ConceptTooltip endpoint={data.endpoint} />
    </Suspense>
  ),
  'automation-locked-tooltip': (
    data: AutomationLockedTooltipProps
  ): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <AutomationLockedTooltip endpoint={data.endpoint} />
    </Suspense>
  ),
  'dropdowns-dropdown': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <Dropdown menuButton={data.menu_button} menuItems={data.menu_items} />
    </Suspense>
  ),

  'common-copy-to-clipboard-button': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <CopyToClipboardButton textToCopy={data.text_to_copy} />
    </Suspense>
  ),
  'common-theme-toggle-button': (
    data: Omit<ThemeToggleButtonProps, 'defaultTheme'> & {
      default_theme: string
    }
  ): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ThemeToggleButton {...data} defaultTheme={data.default_theme} />
    </Suspense>
  ),
  'common-icon': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <Icon icon={data.icon} alt={data.alt} />
    </Suspense>
  ),
  'common-graphical-icon': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <GraphicalIcon icon={data.icon} />
    </Suspense>
  ),
  'profile-testimonials-summary': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <TestimonialsSummary
        handle={data.handle}
        flair={data.flair}
        numTestimonials={data.num_testimonials}
        numSolutionsMentored={data.num_solutions_mentored}
        numStudentsHelped={data.num_students_helped}
        numTestimonialsReceived={data.num_testimonials_received}
        testimonials={camelizeKeysAs<Testimonial[]>(data.testimonials)}
        links={data.links}
      />
    </Suspense>
  ),
  'profile-community-solutions-list': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <CommunitySolutionsList
        request={camelizeKeysAs<Request>(data.request)}
        tracks={camelizeKeysAs<ProfileCommunitySolutionsListTrackData[]>(
          data.tracks
        )}
      />
    </Suspense>
  ),
  'profile-testimonials-list': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <TestimonialsList
        request={camelizeKeysAs<Request>(data.request)}
        defaultSelected={data.default_selected || null}
      />
    </Suspense>
  ),
  'profile-contributions-list': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ContributionsList
        categories={camelizeKeysAs<readonly ProfileContributionsListCategory[]>(
          data.categories
        )}
      />
    </Suspense>
  ),
  'profile-contributions-summary': (data: any): JSX.Element => {
    const tracks = data.tracks.map(
      (track: any) =>
        new TrackContribution(camelizeKeysAs<TrackContribution>(track))
    )

    return (
      <Suspense fallback={renderLoader()}>
        <ContributionsSummary
          tracks={tracks}
          handle={data.handle}
          links={data.links}
        />
      </Suspense>
    )
  },
  'profile-first-time-modal': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <FirstTimeModal links={data.links} />
    </Suspense>
  ),
  'community-solutions-star-button': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <StarButton
        userSignedIn={data.user_signed_in}
        defaultNumStars={data.num_stars}
        defaultIsStarred={data.is_starred}
        links={data.links}
      />
    </Suspense>
  ),
  'community-solutions-comments-list': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <CommentsList
        isAuthor={data.is_author}
        userSignedIn={data.user_signed_in}
        defaultAllowComments={data.allow_comments}
        request={camelizeKeysAs<Request>(data.request)}
        links={camelizeKeysAs<CommentsListLinks>(data.links)}
      />
    </Suspense>
  ),
  'profile-avatar-selector': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <AvatarSelector
        defaultUser={camelizeKeysAs<User>(data.user)}
        links={data.links}
      />
    </Suspense>
  ),
  'profile-new-profile-form': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <NewProfileForm
        user={camelizeKeysAs<User>(data.user)}
        defaultFields={data.fields}
        links={data.links}
      />
    </Suspense>
  ),
  'common-progress-graph': (data: {
    values: Array<number>
    width: number
    height: number
  }): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ProgressGraph
        data={data.values}
        height={data.height}
        width={data.width}
      />
    </Suspense>
  ),

  'impact-stat': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ImpactStat metricType={data.type} initialValue={data.value} />
    </Suspense>
  ),
  'impact-chart': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <ImpactChart data={camelizeKeysAs<ChartData>(data)} />
    </Suspense>
  ),
  'insiders-status': (data: InsidersStatusData): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <InsidersStatus {...camelizeKeysAs<InsidersStatusData>(data)} />
    </Suspense>
  ),

  'insiders-payment-pending': (data: PaymentPendingProps): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <PaymentPending {...camelizeKeysAs<PaymentPendingProps>(data)} />
    </Suspense>
  ),

  'perks-external-modal-button': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <PerksExternalModalButton
        data={camelizeKeysAs<PerksExternalModalButtonProps>(data)}
      />
    </Suspense>
  ),

  'perks-modal-button': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <PerksModalButton data={camelizeKeysAs<PerksModalButtonProps>(data)} />
    </Suspense>
  ),

  'impact-map': (data: any): JSX.Element => {
    const metrics = data.metrics.map((metric: any) =>
      camelizeKeysAs<Metric>(metric)
    )

    return (
      <Suspense fallback={renderLoader()}>
        <ImpactMap initialMetrics={metrics} trackTitle={data.track_title} />
      </Suspense>
    )
  },
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact(mappings)

import {
  handleNavbarFocus,
  scrollIntoView,
  showSiteFooterOnTurboLoad,
} from '@/utils'
import { TrophiesProps, Trophy } from '@/components/track/Trophies'
import { Trophies } from '@/components/track'

document.addEventListener('turbo:load', () => {
  highlightAll()
})

showSiteFooterOnTurboLoad()
handleNavbarFocus()
scrollIntoView()

// object.entries polyfill
if (!Object.entries) {
  Object.entries = function (obj: any) {
    const ownProps = Object.keys(obj)
    let i = ownProps.length
    const resArray = new Array(i)

    while (i--) resArray[i] = [ownProps[i], obj[ownProps[i]]]

    return resArray
  }
}
