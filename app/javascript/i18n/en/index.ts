import aa from './automation-batch'
import ab from './components-common-exercise-widget'
import ac from './components-common-markdown-editor-form'
import ad from './components-common-share-panel'
import ae from './components-community'
import af from './components-community-solutions'
import ag from './components-concept-map'
import ah from './components-contributing'
import ai from './components-contributing-tasks-list-task'
import aj from './components-donations'
import ak from './components-donations-subscription-form'
import al from './components-dropdowns'
import am from './components-dropdowns-reputation'
import an from './components-dropdowns-track-menu'
import ao from './components-editor-ChatGptFeedback'
import ap from './components-editor-EditorStatusSummary.tsx'
import aq from './components-editor-FeedbackPanel'
import ar from './components-editor-GetHelp'
import as from './components-editor-header'
import at from './components-editor-legacy-file-banner'
import au from './components-editor-LegacyFileBanner.tsx'
import av from './components-editor-panels'
import aw from './components-editor-RunTestsButton.tsx'
import ax from './components-editor-SubmitButton.tsx'
import ay from './components-editor-tabs'
import az from './components-editor-testComponents'
import a0 from './components-github-syncer-widget'
import a1 from './components-impact-ImpactTestimonial.tsx'
import a2 from './components-impact-TopLearningCountries.tsx'
import a3 from './components-insiders'
import a4 from './components-journey'
import a5 from './components-journey-badges-list'
import a6 from './components-journey-contribution-results'
import a7 from './components-journey-contributions-list'
import a8 from './components-journey-overview'
import a9 from './components-journey-overview-badges-section'
import ba from './components-journey-overview-contributing-section'
import bb from './components-journey-overview-learning-section'
import bc from './components-journey-overview-mentoring-section'
import bd from './components-journey-solutions-list'
import be from './components-maintaining'
import bf from './components-mentoring-automation-AutomationListElement.tsx'
import bg from './components-mentoring-automation-Representation.tsx'
import bh from './components-mentoring-automation-RepresentationList.tsx'
import bi from './components-mentoring-discussion-discussion-post'
import bj from './components-mentoring-discussion-finished-wizard'
import bk from './components-mentoring-discussion-FinishedWizard.tsx'
import bl from './components-mentoring-discussion-MarkAsNothingToDoButton.tsx'
import bm from './components-mentoring-discussion-NewMessageAlert.tsx'
import bn from './components-mentoring-inbox'
import bo from './components-mentoring-Inboxtsx'
import bp from './components-mentoring-queue'
import bq from './components-mentoring-Queuetsx'
import br from './components-mentoring-representation-common'
import bs from './components-mentoring-representation-left-pane'
import bt from './components-mentoring-representation-modals'
import bu from './components-mentoring-representation-right-pane'
import bv from './components-mentoring-representation-right-pane-RadioGroup.tsx'
import bw from './components-mentoring-request-locked-solution-mentoring-note'
import bx from './components-mentoring-request-StartMentoringPanel.tsx'
import by from './components-mentoring-Session.tsx'
import bz from './components-mentoring-session-favorite-button'
import b0 from './components-mentoring-session-iteration-view'
import b1 from './components-mentoring-session-mobile-code-panel-MobileIterationView.tsx'
import b2 from './components-mentoring-session-mobile-code-panel-SessionInfoModal.tsx'
import b3 from './components-mentoring-session-Scratchpad.tsx'
import b4 from './components-mentoring-session-SessionInfo.tsx'
import b5 from './components-mentoring-session-student-info'
import b6 from './components-mentoring-session-StudentInfo.tsx'
import b7 from './components-mentoring-testimonials-list'
import b8 from './components-mentoring-testimonials-list-revealed-testimonial'
import b9 from './components-mentoring-TestimonialsList.tsx'
import ca from './components-mentoring-track-selector'
import cb from './components-modals-BadgeModal.tsx'
import cc from './components-modals-BegModal.tsx'
import cd from './components-modals-BugReportModal.tsx'
import ce from './components-modals-ChangePublishedIterationModal.tsx'
import cf from './components-modals-complete-exercise-modal'
import cg from './components-modals-complete-exercise-modal-exercise-completed-modal-Unlocks.tsx'
import ch from './components-modals-ConceptMakersModal.tsx'
import ci from './components-modals-DeleteAccountModal.tsx'
import cj from './components-modals-DisableSolutionCommentsModal.tsx'
import ck from './components-modals-EnableSolutionCommentsModal.tsx'
import cl from './components-modals-exercise-update-modal'
import cm from './components-modals-ExerciseMakersModal.tsx'
import cn from './components-modals-ExerciseUpdateModal.tsx'
import co from './components-modals-mentor'
import cp from './components-modals-mentor-registration-modal'
import cq from './components-modals-mentor-registration-modal-commit-step'
import cr from './components-modals-MentorChangeTracksModal.tsx'
import cs from './components-modals-MentorRegistrationModal.tsx'
import ct from './components-modals-PreviousMentoringSessionsModal.tsx'
import cu from './components-modals-profile'
import cv from './components-modals-PublishSolutionModal.tsx'
import cw from './components-modals-realtime-feedback-modal'
import cx from './components-modals-realtime-feedback-modal-components'
import cy from './components-modals-realtime-feedback-modal-feedback-content'
import cz from './components-modals-realtime-feedback-modal-feedback-content-found-automated-feedback'
import c0 from './components-modals-realtime-feedback-modal-feedback-content-no-automated-feedback'
import c1 from './components-modals-RequestMentoringModal.tsx'
import c2 from './components-modals-ResetAccountModal.tsx'
import c3 from './components-modals-seniority-survey-modal'
import c4 from './components-modals-student'
import c5 from './components-modals-student-finish-mentor-discussion-modal'
import c6 from './components-modals-TaskHintsModal.tsx'
import c7 from './components-modals-TestimonialModal.tsx'
import c8 from './components-modals-track-welcome-modal-LHS-steps'
import c9 from './components-modals-track-welcome-modal-LHS-steps-components'
import da from './components-modals-track-welcome-modal-RHS'
import db from './components-modals-UnpublishSolutionModal.tsx'
import dc from './components-modals-upload-video'
import dd from './components-modals-upload-video-elements'
import de from './components-modals-welcome-modal'
import df from './components-modals-WelcomeToInsidersModal.tsx'
import dg from './discussion-batch'
import dh from './session-batch-1'
import di from './session-batch-2'
import dj from './session-batch'

