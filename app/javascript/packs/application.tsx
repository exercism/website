// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// eslint-disable-next-line @typescript-eslint/no-var-requires
require('@rails/ujs').start()
// eslint-disable-next-line @typescript-eslint/no-var-requires
require('turbolinks').start()
// eslint-disable-next-line @typescript-eslint/no-var-requires
require('@rails/activestorage').start()

import 'tailwindcss/base'
import 'tailwindcss/components'
import 'tailwindcss/utilities'
import 'focus-visible'

import '../../css/application'
import '../../css/layout'
import '../../css/defaults'

import '../../css/ui-kit/buttons'
import '../../css/ui-kit/tracks'

import '../../css/components/contributions-summary'
import '../../css/components/progress'
import '../../css/components/site-update'
import '../../css/components/community-rank-tag'
import '../../css/components/track-breadcrumbs'
import '../../css/components/contributing/header'
import '../../css/components/header-with-bg'
import '../../css/components/makers-button'
import '../../css/components/avatar-selector'
import '../../css/components/badge'
import '../../css/components/bg-img'
import '../../css/components/code-pane'
import '../../css/components/concept'
import '../../css/components/concept-icon'
import '../../css/components/concept-progress-bar'
import '../../css/components/copy-text-to-clipboard'
import '../../css/components/details'
import '../../css/components/combo-button'
import '../../css/components/exercise-header'
import '../../css/components/flash'
import '../../css/components/icon'
import '../../css/components/iteration-summary'
import '../../css/components/accordion-section'
import '../../css/components/underline'
import '../../css/components/docs-main-nav'
import '../../css/components/docs-side-nav'
import '../../css/components/docs-tracks-list'
import '../../css/components/iterations-footer'
import '../../css/components/solution-iterations'

import '../../css/components/share-panel'
import '../../css/components/split-pane'
import '../../css/components/heading-with-count'
import '../../css/components/notification'
import '../../css/components/prominent-link'
import '../../css/components/reputation'
import '../../css/components/primary-reputation'
import '../../css/components/site-header'
import '../../css/components/tab'
import '../../css/components/tab-2'
import '../../css/components/textual-content'
import '../../css/components/tracks-list'
import '../../css/components/pagination'
import '../../css/components/modal'
import '../../css/components/radio'
import '../../css/components/checkbox'
import '../../css/components/select'
import '../../css/components/single-select'
import '../../css/components/multiple-select'
import '../../css/components/track-select'
import '../../css/tooltips/generic'
import '../../css/tooltips/base'
import '../../css/tooltips/concept'
import '../../css/tooltips/user'
import '../../css/tooltips/exercise'
import '../../css/tooltips/student'
import '../../css/components/user_activity'
import '../../css/components/search-bar'
import '../../css/components/community-solution'
import '../../css/components/iteration-processing-status'
import '../../css/components/notification-dot'

import '../../css/components/mentor/header'
import '../../css/components/mentor/solution-row'
import '../../css/components/mentor/discussion'

import '../../css/components/track/header'
import '../../css/components/track/concept-nav'
import '../../css/components/track/concept-map'
import '../../css/components/iteration-pane'
import '../../css/components/explainer'
import '../../css/components/markdown-editor'
import '../../css/components/mentor-discussion-summary'
import '../../css/components/mentor-track-selector'
import '../../css/components/tag'
import '../../css/components/difficulty-tag'
import '../../css/components/exercise-status-tag'
import '../../css/components/exercise-type-tag'
import '../../css/components/divider'
import '../../css/components/faces'
import '../../css/components/exercise-dot'
import '../../css/components/results-zone'
import '../../css/components/introducer'
import '../../css/components/profile-header'
import '../../css/components/track-filter'
import '../../css/components/mentor-discussion-widget'
import '../../css/components/completed-exercise-progress'

import '../../css/components/widgets/exercise'
import '../../css/components/mentor-discussion-post-editor'
import '../../css/components/test-run'
import '../../css/components/alert'
import '../../css/components/diff'
import '../../css/components/cli-walkthrough'
import '../../css/components/cli-walkthrough-button'

