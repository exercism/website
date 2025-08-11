import aa from './automation-batch'
import ab from './components-bootcamp-common-ErrorBoundary'
import ac from './components-bootcamp-CSSExercisePage'
import ad from './components-bootcamp-CSSExercisePage-FinishLessonModal'
import ae from './components-bootcamp-CSSExercisePage-Header'
import af from './components-bootcamp-CSSExercisePage-LHS'
import ag from './components-bootcamp-CustomFunctionEditor'
import ah from './components-bootcamp-CustomFunctionEditor-Header'
import ai from './components-bootcamp-DrawingPage'
import aj from './components-bootcamp-FrontendExercisePage-Header'
import ak from './components-bootcamp-FrontendExercisePage-LHS'
import al from './components-bootcamp-FrontendExercisePage-RHS'
import am from './components-bootcamp-JikiscriptExercisePage-ControlButtons'
import an from './components-bootcamp-JikiscriptExercisePage-Header'
import ao from './components-bootcamp-JikiscriptExercisePage-RHS'
import ap from './components-bootcamp-JikiscriptExercisePage-Scrubber'
import aq from './components-bootcamp-JikiscriptExercisePage-TaskPreview'
import ar from './components-bootcamp-JikiscriptExercisePage-Tasks'
import as from './components-bootcamp-JikiscriptExercisePage-TestResultsView'
import at from './components-bootcamp-modals'
import au from './components-common-exercise-widget'
import av from './components-common-HandleWithFlair.tsx'
import aw from './components-common-markdown-editor-form'
import ax from './components-common-share-panel'
import ay from './components-community'
import az from './components-community-solutions'
import a0 from './components-concept-map'
import a1 from './components-contributing'
import a2 from './components-contributing-tasks-list-task'
import a3 from './components-donations'
import a4 from './components-donations-subscription-form'
import a5 from './components-dropdowns'
import a6 from './components-dropdowns-reputation'
import a7 from './components-dropdowns-track-menu'
import a8 from './components-editor-ChatGptFeedback'
import a9 from './components-editor-EditorStatusSummary.tsx'
import ba from './components-editor-FeedbackPanel'
import bb from './components-editor-GetHelp'
import bc from './components-editor-header'
import bd from './components-editor-legacy-file-banner'
import be from './components-editor-LegacyFileBanner.tsx'
import bf from './components-editor-panels'
import bg from './components-editor-RunTestsButton.tsx'
import bh from './components-editor-SubmitButton.tsx'
import bi from './components-editor-tabs'
import bj from './components-editor-testComponents'
import bk from './components-github-syncer-widget'
import bl from './components-impact-ImpactTestimonial.tsx'
import bm from './components-impact-TopLearningCountries.tsx'
import bn from './components-insiders'
import bo from './components-journey'
import bp from './components-journey-badges-list'
import bq from './components-journey-contribution-results'
import br from './components-journey-contributions-list'
import bs from './components-journey-overview'
import bt from './components-journey-overview-badges-section'
import bu from './components-journey-overview-contributing-section'
import bv from './components-journey-overview-learning-section'
import bw from './components-journey-overview-mentoring-section'
import bx from './components-journey-solutions-list'
import by from './components-maintaining'
import bz from './components-mentoring-automation-AutomationListElement.tsx'
import b0 from './components-mentoring-automation-Representation.tsx'
import b1 from './components-mentoring-automation-RepresentationList.tsx'
import b2 from './components-mentoring-discussion-discussion-post'
import b3 from './components-mentoring-discussion-finished-wizard'
import b4 from './components-mentoring-discussion-FinishedWizard.tsx'
import b5 from './components-mentoring-discussion-MarkAsNothingToDoButton.tsx'
import b6 from './components-mentoring-discussion-NewMessageAlert.tsx'
import b7 from './components-mentoring-inbox'
import b8 from './components-mentoring-Inboxtsx'
import b9 from './components-mentoring-queue'
import ca from './components-mentoring-Queuetsx'
import cb from './components-mentoring-representation-common'
import cc from './components-mentoring-representation-left-pane'
import cd from './components-mentoring-representation-modals'
import ce from './components-mentoring-representation-right-pane'
import cf from './components-mentoring-representation-right-pane-RadioGroup.tsx'
import cg from './components-mentoring-request-locked-solution-mentoring-note'
import ch from './components-mentoring-request-StartMentoringPanel.tsx'
import ci from './components-mentoring-Session.tsx'
import cj from './components-mentoring-session-favorite-button'
import ck from './components-mentoring-session-iteration-view'
import cl from './components-mentoring-session-mobile-code-panel-MobileIterationView.tsx'
import cm from './components-mentoring-session-mobile-code-panel-SessionInfoModal.tsx'
import cn from './components-mentoring-session-Scratchpad.tsx'
import co from './components-mentoring-session-SessionInfo.tsx'
import cp from './components-mentoring-session-student-info'
import cq from './components-mentoring-session-StudentInfo.tsx'
import cr from './components-mentoring-testimonials-list'
import cs from './components-mentoring-testimonials-list-revealed-testimonial'
import ct from './components-mentoring-TestimonialsList.tsx'
import cu from './components-mentoring-track-selector'
import cv from './components-modals-BadgeModal.tsx'
import cw from './components-modals-BegModal.tsx'
import cx from './components-modals-BugReportModal.tsx'
import cy from './components-modals-ChangePublishedIterationModal.tsx'
import cz from './components-modals-complete-exercise-modal'
import c0 from './components-modals-complete-exercise-modal-exercise-completed-modal-Unlocks.tsx'
import c1 from './components-modals-ConceptMakersModal.tsx'
import c2 from './components-modals-DeleteAccountModal.tsx'
import c3 from './components-modals-DisableSolutionCommentsModal.tsx'
import c4 from './components-modals-EnableSolutionCommentsModal.tsx'
import c5 from './components-modals-exercise-update-modal'
import c6 from './components-modals-ExerciseMakersModal.tsx'
import c7 from './components-modals-ExerciseUpdateModal.tsx'
import c8 from './components-modals-mentor'
import c9 from './components-modals-mentor-registration-modal'
import da from './components-modals-mentor-registration-modal-commit-step'
import db from './components-modals-MentorChangeTracksModal.tsx'
import dc from './components-modals-MentorRegistrationModal.tsx'
import dd from './components-modals-PreviousMentoringSessionsModal.tsx'
import de from './components-modals-profile'
import df from './components-modals-PublishSolutionModal.tsx'
import dg from './components-modals-realtime-feedback-modal'
import dh from './components-modals-realtime-feedback-modal-components'
import di from './components-modals-realtime-feedback-modal-feedback-content'
import dj from './components-modals-realtime-feedback-modal-feedback-content-found-automated-feedback'
import dk from './components-modals-realtime-feedback-modal-feedback-content-no-automated-feedback'
import dl from './components-modals-RequestMentoringModal.tsx'
import dm from './components-modals-ResetAccountModal.tsx'
import dn from './components-modals-seniority-survey-modal'
import dp from './components-modals-student'
import dq from './components-modals-student-finish-mentor-discussion-modal'
import dr from './components-modals-TaskHintsModal.tsx'
import ds from './components-modals-TestimonialModal.tsx'
import dt from './components-modals-track-welcome-modal-LHS'
import du from './components-modals-track-welcome-modal-LHS-steps'
import dv from './components-modals-track-welcome-modal-LHS-steps-components'
import dw from './components-modals-track-welcome-modal-RHS'
import dx from './components-modals-UnpublishSolutionModal.tsx'
import dy from './components-modals-upload-video'
import dz from './components-modals-upload-video-elements'
import d0 from './components-modals-welcome-modal'
import d1 from './components-modals-WelcomeToInsidersModal.tsx'
import d2 from './components-notifications-'
import d3 from './components-notifications-notifications-list'
import d4 from './components-perks'
import d5 from './components-profile'
import d6 from './components-profile-avatar-selector'
import d7 from './components-profile-avatar-selector-cropping-modal'
import d8 from './components-profile-avatar-selector-photo'
import d9 from './components-profile-community-solutions-list'
import ea from './components-profile-contributions-list'
import eb from './components-profile-contributions-summary'
import ec from './components-profile-testimonials-list'
import ed from './components-settings-BootcampAffiliateCouponForm.tsx'
import ee from './components-settings-BootcampFreeCouponForm.tsx'
import ef from './components-settings-comments-preference-form'
import eg from './components-settings-CommunicationPreferencesForm.tsx'
import eh from './components-settings-delete-profile-form'
import ei from './components-settings-DeleteAccountButton.tsx'
import ej from './components-settings-DeleteProfileForm.tsx'
import ek from './components-settings-EmailForm.tsx'
import el from './components-settings-FormMessage.tsx'
import em from './components-settings-github-syncer-common'
import en from './components-settings-github-syncer-sections-ConnectedSection'
import eo from './components-settings-github-syncer-sections-ConnectedSection-ManualSyncSection.tsx'
import ep from './components-settings-github-syncer-sections-ConnectedSection-SyncBehaviourSection.tsx'
import eq from './components-settings-HandleForm.tsx'
import er from './components-settings-InsiderBenefitsForm.tsx'
import es from './components-settings-PasswordForm.tsx'
import et from './components-settings-PhotoForm.tsx'
import eu from './components-settings-ProfileForm.tsx'
import ev from './components-settings-PronounsForm.tsx'
import ew from './components-settings-ResetAccountButton.tsx'
import ex from './components-settings-ShowOnSupportersPageButton.tsx'
import ey from './components-settings-theme-preference-form'
import ez from './components-settings-ThemePreferenceForm.tsx'
import e0 from './components-settings-TokenForm.tsx'
import e1 from './components-settings-useInvalidField.tsx'
import e2 from './components-settings-UserPreferencesForm.tsx'
import e3 from './components-settings-useSettingsMutation.tsx'
import e4 from './components-student-CompleteExerciseButton.tsx'
import e5 from './components-student-ExerciseList.tsx'
import e6 from './components-student-ExerciseStatusChart.tsx'
import e7 from './components-student-ExerciseStatusDot.tsx'
import e8 from './components-student-iterations-list'
import e9 from './components-student-mentoring-dropdown'
import fa from './components-student-mentoring-session'
import fb from './components-student-mentoring-session-iteration-view'
import fc from './components-student-mentoring-session-mentoring-request'
import fd from './components-student-mentoring-session-mentoring-request-MentoringRequestFormComponents'
import fe from './components-student-MentoringComboButton.tsx'
import ff from './components-student-MentoringSession.tsx'
import fg from './components-student-open-editor-button'
import fh from './components-student-OpenEditorButton.tsx'
import fi from './components-student-published-solution'
import fj from './components-student-PublishSolutionButton.tsx'
import fk from './components-student-RequestMentoringButton.tsx'
import fl from './components-student-solution-summary'
import fm from './components-student-tracks-list'
import fn from './components-student-TracksList.tsx'
import fo from './components-student-UpdateExerciseNotice.tsx'
import fp from './components-test'
import fq from './components-tooltips-ExerciseTooltip.tsx'
import fr from './components-tooltips-studentTooltip'
import fs from './components-tooltips-task-tooltip'
import ft from './components-track-activity-ticker'
import fu from './components-track-build-analyzer-tags'
import fv from './components-track-dig-deeper-components'
import fw from './components-track-dig-deeper-components-community-videos'
import fx from './components-track-dig-deeper-components-no-content-yet'
import fy from './components-track-exercise-community-solutions-list'
import fz from './components-track-ExerciseCommunitySolutionsList.tsx'
import f0 from './components-track-iteration-summary'
import f1 from './components-track-IterationSummary.tsx'
import f2 from './components-track-Trophies.tsx'
import f3 from './components-track-UnlockHelpButton.tsx'
import f4 from './components-training-data-code-tagger'
import f5 from './components-training-data-dashboard'
import f6 from './discussion-batch'
import f7 from './session-batch-1'
import f8 from './session-batch-2'
import f9 from './session-batch-3'

