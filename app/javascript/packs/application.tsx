/* eslint-disable @typescript-eslint/no-explicit-any */
import React, { lazy, Suspense } from 'react'
import { camelizeKeys } from 'humps'
import { camelizeKeysAs } from '@/utils/camelize-keys-as'
import { initReact } from '@/utils/react-bootloader'
import { RenderLoader } from '@/components/common/RenderLoader'
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
import type { Request } from '@/hooks/request-query'
import type { AutomationLockedTooltipProps } from '../components/tooltips/AutomationLockedTooltip'
import type { DigDeeperProps } from '@/components/track/DigDeeper'
import type { ChartData } from '@/components/impact/Chart'
import type { InsidersStatusData } from '../components/insiders/InsidersStatus'
import type { ThemeToggleButtonProps } from '@/components/common/ThemeToggleButton'
import type { PerksModalButtonProps } from '@/components/perks/PerksModalButton.js'
import type { PerksExternalModalButtonProps } from '@/components/perks/PerksExternalModalButton.js'
import type { VideoGridProps } from '@/components/community/video-grid/index.js'
import type { PaymentPendingProps } from '@/components/insiders/PaymentPending'
import type { TrophiesProps, Trophy } from '@/components/track/Trophies'
import type { CodeTaggerProps } from '@/components/training-data/code-tagger/CodeTagger.types'
import type { DashboardProps } from '@/components/training-data/dashboard/Dashboard.types'

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

const StudentTracksList = lazy(() => import('@/components/student/TracksList'))
const StudentExerciseList = lazy(
  () => import('@/components/student/ExerciseList')
)

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

const YoutubePlayerWithMutation = lazy(
  () => import('@/components/common/YoutubePlayerWithMutation')
)

const DigDeeper = lazy(() => import('@/components/track/DigDeeper'))
const ActivatePracticeMode = lazy(
  () => import('@/components/track/ActivatePracticeMode')
)
const ConceptMakersButton = lazy(
  () => import('@/components/track/ConceptMakersButton')
)
const UnlockHelpButton = lazy(
  () => import('@/components/track/UnlockHelpButton')
)
const ExerciseMakersButton = lazy(
  () => import('@/components/track/ExerciseMakersButton')
)

const ActivityTicker = lazy(() => import('@/components/track/ActivityTicker'))

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

const ImpactTestimonial = lazy(
  () => import('@/components/impact/ImpactTestimonial')
)