export default {
  'automation-batch': aa,
  'components/common/exercise-widget': ab,
  'components/common/markdown-editor-form': ac,
  'components/common/share-panel': ad,
  'components/community': ae,
  'components/community-solutions': af,
  'components/concept-map': ag,
  'components/contributing': ah,
  'components/contributing/tasks-list/task': ai,
  'components/donations': aj,
  'components/donations/subscription-form': ak,
  'components/dropdowns': al,
  'components/dropdowns/reputation': am,
  'components/dropdowns/track-menu': an,
  'components/editor/ChatGptFeedback': ao,
  'components/editor/EditorStatusSummary.tsx': ap,
  'components/editor/FeedbackPanel': aq,
  'components/editor/GetHelp': ar,
  'components/editor/header': as,
  'components/editor/legacy-file-banner': at,
  'components/editor/LegacyFileBanner.tsx': au,
  'components/editor/panels': av,
  'components/editor/RunTestsButton.tsx': aw,
  'components/editor/SubmitButton.tsx': ax,
  'components/editor/tabs': ay,
  'components/editor/testComponents': az,
  'components/github-syncer-widget': a0,
  'components/impact/ImpactTestimonial.tsx': a1,
  'components/impact/TopLearningCountries.tsx': a2,
  'components/insiders': a3,
  'components/journey': a4,
  'components/journey/badges-list': a5,
  'components/journey/contribution-results': a6,
  'components/journey/contributions-list': a7,
  'components/journey/overview': a8,
  'components/journey/overview/badges-section': a9,
  'components/journey/overview/contributing-section': ba,
  'components/journey/overview/learning-section': bb,
  'components/journey/overview/mentoring-section': bc,
  'components/journey/solutions-list': bd,
  'components/maintaining': be,
  'components/mentoring/automation/AutomationListElement.tsx': bf,
  'components/mentoring/automation/Representation.tsx': bg,
  'components/mentoring/automation/RepresentationList.tsx': bh,
  'components/mentoring/discussion/discussion-post': bi,
  'components/mentoring/discussion/finished-wizard': bj,
  'components/mentoring/discussion/FinishedWizard.tsx': bk,
  'components/mentoring/discussion/MarkAsNothingToDoButton.tsx': bl,
  'components/mentoring/discussion/NewMessageAlert.tsx': bm,
  'components/mentoring/inbox': bn,
  'components/mentoring/Inboxtsx': bo,
  'components/mentoring/queue': bp,
  'components/mentoring/Queuetsx': bq,
  'components/mentoring/representation/common': br,
  'components/mentoring/representation/left-pane': bs,
  'components/mentoring/representation/modals': bt,
  'components/mentoring/representation/right-pane': bu,
  'components/mentoring/representation/right-pane/RadioGroup.tsx': bv,
  'components/mentoring/request/locked-solution-mentoring-note': bw,
  'components/mentoring/request/StartMentoringPanel.tsx': bx,
  'components/mentoring/Session.tsx': by,
  'components/mentoring/session/favorite-button': bz,
  'components/mentoring/session/iteration-view': b0,
  'components/mentoring/session/mobile-code-panel/MobileIterationView.tsx': b1,
  'components/mentoring/session/mobile-code-panel/SessionInfoModal.tsx': b2,
  'components/mentoring/session/Scratchpad.tsx': b3,
  'components/mentoring/session/SessionInfo.tsx': b4,
  'components/mentoring/session/student-info': b5,
  'components/mentoring/session/StudentInfo.tsx': b6,
  'components/mentoring/testimonials-list': b7,
  'components/mentoring/testimonials-list/revealed-testimonial': b8,
  'components/mentoring/TestimonialsList.tsx': b9,
  'components/mentoring/track-selector': ca,
  'components/modals/BadgeModal.tsx': cb,
  'components/modals/BegModal.tsx': cc,
  'components/modals/BugReportModal.tsx': cd,
  'components/modals/ChangePublishedIterationModal.tsx': ce,
  'components/modals/complete-exercise-modal': cf,
  'components/modals/complete-exercise-modal/exercise-completed-modal/Unlocks.tsx':
    cg,
  'components/modals/ConceptMakersModal.tsx': ch,
  'components/modals/DeleteAccountModal.tsx': ci,
  'components/modals/DisableSolutionCommentsModal.tsx': cj,
  'components/modals/EnableSolutionCommentsModal.tsx': ck,
  'components/modals/exercise-update-modal': cl,
  'components/modals/ExerciseMakersModal.tsx': cm,
  'components/modals/ExerciseUpdateModal.tsx': cn,
  'components/modals/mentor': co,
  'components/modals/mentor-registration-modal': cp,
  'components/modals/mentor-registration-modal/commit-step': cq,
  'components/modals/MentorChangeTracksModal.tsx': cr,
  'components/modals/MentorRegistrationModal.tsx': cs,
  'components/modals/PreviousMentoringSessionsModal.tsx': ct,
  'components/modals/profile': cu,
  'components/modals/PublishSolutionModal.tsx': cv,
  'components/modals/realtime-feedback-modal': cw,
  'components/modals/realtime-feedback-modal/components': cx,
  'components/modals/realtime-feedback-modal/feedback-content': cy,
  'components/modals/realtime-feedback-modal/feedback-content/found-automated-feedback':
    cz,
  'components/modals/realtime-feedback-modal/feedback-content/no-automated-feedback':
    c0,
  'components/modals/RequestMentoringModal.tsx': c1,
  'components/modals/ResetAccountModal.tsx': c2,
  'components/modals/seniority-survey-modal': c3,
  'components/modals/student': c4,
  'components/modals/student/finish-mentor-discussion-modal': c5,
  'components/modals/TaskHintsModal.tsx': c6,
  'components/modals/TestimonialModal.tsx': c7,
  'components/modals/track-welcome-modal/LHS/steps': c8,
  'components/modals/track-welcome-modal/LHS/steps/components': c9,
  'components/modals/track-welcome-modal/RHS': da,
  'components/modals/UnpublishSolutionModal.tsx': db,
  'components/modals/upload-video': dc,
  'components/modals/upload-video/elements': dd,
  'components/modals/welcome-modal': de,
  'components/modals/WelcomeToInsidersModal.tsx': df,
  'discussion-batch': dg,
  'session-batch-1': dh,
  'session-batch-2': di,
  'session-batch-3': dj,
}