import '../../css/modals/reset-account'
import '../../css/modals/badge'
import '../../css/modals/update-exercise'
import '../../css/modals/makers'
import '../../css/modals/test-run'
import '../../css/modals/crop-avatar'
import '../../css/modals/profile-first-time'
import '../../css/modals/completed-tutorial-exercise'
import '../../css/modals/completed-exercise'
import '../../css/modals/publish-exercise'
import '../../css/modals/mentoring-sessions'
import '../../css/modals/finish-mentor-discussion'
import '../../css/modals/confirm-finish-student-mentor-discussion'
import '../../css/modals/finish-student-mentor-discussion'
import '../../css/modals/welcome-to-v3'
import '../../css/modals/become-mentor'
import '../../css/modals/change-mentor-tracks'
import '../../css/modals/select-exercise-for-mentoring'
import '../../css/modals/testimonial'
import '../../css/modals/change-published-iteration'
import '../../css/modals/unpublish-solution'
import '../../css/modals/cli-walkthrough'

import '../../css/dropdowns/generic-menu'
import '../../css/dropdowns/share-solution'
import '../../css/dropdowns/notifications'
import '../../css/dropdowns/reputation'
import '../../css/dropdowns/request-mentoring'
import '../../css/dropdowns/open-editor-button'

import '../../css/pages/settings'
import '../../css/pages/contributing-dashboard'
import '../../css/pages/contributing-contributors'
import '../../css/pages/contributing-tasks'
import '../../css/pages/auth'
import '../../css/pages/dashboard'
import '../../css/pages/docs-show'
import '../../css/pages/docs-index'
import '../../css/pages/docs-tracks'
import '../../css/pages/onboarding'
import '../../css/pages/profile-intro'
import '../../css/pages/profile-new'
import '../../css/pages/profile'
import '../../css/pages/profile-badges'
import '../../css/pages/profile-solutions'
import '../../css/pages/profile-contributions'
import '../../css/pages/profile-testimonials'
import '../../css/pages/staging' // TODO: Remove for launch
import '../../css/pages/track-shared-index'
import '../../css/pages/concepts-index'
import '../../css/pages/concept-show'
import '../../css/pages/exercise-show'
import '../../css/pages/exercise-mentoring'
import '../../css/pages/exercises-index'
import '../../css/pages/iterations-index'
import '../../css/pages/community-solutions-index'
import '../../css/pages/community-solution-show'
import '../../css/pages/track-index'
import '../../css/pages/track-show-joined'
import '../../css/pages/track-show-unjoined'
import '../../css/pages/mentoring/external'
import '../../css/pages/mentoring/inbox'
import '../../css/pages/mentoring/queue'
import '../../css/pages/mentoring/testimonials'
import '../../css/pages/maintaining/dashboard'
import '../../css/pages/maintaining/track'
import '../../css/pages/journey'
import '../../css/pages/journey/overview'
import '../../css/pages/journey/solutions'
import '../../css/pages/journey/reputation'
import '../../css/pages/journey/badges'

import 'tippy.js/animations/shift-away-subtle.css'
import 'tippy.js/dist/svg-arrow.css'
import '../../css/highlighters/highlightjs-light'
import '../../css/highlighters/highlightjs-dark'

import React from 'react'
import { initReact } from '../utils/react-bootloader.jsx'
import * as Common from '../components/common'
import { CLIWalkthrough } from '../components/common/CLIWalkthrough'
import { CLIWalkthroughButton } from '../components/common/CLIWalkthroughButton'

import * as Student from '../components/student'