const ProfileTestimonial = lazy(
  () => import('@/components/profile/testimonials-list/ProfileTestimonial')
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

const CodeTagger = lazy(() => import('@/components/training-data/CodeTagger'))

const Dashboard = lazy(() => import('@/components/training-data/Dashboard'))

const PaymentPending = lazy(
  () => import('@/components/insiders/PaymentPending')
)
const PerksModalButton = lazy(
  () => import('@/components/perks/PerksModalButton')
)
const PerksExternalModalButton = lazy(
  () => import('@/components/perks/PerksExternalModalButton')
)

const Trophies = lazy(() => import('@/components/track/Trophies'))

import { QueryClient } from '@tanstack/react-query'
declare global {
  interface Window {
    Turbo: typeof import('@hotwired/turbo/dist/types/core/index')
    queryClient: QueryClient
  }
}
// use query client by pulling it out of the provider with useQueryClient hook
// const queryClient = useQueryClient()
window.queryClient = new QueryClient()

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
export const mappings = {
  'share-link': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ShareLink
        title={data.title}
        shareTitle={data.share_title}
        shareLink={data.share_link}
        platforms={camelizeKeysAs<readonly SharePlatform[]>(data.platforms)}
      />
    </Suspense>
  ),
  'common-concept-widget': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ConceptWidget concept={data.concept} />
    </Suspense>
  ),

  'common-youtube-player': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <YoutubePlayerWithMutation
        id={data.id}
        markAsSeenEndpoint={data.mark_as_seen_endpoint}
      />
    </Suspense>
  ),

  'common-modal': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <Modal html={data.html} />
    </Suspense>
  ),
  'common-solution-view': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
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
    <Suspense fallback={RenderLoader()}>
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
    <Suspense fallback={RenderLoader()}>
      <CommunitySolution
        solution={camelizeKeysAs<CommunitySolutionProps>(data.solution)}
        context={data.context}
      />
    </Suspense>
  ),
  'common-introducer': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <Introducer
        icon={data.icon}
        content={data.content}
        endpoint={data.endpoint}
      />
    </Suspense>
  ),
  'common-cli-walkthrough': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <CLIWalkthrough html={data.html} />
    </Suspense>
  ),
  'common-cli-walkthrough-button': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <CLIWalkthroughButton html={data.html} />
    </Suspense>
  ),

  'community-video-grid': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <VideoGrid {...camelizeKeysAs<VideoGridProps>(data)} />
    </Suspense>
  ),
  'community-stories-grid': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <StoriesGrid data={camelizeKeys(data)} />
    </Suspense>
  ),

  'track-exercise-community-solutions-list': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ExerciseCommunitySolutionsList
        request={camelizeKeysAs<Request>(data.request)}
        tags={data.tags}
      />
    </Suspense>
  ),

  'track-activate-practice-mode': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ActivatePracticeMode
        endpoint={data.endpoint}
        redirectToUrl={data.redirect_to_url}
        buttonLabel={data.button_label}
      />
    </Suspense>
  ),

  'track-dig-deeper': (data: DigDeeperProps): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <DigDeeper data={camelizeKeysAs<DigDeeperProps>(data)} />
    </Suspense>
  ),

  'track-trophies': (data: TrophiesProps): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <Trophies trophies={camelizeKeysAs<Trophy[]>(data.trophies)} />
    </Suspense>
  ),

  'unlock-help-button': (data: { unlock_url: string }): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <UnlockHelpButton unlockUrl={data.unlock_url} />
    </Suspense>
  ),

  'track-exercise-makers-button': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ExerciseMakersButton
        avatarUrls={camelizeKeysAs<readonly string[]>(data.avatar_urls)}
        numAuthors={data.num_authors}
        numContributors={data.num_contributors}
        links={data.links}
      />
    </Suspense>
  ),
  'track-concept-makers-button': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ConceptMakersButton
        avatarUrls={camelizeKeysAs<readonly string[]>(data.avatar_urls)}
        numAuthors={data.num_authors}
        numContributors={data.num_contributors}
        links={data.links}
      />
    </Suspense>
  ),

  'track-build-analyzer-tags': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <AnalyzerTags {...camelizeKeysAs<AnalyzerTagsType>(data)} />
    </Suspense>
  ),

  'track-activity-ticker': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ActivityTicker {...camelizeKeysAs<ActivityTickerProps>(data)} />
    </Suspense>
  ),

  'common-credits': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
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
    <Suspense fallback={RenderLoader()}>
      <ExerciseWidget
        exercise={camelizeKeysAs<Exercise>(data.exercise)}
        track={camelizeKeysAs<Track>(data.track)}
        solution={camelizeKeysAs<SolutionForStudent>(data.solution)}
        links={data.links}
        renderBlurb={data.render_blurb}
        isSkinny={data.skinny}
      />
    </Suspense>
  ),
  'common-share-button': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ShareButton
        title={data.title}
        shareTitle={data.share_title}
        shareLink={data.share_link}
        platforms={camelizeKeysAs<readonly SharePlatform[]>(data.platforms)}
      />
    </Suspense>
  ),
  'common-site-updates-list': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <SiteUpdatesList
        updates={camelizeKeysAs<readonly SiteUpdate[]>(data.updates)}
        context={data.context}
      />
    </Suspense>
  ),
  'contributing-contributors-list': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ContributorsList
        request={camelizeKeysAs<Request>(data.request)}
        tracks={camelizeKeysAs<readonly Track[]>(data.tracks)}
      />
    </Suspense>
  ),
  'contributing-tasks-list': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <TasksList
        request={camelizeKeysAs<ContributingTasksRequest>(data.request)}
        tracks={camelizeKeysAs<readonly Track[]>(data.tracks)}
      />
    </Suspense>
  ),

  'training-data-dashboard': (data: any) => (
    <Suspense fallback={RenderLoader()}>
      <Dashboard {...camelizeKeysAs<DashboardProps>(data)} />
    </Suspense>
  ),
  'training-data-code-tagger': (data: any) => (
    <Suspense fallback={RenderLoader()}>
      <CodeTagger {...camelizeKeysAs<CodeTaggerProps>(data)} />
    </Suspense>
  ),
  'student-tracks-list': (data: any): JSX.Element => (
    <Suspense fallback={<TracksListSkeleton />}>
      <StudentTracksList
        request={camelizeKeysAs<Request>(data.request)}
        tagOptions={data.tag_options}
      />
    </Suspense>
  ),
  'student-exercise-list': (data: any): JSX.Element => (
    <Suspense fallback={<ExerciseListSkeleton />}>
      <StudentExerciseList
        request={camelizeKeysAs<Request>(data.request)}
        defaultStatus={data.status}
      />
    </Suspense>
  ),
  'student-exercise-status-chart': (data: any): JSX.Element => (
    <Suspense fallback={<ExerciseStatusChartSkeleton />}>
      <ExerciseStatusChart
        exercisesData={data.exercises_data}
        links={data.links}
      />
    </Suspense>
  ),
  'student-exercise-status-dot': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ExerciseStatusDot
        exerciseStatus={data.exercise_status}
        type={data.type}
        links={data.links}
      />
    </Suspense>
  ),
  'student-open-editor-button': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <OpenEditorButton
        editorEnabled={data.editor_enabled}
        status={data.status}
        links={data.links}
        command={data.command}
      />
    </Suspense>
  ),
  'student-complete-exercise-button': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <CompleteExerciseButton
        endpoint={data.endpoint}
        iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
      />
    </Suspense>
  ),
  'concept-map': (data: any): JSX.Element => (
    <Suspense fallback={<ConceptMapSkeleton />}>
      <ConceptMap {...camelizeKeysAs<IConceptMap>(data.graph)} />
    </Suspense>
  ),

  'mentored-student-tooltip': (data: any): JSX.Element => (
    <Suspense
      fallback={
        <TooltipBase width={350}>
          <StudentTooltipSkeleton />
        </TooltipBase>
      }
    >
      <StudentTooltip endpoint={data.endpoint} />
    </Suspense>
  ),
  'user-tooltip': (data: any): JSX.Element => (
    <Suspense
      fallback={
        <TooltipBase width={460}>
          <UserTooltipSkeleton />
        </TooltipBase>
      }
    >
      <UserTooltip endpoint={data.endpoint} />
    </Suspense>
  ),
  'exercise-tooltip': (data: any): JSX.Element => (
    <Suspense
      fallback={
        <TooltipBase width={400}>
          <ExerciseTooltipSkeleton />
        </TooltipBase>
      }
    >
      <ExerciseTooltip endpoint={data.endpoint} />
    </Suspense>
  ),

  'tooling-tooltip': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ToolingTooltip endpoint={data.endpoint} />
    </Suspense>
  ),

  'concept-tooltip': (data: any): JSX.Element => (
    <Suspense
      fallback={
        <TooltipBase width={460}>
          <ConceptTooltipSkeleton />
        </TooltipBase>
      }
    >
      <ConceptTooltip endpoint={data.endpoint} />
    </Suspense>
  ),
  'automation-locked-tooltip': (
    data: AutomationLockedTooltipProps
  ): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <AutomationLockedTooltip endpoint={data.endpoint} />
    </Suspense>
  ),
  'dropdowns-dropdown': (data: any): JSX.Element => (
    <Suspense fallback={<UserMenuDropdownSkeleton />}>
      <Dropdown menuButton={data.menu_button} menuItems={data.menu_items} />
    </Suspense>
  ),

  'common-copy-to-clipboard-button': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <CopyToClipboardButton textToCopy={data.text_to_copy} />
    </Suspense>
  ),
  'common-theme-toggle-button': (
    data: Omit<ThemeToggleButtonProps, 'defaultTheme'> & {
      default_theme: string
    }
  ): JSX.Element => (
    <Suspense fallback={<ThemeToggleButtonSkeleton />}>
      <ThemeToggleButton {...data} defaultTheme={data.default_theme} />
    </Suspense>
  ),
  'common-icon': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <Icon icon={data.icon} alt={data.alt} />
    </Suspense>
  ),
  'common-graphical-icon': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <GraphicalIcon icon={data.icon} />
    </Suspense>
  ),
  'profile-testimonials-summary': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
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
    <Suspense fallback={RenderLoader()}>
      <CommunitySolutionsList
        request={camelizeKeysAs<Request>(data.request)}
        tracks={camelizeKeysAs<ProfileCommunitySolutionsListTrackData[]>(
          data.tracks
        )}
      />
    </Suspense>
  ),
  'impact-testimonials-list': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <TestimonialsList
        request={camelizeKeysAs<Request>(data.request)}
        defaultSelected={data.default_selected || null}
      >
        <ImpactTestimonial
          testimonial={{} as Testimonial}
          onClick={() => {}}
          onClose={() => {}}
          open={false}
        />
      </TestimonialsList>
    </Suspense>
  ),
  'profile-testimonials-list': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <TestimonialsList
        request={camelizeKeysAs<Request>(data.request)}
        defaultSelected={data.default_selected || null}
      >
        <ProfileTestimonial
          testimonial={{} as Testimonial}
          onClick={() => {}}
          onClose={() => {}}
          open={false}
        />
      </TestimonialsList>
    </Suspense>
  ),
  'profile-contributions-list': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
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
      <Suspense fallback={RenderLoader()}>
        <ContributionsSummary
          tracks={tracks}
          handle={data.handle}
          links={data.links}
        />
      </Suspense>
    )
  },
  'profile-first-time-modal': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <FirstTimeModal links={data.links} />
    </Suspense>
  ),
  'community-solutions-star-button': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <StarButton
        userSignedIn={data.user_signed_in}
        defaultNumStars={data.num_stars}
        defaultIsStarred={data.is_starred}
        links={data.links}
      />
    </Suspense>
  ),
  'community-solutions-comments-list': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
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
    <Suspense fallback={RenderLoader()}>
      <AvatarSelector
        defaultUser={camelizeKeysAs<User>(data.user)}
        links={data.links}
      />
    </Suspense>
  ),
  'profile-new-profile-form': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
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
    <Suspense fallback={RenderLoader()}>
      <ProgressGraph
        data={data.values}
        height={data.height}
        width={data.width}
      />
    </Suspense>
  ),

  'impact-stat': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ImpactStat metricType={data.type} initialValue={data.value} />
    </Suspense>
  ),
  'impact-chart': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <ImpactChart data={camelizeKeysAs<ChartData>(data)} />
    </Suspense>
  ),
  'insiders-status': (data: InsidersStatusData): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <InsidersStatus {...camelizeKeysAs<InsidersStatusData>(data)} />
    </Suspense>
  ),

  'insiders-payment-pending': (data: PaymentPendingProps): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <PaymentPending {...camelizeKeysAs<PaymentPendingProps>(data)} />
    </Suspense>
  ),

  'perks-external-modal-button': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <PerksExternalModalButton
        data={camelizeKeysAs<PerksExternalModalButtonProps>(data)}
      />
    </Suspense>
  ),

  'perks-modal-button': (data: any): JSX.Element => (
    <Suspense fallback={RenderLoader()}>
      <PerksModalButton data={camelizeKeysAs<PerksModalButtonProps>(data)} />
    </Suspense>
  ),

  'impact-map': (data: any): JSX.Element => {
    const metrics = data.metrics.map((metric: any) =>
      camelizeKeysAs<Metric>(metric)
    )

    return (
      <Suspense fallback={RenderLoader()}>
        <ImpactMap initialMetrics={metrics} trackTitle={data.track_title} />
      </Suspense>
    )
  },
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact(mappings)

