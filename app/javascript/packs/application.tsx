/* eslint-disable @typescript-eslint/no-explicit-any */
import 'focus-visible'
import 'tippy.js/animations/shift-away-subtle.css'
import 'tippy.js/dist/svg-arrow.css'
import 'abortcontroller-polyfill/dist/abortcontroller-polyfill-only'

import React, { lazy, Suspense } from 'react'
import { initReact } from '../utils/react-bootloader.jsx'

const DonationsFormWithModal = lazy(
  () => import('../components/donations/FormWithModal')
)

const DonationsSubscriptionForm = lazy(
  () => import('../components/donations/SubscriptionForm')
)

const PremiumSubscriptionForm = lazy(
  () => import('../components/donations/PremiumSubscriptionForm')
)
const Editor = lazy(() => import('../components/Editor'))
import { Props as EditorProps } from '../components/editor/Props'

const DonationsFooterForm = lazy(
  () => import('../components/donations/FooterForm')
)

const CLIWalkthrough = lazy(() => import('../components/common/CLIWalkthrough'))
const CLIWalkthroughButton = lazy(
  () => import('../components/common/CLIWalkthroughButton')
)

const ImpactStat = lazy(() => import('../components/impact/stat'))
const ImpactMap = lazy(() => import('../components/impact/map'))
const ImpactChart = lazy(() => import('../components/impact/Chart'))
const InsidersStatus = lazy(
  () => import('../components/insiders/InsidersStatus')
)

import StudentTracksList from '../components/student/TracksList'
import StudentExerciseList from '../components/student/ExerciseList'

import * as Common from '../components/common'

import * as Student from '../components/student'
import * as Community from '../components/community'

import * as TrackComponents from '../components/track'
import { ConceptMap } from '../components/concept-map/ConceptMap'
import { IConceptMap } from '../components/concept-map/concept-map-types'
import {
  Iteration,
  Track,
  Exercise,
  SolutionForStudent,
  CommunitySolution,
  Testimonial,
  User,
  SiteUpdate,
  TrackContribution,
  SharePlatform,
  Metric,
} from '../components/types'

import * as Tooltips from '../components/tooltips'
import { Dropdown } from '../components/dropdowns/Dropdown'
import * as Profile from '../components/profile'
import * as CommunitySolutions from '../components/community-solutions'
import * as Contributing from '../components/contributing'
import { Request as ContributingTasksRequest } from '../components/contributing/TasksList'
import { TrackData as ProfileCommunitySolutionsListTrackData } from '../components/profile/CommunitySolutionsList'
import { Category as ProfileContributionsListCategory } from '../components/profile/ContributionsList'
import { Links as SolutionViewLinks } from '../components/common/SolutionView'
import { Links as CommentsListLinks } from '../components/community-solutions/CommentsList'

import { Request } from '../hooks/request-query'
import { camelizeKeys } from 'humps'
export function camelizeKeysAs<T>(object: any): T {
  return camelizeKeys(object) as unknown as T
}
import currency from 'currency.js'