import * as TrackComponents from '../components/track'
import { ConceptMap } from '../components/concept-map/ConceptMap'
import { IConceptMap } from '../components/concept-map/concept-map-types'
import {
  Iteration,
  Track,
  Exercise,
  // MentorSessionRequest,
  // MentorSessionTrack,
  // MentorSessionExercise,
  MentorDiscussion,
  MentoredTrack,
  SolutionForStudent,
  CommunitySolution,
  Testimonial,
  // MentoredTrackExercise,
  User,
  SiteUpdate,
  CommunicationPreferences,
  TrackContribution,
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

import { Request } from '../hooks/request-query'
import { camelizeKeys } from 'humps'
function camelizeKeysAs<T>(object: any): T {
  return (camelizeKeys(object) as unknown) as T
}

// // Add all react components here.
// // Each should map 1-1 to a component in app/helpers/components
initReact({
  'common-concept-widget': (data: any) => (
    <Common.ConceptWidget concept={data.concept} />
  ),
  'common-modal': (data: any) => <Common.Modal html={data.html} />,
  'common-solution-view': (data: any) => (
    <Common.SolutionView
      iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
      language={data.language}
      indentSize={data.indent_size}
      publishedIterationIdx={data.published_iteration_idx}
      outOfDate={data.out_of_date}
      links={camelizeKeysAs<SolutionViewLinks>(data.links)}
    />
  ),
  'common-expander': (data: any) => (
    <Common.Expander
      content={data.content}
      buttonTextCompressed={data.button_text_compressed}
      buttonTextExpanded={data.button_text_expanded}
      className={data.class_name}
    />
  ),
  'common-community-solution': (data: any) => (
    <Common.CommunitySolution
      solution={camelizeKeysAs<CommunitySolution>(data.solution)}
      context={data.context}
    />
  ),
  'common-introducer': (data: any) => (
    <Common.Introducer
      icon={data.icon}
      content={data.content}
      endpoint={data.endpoint}
      hidden={data.hidden}
    />
  ),
  'common-cli-walkthrough': (data: any) => <CLIWalkthrough html={data.html} />,
  'common-cli-walkthrough-button': (data: any) => (
    <CLIWalkthroughButton html={data.html} />
  ),
  'track-exercise-community-solutions-list': (data: any) => (
    <TrackComponents.ExerciseCommunitySolutionsList
      request={camelizeKeysAs<Request>(data.request)}
    />
  ),
  'track-exercise-makers-button': (data: any) => (
    <TrackComponents.ExerciseMakersButton
      avatarUrls={camelizeKeysAs<readonly string[]>(data.avatar_urls)}
      numAuthors={data.num_authors}
      numContributors={data.num_contributors}
      links={data.links}
    />
  ),
  'track-concept-makers-button': (data: any) => (
    <TrackComponents.ConceptMakersButton
      avatarUrls={camelizeKeysAs<readonly string[]>(data.avatar_urls)}
      numAuthors={data.num_authors}
      numContributors={data.num_contributors}
      links={data.links}
    />
  ),
  'common-exercise-widget': (data: any) => (
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
  'common-share-solution-button': (data: any) => (
    <Common.ShareSolutionButton title={data.title} links={data.links} />
  ),
  'common-site-updates-list': (data: any) => (
    <Common.SiteUpdatesList
      updates={camelizeKeysAs<readonly SiteUpdate[]>(data.updates)}
      context={data.context}
    />
  ),
  'contributing-contributors-list': (data: any) => (
    <Contributing.ContributorsList
      request={camelizeKeysAs<Request>(data.request)}
      tracks={camelizeKeysAs<readonly Track[]>(data.tracks)}
    />
  ),
  'contributing-tasks-list': (data: any) => (
    <Contributing.TasksList
      request={camelizeKeysAs<ContributingTasksRequest>(data.request)}
      tracks={camelizeKeysAs<readonly Track[]>(data.tracks)}
    />
  ),
  'student-tracks-list': (data: any) => (
    <Student.TracksList request={data.request} tagOptions={data.tag_options} />
  ),
  'student-exercise-list': (data: any) => (
    <Student.ExerciseList
      request={camelizeKeysAs<Request>(data.request)}
      track={camelizeKeysAs<Track>(data.track)}
    />
  ),
  'student-exercise-status-chart': (data: any) => (
    <Student.ExerciseStatusChart
      exercisesData={data.exercises_data}
      links={data.links}
    />
  ),
  'student-exercise-status-dot': (data: any) => (
    <Student.ExerciseStatusDot
      slug={data.slug}
      exerciseStatus={data.exercise_status}
      type={data.type}
      links={data.links}
    />
  ),
  'student-open-editor-button': (data: any) => (
    <Student.OpenEditorButton
      status={data.status}
      links={data.links}
      command={data.command}
    />
  ),
  'student-complete-exercise-button': (data: any) => (
    <Student.CompleteExerciseButton
      endpoint={data.endpoint}
      iterations={camelizeKeysAs<readonly Iteration[]>(data.iterations)}
    />
  ),
  'concept-map': (data: any) => (
    <ConceptMap {...camelizeKeysAs<IConceptMap>(data.graph)} />
  ),

  'mentored-student-tooltip': (data: any) => (
    <Tooltips.StudentTooltip
      requestId={data.endpoint}
      endpoint={data.endpoint}
    />
  ),
  'user-tooltip': (data: any, elem: HTMLElement) => (
    <Tooltips.UserTooltip
      contentEndpoint={data.endpoint}
      referenceElement={elem}
      referenceUserHandle={data.handle}
      placement={data.placement}
      hoverRequestToShow={true}
      focusRequestToShow={true}
    />
  ),
  'exercise-tooltip': (data: any, elem: HTMLElement) => (
    <Tooltips.UserTooltip
      contentEndpoint={data.endpoint}
      referenceElement={elem}
      referenceUserHandle={data.handle}
      placement={data.placement}
      hoverRequestToShow={true}
      focusRequestToShow={true}
    />
  ),
  'dropdowns-dropdown': (data: any) => (
    <Dropdown menuButton={data.menu_button} menuItems={data.menu_items} />
  ),
  'common-copy-to-clipboard-button': (data: any) => (
    <Common.CopyToClipboardButton textToCopy={data.text_to_copy} />
  ),
  'common-icon': (data: any) => <Common.Icon icon={data.icon} alt={data.alt} />,
  'common-graphical-icon': (data: any) => (
    <Common.GraphicalIcon icon={data.icon} />
  ),
  'profile-testimonials-summary': (data: any) => (
    <Profile.TestimonialsSummary
      handle={data.handle}
      numTestimonials={data.num_testimonials}
      numSolutionsMentored={data.num_solutions_mentored}
      numStudentsHelped={data.num_students_helped}
      numTestimonialsReceived={data.num_testimonials_received}
      testimonials={camelizeKeysAs<Testimonial[]>(data.testimonials)}
      links={data.links}
    />
  ),
  'profile-community-solutions-list': (data: any) => (
    <Profile.CommunitySolutionsList
      request={camelizeKeysAs<Request>(data.request)}
      tracks={camelizeKeysAs<ProfileCommunitySolutionsListTrackData[]>(
        data.tracks
      )}
    />
  ),
  'profile-contributions-list': (data: any) => (
    <Profile.ContributionsList
      categories={camelizeKeysAs<readonly ProfileContributionsListCategory[]>(
        data.categories
      )}
    />
  ),
  'profile-contributions-summary': (data: any) => {
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
  'profile-first-time-modal': (data: any) => (
    <Profile.FirstTimeModal links={data.links} />
  ),
  'community-solutions-star-button': (data: any) => (
    <CommunitySolutions.StarButton
      defaultNumStars={data.num_stars}
      defaultIsStarred={data.is_starred}
      links={data.links}
    />
  ),
  'profile-avatar-selector': (data: any) => (
    <Profile.AvatarSelector
      user={camelizeKeysAs<User>(data.user)}
      links={data.links}
    />
  ),
  'common-progress-graph': (data: {
    values: Array<number>
    width: number
    height: number
  }) => (
    <Common.ProgressGraph
      data={data.values}
      height={data.height}
      width={data.width}
      smooth
    />
  ),
})

import { highlightAll } from '../utils/highlight'

document.addEventListener('turbolinks:load', () => {
  highlightAll()
})

const images = require.context('../images', true)
const imagePath = (name: any) => images(name)