import { handleNavbarFocus, scrollIntoView, showSiteFooter } from '@/utils'
import { lazyHighlightAll } from '@/utils/lazy-highlight-all'
import { addAnchorsToDocsHeaders } from '@/utils/anchor-docs-headers'
import { AnalyzerTags } from '@/components/track/build/AnalyzerTags'
import { AnalyzerTagsType } from '@/components/track/build/analyzer-tags/AnalyzerTags.types'
import { ActivityTickerProps } from '@/components/track/activity-ticker/ActivityTicker.types'

import { UserTooltipSkeleton } from '@/components/common/skeleton/skeletons/UserTooltipSkeleton'
import { TooltipBase } from '@/components/tooltips/TooltipBase'
import { ExerciseTooltipSkeleton } from '@/components/common/skeleton/skeletons/ExerciseTooltipSkeleton'
import { ConceptTooltipSkeleton } from '@/components/common/skeleton/skeletons/ConceptTooltipSkeleton'
import { StudentTooltipSkeleton } from '@/components/common/skeleton/skeletons/StudentTooltipSkeleton'
import { ConceptMapSkeleton } from '@/components/common/skeleton/skeletons/ConceptMapSkeleton'
import { ExerciseListSkeleton } from '@/components/common/skeleton/skeletons/ExerciseListSkeleton'
import { ExerciseStatusChartSkeleton } from '@/components/common/skeleton/skeletons/ExerciseStatusChartSkeleton'
import { TracksListSkeleton } from '@/components/common/skeleton/skeletons/TracksListSkeleton'
import { ThemeToggleButtonSkeleton } from '@/components/common/skeleton/skeletons/ThemeToggleButtonSkeleton'
import { UserMenuDropdownSkeleton } from '@/components/common/skeleton/skeletons/UserMenuDropdownSkeleton'
import { initializeFullscreenChangeListeners } from '@/utils/handle-accessibility-fullscreen'

document.addEventListener('turbo:load', () => {
  showSiteFooter()
  handleNavbarFocus()
  scrollIntoView()
  addAnchorsToDocsHeaders()
  initializeFullscreenChangeListeners()
  document.querySelector('meta[name="turbo-visit-control"]')?.remove()

  // Do this last
  lazyHighlightAll()
})

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

//
// Leave this code here so that we can easily add components to test during development.
//

// import { ExtendLockedUntilModal } from '../components/mentoring/request/locked-solution-mentoring-note/ExtendLockedUntilModal'
// const elem = <ExtendLockedUntilModal open={true} />

// import ReactDOM from 'react-dom'
// ReactDOM.render(elem, document.body)