const renderLoader = () => <div className="c-loading-suspense" />

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
    <Common.ShareLink
      title={data.title}
      shareTitle={data.share_title}
      shareLink={data.share_link}
      platforms={camelizeKeysAs<readonly SharePlatform[]>(data.platforms)}
    />
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
  'premium-subscription-form': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <PremiumSubscriptionForm
        {...camelizeKeysAs<PremiumSubscriptionProps>(data)}
        amount={currency(data.amount_in_cents, { fromCents: true })}
      />
    </Suspense>
  ),
  editor: (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <Editor {...camelizeKeysAs<EditorProps>(data)} />
    </Suspense>
  ),
  'common-concept-widget': (data: any): JSX.Element => (
    <Common.ConceptWidget concept={data.concept} />
  ),
  'common-modal': (data: any): JSX.Element => <Common.Modal html={data.html} />,
  'common-solution-view': (data: any): JSX.Element => (
    <Common.SolutionView
      iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
      language={data.language}
      indentSize={data.indent_size}
      publishedIterationIdx={data.published_iteration_idx}
      publishedIterationIdxs={data.published_iteration_idxs}
      outOfDate={data.out_of_date}
      links={camelizeKeysAs<SolutionViewLinks>(data.links)}
    />
  ),
  'common-expander': (data: any): JSX.Element => (
    <Common.Expander
      contentIsSafe={data.content_is_safe}
      content={data.content}
      buttonTextCompressed={data.button_text_compressed}
      buttonTextExpanded={data.button_text_expanded}
      className={data.class_name}
    />
  ),
  'common-community-solution': (data: any): JSX.Element => (
    <Common.CommunitySolution
      solution={camelizeKeysAs<CommunitySolution>(data.solution)}
      context={data.context}
    />
  ),
  'common-introducer': (data: any): JSX.Element => (
    <Common.Introducer
      icon={data.icon}
      content={data.content}
      endpoint={data.endpoint}
    />
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
    <Community.VideoGrid {...camelizeKeysAs<VideoGridProps>(data)} />
  ),
  'community-stories-grid': (data: any): JSX.Element => (
    <Community.StoriesGrid data={camelizeKeys(data)} />
  ),

  'track-exercise-community-solutions-list': (data: any): JSX.Element => (
    <TrackComponents.ExerciseCommunitySolutionsList
      request={camelizeKeysAs<Request>(data.request)}
    />
  ),

  'track-dig-deeper': (data: DigDeeperProps): JSX.Element => (
    <TrackComponents.DigDeeper data={camelizeKeysAs<DigDeeperProps>(data)} />
  ),

  'unlock-help-button': (data: { unlock_url: string }): JSX.Element => (
    <TrackComponents.UnlockHelpButton unlockUrl={data.unlock_url} />
  ),

  'track-exercise-makers-button': (data: any): JSX.Element => (
    <TrackComponents.ExerciseMakersButton
      avatarUrls={camelizeKeysAs<readonly string[]>(data.avatar_urls)}
      numAuthors={data.num_authors}
      numContributors={data.num_contributors}
      links={data.links}
    />
  ),
  'track-concept-makers-button': (data: any): JSX.Element => (
    <TrackComponents.ConceptMakersButton
      avatarUrls={camelizeKeysAs<readonly string[]>(data.avatar_urls)}
      numAuthors={data.num_authors}
      numContributors={data.num_contributors}
      links={data.links}
    />
  ),
  'common-credits': (data: any): JSX.Element => (
    <Common.Credits
      users={camelizeKeysAs<User[]>(data.users)}
      topCount={data.top_count}
      topLabel={data.top_label}
      bottomCount={data.bottom_count}
      bottomLabel={data.bottom_label}
    />
  ),
  'common-exercise-widget': (data: any): JSX.Element => (
    <Common.ExerciseWidget
      exercise={camelizeKeysAs<Exercise>(data.exercise)}
      track={camelizeKeysAs<Track>(data.track)}
      solution={camelizeKeysAs<SolutionForStudent>(data.solution)}
      links={data.links}
      renderAsLink={data.render_as_link}
      renderBlurb={data.render_blurb}
      isSkinny={data.skinny}
    />
  ),
  'common-share-button': (data: any): JSX.Element => (
    <Common.ShareButton
      title={data.title}
      shareTitle={data.share_title}
      shareLink={data.share_link}
      platforms={camelizeKeysAs<readonly SharePlatform[]>(data.platforms)}
    />
  ),
  'common-site-updates-list': (data: any): JSX.Element => (
    <Common.SiteUpdatesList
      updates={camelizeKeysAs<readonly SiteUpdate[]>(data.updates)}
      context={data.context}
    />
  ),
  'contributing-contributors-list': (data: any): JSX.Element => (
    <Contributing.ContributorsList
      request={camelizeKeysAs<Request>(data.request)}
      tracks={camelizeKeysAs<readonly Track[]>(data.tracks)}
    />
  ),
  'contributing-tasks-list': (data: any): JSX.Element => (
    <Contributing.TasksList
      request={camelizeKeysAs<ContributingTasksRequest>(data.request)}
      tracks={camelizeKeysAs<readonly Track[]>(data.tracks)}
    />
  ),
  'student-tracks-list': (data: any): JSX.Element => (
    <StudentTracksList request={data.request} tagOptions={data.tag_options} />
  ),
  'student-exercise-list': (data: any): JSX.Element => (
    <StudentExerciseList
      request={camelizeKeysAs<Request>(data.request)}
      defaultStatus={data.status}
    />
  ),
  'student-exercise-status-chart': (data: any): JSX.Element => (
    <Student.ExerciseStatusChart
      exercisesData={data.exercises_data}
      links={data.links}
    />
  ),
  'student-exercise-status-dot': (data: any): JSX.Element => (
    <Student.ExerciseStatusDot
      exerciseStatus={data.exercise_status}
      type={data.type}
      links={data.links}
    />
  ),
  'student-open-editor-button': (data: any): JSX.Element => (
    <Student.OpenEditorButton
      editorEnabled={data.editor_enabled}
      status={data.status}
      links={data.links}
      command={data.command}
    />
  ),
  'student-complete-exercise-button': (data: any): JSX.Element => (
    <Student.CompleteExerciseButton
      endpoint={data.endpoint}
      iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
    />
  ),
  'concept-map': (data: any): JSX.Element => (
    <ConceptMap {...camelizeKeysAs<IConceptMap>(data.graph)} />
  ),

  'mentored-student-tooltip': (data: any): JSX.Element => (
    <Tooltips.StudentTooltip endpoint={data.endpoint} />
  ),
  'user-tooltip': (data: any): JSX.Element => (
    <Tooltips.UserTooltip endpoint={data.endpoint} />
  ),
  'exercise-tooltip': (data: any): JSX.Element => (
    <Tooltips.ExerciseTooltip endpoint={data.endpoint} />
  ),

  'tooling-tooltip': (data: any): JSX.Element => (
    <Tooltips.ToolingTooltip endpoint={data.endpoint} />
  ),

  'concept-tooltip': (data: any): JSX.Element => (
    <Tooltips.ConceptTooltip endpoint={data.endpoint} />
  ),
  'automation-locked-tooltip': (
    data: AutomationLockedTooltipProps
  ): JSX.Element => (
    <Tooltips.AutomationLockedTooltip endpoint={data.endpoint} />
  ),
  'dropdowns-dropdown': (data: any): JSX.Element => (
    <Dropdown menuButton={data.menu_button} menuItems={data.menu_items} />
  ),

  'common-copy-to-clipboard-button': (data: any): JSX.Element => (
    <Common.CopyToClipboardButton textToCopy={data.text_to_copy} />
  ),
  'common-theme-toggle-button': (
    data: Omit<ThemeToggleButtonProps, 'defaultTheme'> & {
      default_theme: string
    }
  ): JSX.Element => (
    <Common.ThemeToggleButton {...data} defaultTheme={data.default_theme} />
  ),
  'common-icon': (data: any): JSX.Element => (
    <Common.Icon icon={data.icon} alt={data.alt} />
  ),
  'common-graphical-icon': (data: any): JSX.Element => (
    <Common.GraphicalIcon icon={data.icon} />
  ),
  'profile-testimonials-summary': (data: any): JSX.Element => (
    <Profile.TestimonialsSummary
      handle={data.handle}
      flair={data.flair}
      numTestimonials={data.num_testimonials}
      numSolutionsMentored={data.num_solutions_mentored}
      numStudentsHelped={data.num_students_helped}
      numTestimonialsReceived={data.num_testimonials_received}
      testimonials={camelizeKeysAs<Testimonial[]>(data.testimonials)}
      links={data.links}
    />
  ),
  'profile-community-solutions-list': (data: any): JSX.Element => (
    <Profile.CommunitySolutionsList
      request={camelizeKeysAs<Request>(data.request)}
      tracks={camelizeKeysAs<ProfileCommunitySolutionsListTrackData[]>(
        data.tracks
      )}
    />
  ),
  'profile-testimonials-list': (data: any): JSX.Element => (
    <Profile.TestimonialsList
      request={camelizeKeysAs<Request>(data.request)}
      defaultSelected={data.default_selected || null}
    />
  ),
  'profile-contributions-list': (data: any): JSX.Element => (
    <Profile.ContributionsList
      categories={camelizeKeysAs<readonly ProfileContributionsListCategory[]>(
        data.categories
      )}
    />
  ),
  'profile-contributions-summary': (data: any): JSX.Element => {
    const tracks = data.tracks.map(
      (track: any) =>
        new TrackContribution(camelizeKeysAs<TrackContribution>(track))
    )

    return (
      <Profile.ContributionsSummary
        tracks={tracks}
        handle={data.handle}
        links={data.links}
      />
    )
  },
  'profile-first-time-modal': (data: any): JSX.Element => (
    <Profile.FirstTimeModal links={data.links} />
  ),
  'community-solutions-star-button': (data: any): JSX.Element => (
    <CommunitySolutions.StarButton
      userSignedIn={data.user_signed_in}
      defaultNumStars={data.num_stars}
      defaultIsStarred={data.is_starred}
      links={data.links}
    />
  ),
  'community-solutions-comments-list': (data: any): JSX.Element => (
    <CommunitySolutions.CommentsList
      isAuthor={data.is_author}
      userSignedIn={data.user_signed_in}
      defaultAllowComments={data.allow_comments}
      request={camelizeKeysAs<Request>(data.request)}
      links={camelizeKeysAs<CommentsListLinks>(data.links)}
    />
  ),
  'profile-avatar-selector': (data: any): JSX.Element => (
    <Profile.AvatarSelector
      defaultUser={camelizeKeysAs<User>(data.user)}
      links={data.links}
    />
  ),
  'profile-new-profile-form': (data: any): JSX.Element => (
    <Profile.NewProfileForm
      user={camelizeKeysAs<User>(data.user)}
      defaultFields={data.fields}
      links={data.links}
    />
  ),
  'common-progress-graph': (data: {
    values: Array<number>
    width: number
    height: number
  }): JSX.Element => (
    <Common.ProgressGraph
      data={data.values}
      height={data.height}
      width={data.width}
    />
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
  'premium-price-option': (data: PriceOptionProps): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <PriceOption data={camelizeKeysAs<PriceOptionProps>(data)} />
    </Suspense>
  ),
  'premium-paypal-status': (data: PaypalStatusProps): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <PaypalStatus {...camelizeKeysAs<PaypalStatusProps>(data)} />
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
  // Slow things at the end
  'donations-footer-form': (data: any): JSX.Element => (
    <Suspense fallback={renderLoader()}>
      <DonationsFooterForm {...camelizeKeysAs<FooterFormProps>(data)} />
    </Suspense>
  ),
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact(mappings)

import { highlightAll } from '../utils/highlight'
import type { AutomationLockedTooltipProps } from '../components/tooltips/AutomationLockedTooltip'
import type { DigDeeperProps } from '@/components/track/DigDeeper'
import type { ChartData } from '@/components/impact/Chart'
import { InsidersStatusData } from '../components/insiders/InsidersStatus'
import {
  handleNavbarFocus,
  scrollIntoView,
  showSiteFooterOnTurboLoad,
} from '@/utils'
import { ThemeToggleButtonProps } from '@/components/common/ThemeToggleButton'
import { PriceOption, PriceOptionProps } from '@/components/premium/PriceOption'
import { PremiumSubscriptionProps } from '../components/donations/PremiumSubscriptionForm'
import {
  PaypalStatus,
  PaypalStatusProps,
} from '@/components/premium/PaypalStatus'
import { PerksModalButton, PerksExternalModalButton } from '@/components/perks'
import { FooterFormProps } from '../components/donations/FooterForm'
import { PerksModalButtonProps } from '@/components/perks/PerksModalButton.js'
import { PerksExternalModalButtonProps } from '@/components/perks/PerksExternalModalButton.js'
import { VideoGridProps } from '@/components/community/video-grid/index.js'

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