export default {
  'automation-batch': aa,
  'components/bootcamp/common/ErrorBoundary': ab,
  'components/bootcamp/CSSExercisePage': ac,
  'components/bootcamp/CSSExercisePage/FinishLessonModal': ad,
  'components/bootcamp/CSSExercisePage/Header': ae,
  'components/bootcamp/CSSExercisePage/LHS': af,
  'components/bootcamp/CustomFunctionEditor': ag,
  'components/bootcamp/CustomFunctionEditor/Header': ah,
  'components/bootcamp/DrawingPage': ai,
  'components/bootcamp/FrontendExercisePage/Header': aj,
  'components/bootcamp/FrontendExercisePage/LHS': ak,
  'components/bootcamp/FrontendExercisePage/RHS': al,
  'components/bootcamp/JikiscriptExercisePage/ControlButtons': am,
  'components/bootcamp/JikiscriptExercisePage/Header': an,
  'components/bootcamp/JikiscriptExercisePage/RHS': ao,
  'components/bootcamp/JikiscriptExercisePage/Scrubber': ap,
  'components/bootcamp/JikiscriptExercisePage/TaskPreview': aq,
  'components/bootcamp/JikiscriptExercisePage/Tasks': ar,
  'components/bootcamp/JikiscriptExercisePage/TestResultsView': as,
  'components/bootcamp/modals': at,
  'components/common/exercise-widget': au,
  'components/common/HandleWithFlair.tsx': av,
  'components/common/markdown-editor-form': aw,
  'components/common/share-panel': ax,
  'components/community': ay,
  'components/community-solutions': az,
  'components/concept-map': a0,
  'components/contributing': a1,
  'components/contributing/tasks-list/task': a2,
  'components/donations': a3,
  'components/donations/subscription-form': a4,
  'components/dropdowns': a5,
  'components/dropdowns/reputation': a6,
  'components/dropdowns/track-menu': a7,
  'components/editor/ChatGptFeedback': a8,
  'components/editor/EditorStatusSummary.tsx': a9,
  'components/editor/FeedbackPanel': ba,
  'components/editor/GetHelp': bb,
  'components/editor/header': bc,
  'components/editor/legacy-file-banner': bd,
  'components/editor/LegacyFileBanner.tsx': be,
  'components/editor/panels': bf,
  'components/editor/RunTestsButton.tsx': bg,
  'components/editor/SubmitButton.tsx': bh,
  'components/editor/tabs': bi,
  'components/editor/testComponents': bj,
  'components/github-syncer-widget': bk,
  'components/impact/ImpactTestimonial.tsx': bl,
  'components/impact/TopLearningCountries.tsx': bm,
  'components/insiders': bn,
  'components/journey': bo,
  'components/journey/badges-list': bp,
  'components/journey/contribution-results': bq,
  'components/journey/contributions-list': br,
  'components/journey/overview': bs,
  'components/journey/overview/badges-section': bt,
  'components/journey/overview/contributing-section': bu,
  'components/journey/overview/learning-section': bv,
  'components/journey/overview/mentoring-section': bw,
  'components/journey/solutions-list': bx,
  'components/maintaining': by,
  'components/mentoring/automation/AutomationListElement.tsx': bz,
  'components/mentoring/automation/Representation.tsx': b0,
  'components/mentoring/automation/RepresentationList.tsx': b1,
  'components/mentoring/discussion/discussion-post': b2,
  'components/mentoring/discussion/finished-wizard': b3,
  'components/mentoring/discussion/FinishedWizard.tsx': b4,
  'components/mentoring/discussion/MarkAsNothingToDoButton.tsx': b5,
  'components/mentoring/discussion/NewMessageAlert.tsx': b6,
  'components/mentoring/inbox': b7,
  'components/mentoring/Inboxtsx': b8,
  'components/mentoring/queue': b9,
  'components/mentoring/Queuetsx': ca,
  'components/mentoring/representation/common': cb,
  'components/mentoring/representation/left-pane': cc,
  'components/mentoring/representation/modals': cd,
  'components/mentoring/representation/right-pane': ce,
  'components/mentoring/representation/right-pane/RadioGroup.tsx': cf,
  'components/mentoring/request/locked-solution-mentoring-note': cg,
  'components/mentoring/request/StartMentoringPanel.tsx': ch,
  'components/mentoring/Session.tsx': ci,
  'components/mentoring/session/favorite-button': cj,
  'components/mentoring/session/iteration-view': ck,
  'components/mentoring/session/mobile-code-panel/MobileIterationView.tsx': cl,
  'components/mentoring/session/mobile-code-panel/SessionInfoModal.tsx': cm,
  'components/mentoring/session/Scratchpad.tsx': cn,
  'components/mentoring/session/SessionInfo.tsx': co,
  'components/mentoring/session/student-info': cp,
  'components/mentoring/session/StudentInfo.tsx': cq,
  'components/mentoring/testimonials-list': cr,
  'components/mentoring/testimonials-list/revealed-testimonial': cs,
  'components/mentoring/TestimonialsList.tsx': ct,
  'components/mentoring/track-selector': cu,
  'components/modals/BadgeModal.tsx': cv,
  'components/modals/BegModal.tsx': cw,
  'components/modals/BugReportModal.tsx': cx,
  'components/modals/ChangePublishedIterationModal.tsx': cy,
  'components/modals/complete-exercise-modal': cz,
  'components/modals/complete-exercise-modal/exercise-completed-modal/Unlocks.tsx':
    c0,
  'components/modals/ConceptMakersModal.tsx': c1,
  'components/modals/DeleteAccountModal.tsx': c2,
  'components/modals/DisableSolutionCommentsModal.tsx': c3,
  'components/modals/EnableSolutionCommentsModal.tsx': c4,
  'components/modals/exercise-update-modal': c5,
  'components/modals/ExerciseMakersModal.tsx': c6,
  'components/modals/ExerciseUpdateModal.tsx': c7,
  'components/modals/mentor': c8,
  'components/modals/mentor-registration-modal': c9,
  'components/modals/mentor-registration-modal/commit-step': da,
  'components/modals/MentorChangeTracksModal.tsx': db,
  'components/modals/MentorRegistrationModal.tsx': dc,
  'components/modals/PreviousMentoringSessionsModal.tsx': dd,
  'components/modals/profile': de,
  'components/modals/PublishSolutionModal.tsx': df,
  'components/modals/realtime-feedback-modal': dg,
  'components/modals/realtime-feedback-modal/components': dh,
  'components/modals/realtime-feedback-modal/feedback-content': di,
  'components/modals/realtime-feedback-modal/feedback-content/found-automated-feedback':
    dj,
  'components/modals/realtime-feedback-modal/feedback-content/no-automated-feedback':
    dk,
  'components/modals/RequestMentoringModal.tsx': dl,
  'components/modals/ResetAccountModal.tsx': dm,
  'components/modals/seniority-survey-modal': dn,
  'components/modals/student': dp,
  'components/modals/student/finish-mentor-discussion-modal': dq,
  'components/modals/TaskHintsModal.tsx': dr,
  'components/modals/TestimonialModal.tsx': ds,
  'components/modals/track-welcome-modal/LHS': dt,
  'components/modals/track-welcome-modal/LHS/steps': du,
  'components/modals/track-welcome-modal/LHS/steps/components': dv,
  'components/modals/track-welcome-modal/RHS': dw,
  'components/modals/UnpublishSolutionModal.tsx': dx,
  'components/modals/upload-video': dy,
  'components/modals/upload-video/elements': dz,
  'components/modals/welcome-modal': d0,
  'components/modals/WelcomeToInsidersModal.tsx': d1,
  'components/notifications/': d2,
  'components/notifications/notifications-list': d3,
  'components/perks': d4,
  'components/profile': d5,
  'components/profile/avatar-selector': d6,
  'components/profile/avatar-selector/cropping-modal': d7,
  'components/profile/avatar-selector/photo': d8,
  'components/profile/community-solutions-list': d9,
  'components/profile/contributions-list': ea,
  'components/profile/contributions-summary': eb,
  'components/profile/testimonials-list': ec,
  'components/settings/BootcampAffiliateCouponForm.tsx': ed,
  'components/settings/BootcampFreeCouponForm.tsx': ee,
  'components/settings/comments-preference-form': ef,
  'components/settings/CommunicationPreferencesForm.tsx': eg,
  'components/settings/delete-profile-form': eh,
  'components/settings/DeleteAccountButton.tsx': ei,
  'components/settings/DeleteProfileForm.tsx': ej,
  'components/settings/EmailForm.tsx': ek,
  'components/settings/FormMessage.tsx': el,
  'components/settings/github-syncer/common': em,
  'components/settings/github-syncer/sections/ConnectedSection': en,
  'components/settings/github-syncer/sections/ConnectedSection/ManualSyncSection.tsx':
    eo,
  'components/settings/github-syncer/sections/ConnectedSection/SyncBehaviourSection.tsx':
    ep,
  'components/settings/HandleForm.tsx': eq,
  'components/settings/InsiderBenefitsForm.tsx': er,
  'components/settings/PasswordForm.tsx': es,
  'components/settings/PhotoForm.tsx': et,
  'components/settings/ProfileForm.tsx': eu,
  'components/settings/PronounsForm.tsx': ev,
  'components/settings/ResetAccountButton.tsx': ew,
  'components/settings/ShowOnSupportersPageButton.tsx': ex,
  'components/settings/theme-preference-form': ey,
  'components/settings/ThemePreferenceForm.tsx': ez,
  'components/settings/TokenForm.tsx': e0,
  'components/settings/useInvalidField.tsx': e1,
  'components/settings/UserPreferencesForm.tsx': e2,
  'components/settings/useSettingsMutation.tsx': e3,
  'components/student/CompleteExerciseButton.tsx': e4,
  'components/student/ExerciseList.tsx': e5,
  'components/student/ExerciseStatusChart.tsx': e6,
  'components/student/ExerciseStatusDot.tsx': e7,
  'components/student/iterations-list': e8,
  'components/student/mentoring-dropdown': e9,
  'components/student/mentoring-session': fa,
  'components/student/mentoring-session/iteration-view': fb,
  'components/student/mentoring-session/mentoring-request': fc,
  'components/student/mentoring-session/mentoring-request/MentoringRequestFormComponents':
    fd,
  'components/student/MentoringComboButton.tsx': fe,
  'components/student/MentoringSession.tsx': ff,
  'components/student/open-editor-button': fg,
  'components/student/OpenEditorButton.tsx': fh,
  'components/student/published-solution': fi,
  'components/student/PublishSolutionButton.tsx': fj,
  'components/student/RequestMentoringButton.tsx': fk,
  'components/student/solution-summary': fl,
  'components/student/tracks-list': fm,
  'components/student/TracksList.tsx': fn,
  'components/student/UpdateExerciseNotice.tsx': fo,
  'components/test': fp,
  'components/tooltips/ExerciseTooltip.tsx': fq,
  'components/tooltips/student-tooltip': fr,
  'components/tooltips/task-tooltip': fs,
  'components/track/activity-ticker': ft,
  'components/track/build/analyzer-tags': fu,
  'components/track/dig-deeper-components': fv,
  'components/track/dig-deeper-components/community-videos': fw,
  'components/track/dig-deeper-components/no-content-yet': fx,
  'components/track/exercise-community-solutions-list': fy,
  'components/track/ExerciseCommunitySolutionsList.tsx': fz,
  'components/track/iteration-summary': f0,
  'components/track/IterationSummary.tsx': f1,
  'components/track/Trophies.tsx': f2,
  'components/track/UnlockHelpButton.tsx': f3,
  'components/training-data/code-tagger': f4,
  'components/training-data/dashboard': f5,
  'discussion-batch': f6,
  'session-batch-1': f7,
  'session-batch-2': f8,
  'session-batch-3': f9,
}
