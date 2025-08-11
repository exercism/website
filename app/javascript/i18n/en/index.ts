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
import av from './components-common-markdown-editor-form'
import aw from './components-common-share-panel'
import ax from './components-community'
import ay from './components-community-solutions'
import az from './components-concept-map'
import a0 from './components-contributing'
import a1 from './components-contributing-tasks-list-task'
import a2 from './components-donations'
import a3 from './components-donations-subscription-form'
import a4 from './components-dropdowns'
import a5 from './components-dropdowns-reputation'
import a6 from './components-dropdowns-track-menu'
import a7 from './components-editor-ChatGptFeedback'
import a8 from './components-editor-EditorStatusSummary.tsx'
import a9 from './components-editor-FeedbackPanel'
import ba from './components-editor-GetHelp'
import bb from './components-editor-header'
import bc from './components-editor-legacy-file-banner'
import bd from './components-editor-LegacyFileBanner.tsx'
import be from './components-editor-panels'
import bf from './components-editor-RunTestsButton.tsx'
import bg from './components-editor-SubmitButton.tsx'
import bh from './components-editor-tabs'
import bi from './components-editor-testComponents'
import bj from './components-github-syncer-widget'
import bk from './components-impact-ImpactTestimonial.tsx'
import bl from './components-impact-TopLearningCountries.tsx'
import bm from './components-insiders'
import bn from './components-journey'
import bo from './components-journey-badges-list'
import bp from './components-journey-contribution-results'
import bq from './components-journey-contributions-list'
import br from './components-journey-overview'
import bs from './components-journey-overview-badges-section'
import bt from './components-journey-overview-contributing-section'
import bu from './components-journey-overview-learning-section'
import bv from './components-journey-overview-mentoring-section'
import bw from './components-journey-solutions-list'
import bx from './components-maintaining'
import by from './components-mentoring-automation-AutomationListElement.tsx'
import bz from './components-mentoring-automation-Representation.tsx'
import b0 from './components-mentoring-automation-RepresentationList.tsx'
import b1 from './components-mentoring-discussion-discussion-post'
import b2 from './components-mentoring-discussion-finished-wizard'
import b3 from './components-mentoring-discussion-FinishedWizard.tsx'
import b4 from './components-mentoring-discussion-MarkAsNothingToDoButton.tsx'
import b5 from './components-mentoring-discussion-NewMessageAlert.tsx'
import b6 from './components-mentoring-inbox'
import b7 from './components-mentoring-Inboxtsx'
import b8 from './components-mentoring-queue'
import b9 from './components-mentoring-Queuetsx'
import ca from './components-mentoring-representation-common'
import cb from './components-mentoring-representation-left-pane'
import cc from './components-mentoring-representation-modals'
import cd from './components-mentoring-representation-right-pane'
import ce from './components-mentoring-representation-right-pane-RadioGroup.tsx'
import cf from './components-mentoring-request-locked-solution-mentoring-note'
import cg from './components-mentoring-request-StartMentoringPanel.tsx'
import ch from './components-mentoring-Session.tsx'
import ci from './components-mentoring-session-favorite-button'
import cj from './components-mentoring-session-iteration-view'
import ck from './components-mentoring-session-mobile-code-panel-MobileIterationView.tsx'
import cl from './components-mentoring-session-mobile-code-panel-SessionInfoModal.tsx'
import cm from './components-mentoring-session-Scratchpad.tsx'
import cn from './components-mentoring-session-SessionInfo.tsx'
import co from './components-mentoring-session-student-info'
import cp from './components-mentoring-session-StudentInfo.tsx'
import cq from './components-mentoring-testimonials-list'
import cr from './components-mentoring-testimonials-list-revealed-testimonial'
import cs from './components-mentoring-TestimonialsList.tsx'
import ct from './components-mentoring-track-selector'
import cu from './components-modals-BadgeModal.tsx'
import cv from './components-modals-BegModal.tsx'
import cw from './components-modals-BugReportModal.tsx'
import cx from './components-modals-ChangePublishedIterationModal.tsx'
import cy from './components-modals-complete-exercise-modal'
import cz from './components-modals-complete-exercise-modal-exercise-completed-modal-Unlocks.tsx'
import c0 from './components-modals-ConceptMakersModal.tsx'
import c1 from './components-modals-DeleteAccountModal.tsx'
import c2 from './components-modals-DisableSolutionCommentsModal.tsx'
import c3 from './components-modals-EnableSolutionCommentsModal.tsx'
import c4 from './components-modals-exercise-update-modal'
import c5 from './components-modals-ExerciseMakersModal.tsx'
import c6 from './components-modals-ExerciseUpdateModal.tsx'
import c7 from './components-modals-mentor'
import c8 from './components-modals-mentor-registration-modal'
import c9 from './components-modals-mentor-registration-modal-commit-step'
import da from './components-modals-MentorChangeTracksModal.tsx'
import db from './components-modals-MentorRegistrationModal.tsx'
import dc from './components-modals-PreviousMentoringSessionsModal.tsx'
import dd from './components-modals-profile'
import de from './components-modals-PublishSolutionModal.tsx'
import df from './components-modals-realtime-feedback-modal'
import dg from './components-modals-realtime-feedback-modal-components'
import dh from './components-modals-realtime-feedback-modal-feedback-content'
import di from './components-modals-realtime-feedback-modal-feedback-content-found-automated-feedback'
import dj from './components-modals-realtime-feedback-modal-feedback-content-no-automated-feedback'
import dk from './components-modals-RequestMentoringModal.tsx'
import dl from './components-modals-ResetAccountModal.tsx'
import dm from './components-modals-seniority-survey-modal'
import dn from './components-modals-student'
import dp from './components-modals-student-finish-mentor-discussion-modal'
import dq from './components-modals-TaskHintsModal.tsx'
import dr from './components-modals-TestimonialModal.tsx'
import ds from './components-modals-track-welcome-modal-LHS'
import dt from './components-modals-track-welcome-modal-LHS-steps'
import du from './components-modals-track-welcome-modal-LHS-steps-components'
import dv from './components-modals-track-welcome-modal-RHS'
import dw from './components-modals-UnpublishSolutionModal.tsx'
import dx from './components-modals-upload-video'
import dy from './components-modals-upload-video-elements'
import dz from './components-modals-welcome-modal'
import d0 from './components-modals-WelcomeToInsidersModal.tsx'
import d1 from './components-notifications-'
import d2 from './components-notifications-notifications-list'
import d3 from './components-perks'
import d4 from './components-profile'
import d5 from './components-profile-avatar-selector'
import d6 from './components-profile-avatar-selector-cropping-modal'
import d7 from './components-profile-avatar-selector-photo'
import d8 from './components-profile-community-solutions-list'
import d9 from './components-profile-contributions-list'
import ea from './components-profile-contributions-summary'
import eb from './components-profile-testimonials-list'
import ec from './components-settings-BootcampAffiliateCouponForm.tsx'
import ed from './components-settings-BootcampFreeCouponForm.tsx'
import ee from './components-settings-comments-preference-form'
import ef from './components-settings-CommunicationPreferencesForm.tsx'
import eg from './components-settings-delete-profile-form'
import eh from './components-settings-DeleteAccountButton.tsx'
import ei from './components-settings-DeleteProfileForm.tsx'
import ej from './components-settings-EmailForm.tsx'
import ek from './components-settings-FormMessage.tsx'
import el from './components-settings-github-syncer-common'
import em from './components-settings-github-syncer-sections-ConnectedSection'
import en from './components-settings-github-syncer-sections-ConnectedSection-ManualSyncSection.tsx'
import eo from './components-settings-github-syncer-sections-ConnectedSection-SyncBehaviourSection.tsx'
import ep from './components-settings-HandleForm.tsx'
import eq from './components-settings-InsiderBenefitsForm.tsx'
import er from './components-settings-PasswordForm.tsx'
import es from './components-settings-PhotoForm.tsx'
import et from './components-settings-ProfileForm.tsx'
import eu from './components-settings-PronounsForm.tsx'
import ev from './components-settings-ResetAccountButton.tsx'
import ew from './components-settings-ShowOnSupportersPageButton.tsx'
import ex from './components-settings-theme-preference-form'
import ey from './components-settings-ThemePreferenceForm.tsx'
import ez from './components-settings-TokenForm.tsx'
import e0 from './components-settings-useInvalidField.tsx'
import e1 from './components-settings-UserPreferencesForm.tsx'
import e2 from './components-settings-useSettingsMutation.tsx'
import e3 from './components-student-CompleteExerciseButton.tsx'
import e4 from './components-student-ExerciseList.tsx'
import e5 from './components-student-ExerciseStatusChart.tsx'
import e6 from './components-student-ExerciseStatusDot.tsx'
import e7 from './components-student-iterations-list'
import e8 from './components-student-mentoring-dropdown'
import e9 from './components-student-mentoring-session'
import fa from './components-student-mentoring-session-iteration-view'
import fb from './components-student-mentoring-session-mentoring-request'
import fc from './components-student-mentoring-session-mentoring-request-MentoringRequestFormComponents'
import fd from './components-student-MentoringComboButton.tsx'
import fe from './components-student-MentoringSession.tsx'
import ff from './components-student-open-editor-button'
import fg from './components-student-OpenEditorButton.tsx'
import fh from './components-student-published-solution'
import fi from './components-student-PublishSolutionButton.tsx'
import fj from './components-student-RequestMentoringButton.tsx'
import fk from './components-student-solution-summary'
import fl from './components-student-tracks-list'
import fm from './components-student-TracksList.tsx'
import fn from './components-student-UpdateExerciseNotice.tsx'
import fo from './components-test'
import fp from './components-tooltips-ExerciseTooltip.tsx'
import fq from './components-tooltips-studentTooltip'
import fr from './components-tooltips-task-tooltip'
import fs from './components-track-activity-ticker'
import ft from './components-track-build-analyzer-tags'
import fu from './components-track-dig-deeper-components'
import fv from './components-track-dig-deeper-components-community-videos'
import fw from './components-track-dig-deeper-components-no-content-yet'
import fx from './components-track-exercise-community-solutions-list'
import fy from './components-track-ExerciseCommunitySolutionsList.tsx'
import fz from './components-track-iteration-summary'
import f0 from './components-track-IterationSummary.tsx'
import f1 from './components-track-Trophies.tsx'
import f2 from './components-track-UnlockHelpButton.tsx'
import f3 from './components-training-data-code-tagger'
import f4 from './components-training-data-dashboard'
import f5 from './discussion-batch'
import f6 from './session-batch-1'
import f7 from './session-batch-2'
import f8 from './session-batch-3'

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
  'components/common/markdown-editor-form': av,
  'components/common/share-panel': aw,
  'components/community': ax,
  'components/community-solutions': ay,
  'components/concept-map': az,
  'components/contributing': a0,
  'components/contributing/tasks-list/task': a1,
  'components/donations': a2,
  'components/donations/subscription-form': a3,
  'components/dropdowns': a4,
  'components/dropdowns/reputation': a5,
  'components/dropdowns/track-menu': a6,
  'components/editor/ChatGptFeedback': a7,
  'components/editor/EditorStatusSummary.tsx': a8,
  'components/editor/FeedbackPanel': a9,
  'components/editor/GetHelp': ba,
  'components/editor/header': bb,
  'components/editor/legacy-file-banner': bc,
  'components/editor/LegacyFileBanner.tsx': bd,
  'components/editor/panels': be,
  'components/editor/RunTestsButton.tsx': bf,
  'components/editor/SubmitButton.tsx': bg,
  'components/editor/tabs': bh,
  'components/editor/testComponents': bi,
  'components/github-syncer-widget': bj,
  'components/impact/ImpactTestimonial.tsx': bk,
  'components/impact/TopLearningCountries.tsx': bl,
  'components/insiders': bm,
  'components/journey': bn,
  'components/journey/badges-list': bo,
  'components/journey/contribution-results': bp,
  'components/journey/contributions-list': bq,
  'components/journey/overview': br,
  'components/journey/overview/badges-section': bs,
  'components/journey/overview/contributing-section': bt,
  'components/journey/overview/learning-section': bu,
  'components/journey/overview/mentoring-section': bv,
  'components/journey/solutions-list': bw,
  'components/maintaining': bx,
  'components/mentoring/automation/AutomationListElement.tsx': by,
  'components/mentoring/automation/Representation.tsx': bz,
  'components/mentoring/automation/RepresentationList.tsx': b0,
  'components/mentoring/discussion/discussion-post': b1,
  'components/mentoring/discussion/finished-wizard': b2,
  'components/mentoring/discussion/FinishedWizard.tsx': b3,
  'components/mentoring/discussion/MarkAsNothingToDoButton.tsx': b4,
  'components/mentoring/discussion/NewMessageAlert.tsx': b5,
  'components/mentoring/inbox': b6,
  'components/mentoring/Inboxtsx': b7,
  'components/mentoring/queue': b8,
  'components/mentoring/Queuetsx': b9,
  'components/mentoring/representation/common': ca,
  'components/mentoring/representation/left-pane': cb,
  'components/mentoring/representation/modals': cc,
  'components/mentoring/representation/right-pane': cd,
  'components/mentoring/representation/right-pane/RadioGroup.tsx': ce,
  'components/mentoring/request/locked-solution-mentoring-note': cf,
  'components/mentoring/request/StartMentoringPanel.tsx': cg,
  'components/mentoring/Session.tsx': ch,
  'components/mentoring/session/favorite-button': ci,
  'components/mentoring/session/iteration-view': cj,
  'components/mentoring/session/mobile-code-panel/MobileIterationView.tsx': ck,
  'components/mentoring/session/mobile-code-panel/SessionInfoModal.tsx': cl,
  'components/mentoring/session/Scratchpad.tsx': cm,
  'components/mentoring/session/SessionInfo.tsx': cn,
  'components/mentoring/session/student-info': co,
  'components/mentoring/session/StudentInfo.tsx': cp,
  'components/mentoring/testimonials-list': cq,
  'components/mentoring/testimonials-list/revealed-testimonial': cr,
  'components/mentoring/TestimonialsList.tsx': cs,
  'components/mentoring/track-selector': ct,
  'components/modals/BadgeModal.tsx': cu,
  'components/modals/BegModal.tsx': cv,
  'components/modals/BugReportModal.tsx': cw,
  'components/modals/ChangePublishedIterationModal.tsx': cx,
  'components/modals/complete-exercise-modal': cy,
  'components/modals/complete-exercise-modal/exercise-completed-modal/Unlocks.tsx':
    cz,
  'components/modals/ConceptMakersModal.tsx': c0,
  'components/modals/DeleteAccountModal.tsx': c1,
  'components/modals/DisableSolutionCommentsModal.tsx': c2,
  'components/modals/EnableSolutionCommentsModal.tsx': c3,
  'components/modals/exercise-update-modal': c4,
  'components/modals/ExerciseMakersModal.tsx': c5,
  'components/modals/ExerciseUpdateModal.tsx': c6,
  'components/modals/mentor': c7,
  'components/modals/mentor-registration-modal': c8,
  'components/modals/mentor-registration-modal/commit-step': c9,
  'components/modals/MentorChangeTracksModal.tsx': da,
  'components/modals/MentorRegistrationModal.tsx': db,
  'components/modals/PreviousMentoringSessionsModal.tsx': dc,
  'components/modals/profile': dd,
  'components/modals/PublishSolutionModal.tsx': de,
  'components/modals/realtime-feedback-modal': df,
  'components/modals/realtime-feedback-modal/components': dg,
  'components/modals/realtime-feedback-modal/feedback-content': dh,
  'components/modals/realtime-feedback-modal/feedback-content/found-automated-feedback':
    di,
  'components/modals/realtime-feedback-modal/feedback-content/no-automated-feedback':
    dj,
  'components/modals/RequestMentoringModal.tsx': dk,
  'components/modals/ResetAccountModal.tsx': dl,
  'components/modals/seniority-survey-modal': dm,
  'components/modals/student': dn,
  'components/modals/student/finish-mentor-discussion-modal': dp,
  'components/modals/TaskHintsModal.tsx': dq,
  'components/modals/TestimonialModal.tsx': dr,
  'components/modals/track-welcome-modal/LHS': ds,
  'components/modals/track-welcome-modal/LHS/steps': dt,
  'components/modals/track-welcome-modal/LHS/steps/components': du,
  'components/modals/track-welcome-modal/RHS': dv,
  'components/modals/UnpublishSolutionModal.tsx': dw,
  'components/modals/upload-video': dx,
  'components/modals/upload-video/elements': dy,
  'components/modals/welcome-modal': dz,
  'components/modals/WelcomeToInsidersModal.tsx': d0,
  'components/notifications/': d1,
  'components/notifications/notifications-list': d2,
  'components/perks': d3,
  'components/profile': d4,
  'components/profile/avatar-selector': d5,
  'components/profile/avatar-selector/cropping-modal': d6,
  'components/profile/avatar-selector/photo': d7,
  'components/profile/community-solutions-list': d8,
  'components/profile/contributions-list': d9,
  'components/profile/contributions-summary': ea,
  'components/profile/testimonials-list': eb,
  'components/settings/BootcampAffiliateCouponForm.tsx': ec,
  'components/settings/BootcampFreeCouponForm.tsx': ed,
  'components/settings/comments-preference-form': ee,
  'components/settings/CommunicationPreferencesForm.tsx': ef,
  'components/settings/delete-profile-form': eg,
  'components/settings/DeleteAccountButton.tsx': eh,
  'components/settings/DeleteProfileForm.tsx': ei,
  'components/settings/EmailForm.tsx': ej,
  'components/settings/FormMessage.tsx': ek,
  'components/settings/github-syncer/common': el,
  'components/settings/github-syncer/sections/ConnectedSection': em,
  'components/settings/github-syncer/sections/ConnectedSection/ManualSyncSection.tsx':
    en,
  'components/settings/github-syncer/sections/ConnectedSection/SyncBehaviourSection.tsx':
    eo,
  'components/settings/HandleForm.tsx': ep,
  'components/settings/InsiderBenefitsForm.tsx': eq,
  'components/settings/PasswordForm.tsx': er,
  'components/settings/PhotoForm.tsx': es,
  'components/settings/ProfileForm.tsx': et,
  'components/settings/PronounsForm.tsx': eu,
  'components/settings/ResetAccountButton.tsx': ev,
  'components/settings/ShowOnSupportersPageButton.tsx': ew,
  'components/settings/theme-preference-form': ex,
  'components/settings/ThemePreferenceForm.tsx': ey,
  'components/settings/TokenForm.tsx': ez,
  'components/settings/useInvalidField.tsx': e0,
  'components/settings/UserPreferencesForm.tsx': e1,
  'components/settings/useSettingsMutation.tsx': e2,
  'components/student/CompleteExerciseButton.tsx': e3,
  'components/student/ExerciseList.tsx': e4,
  'components/student/ExerciseStatusChart.tsx': e5,
  'components/student/ExerciseStatusDot.tsx': e6,
  'components/student/iterations-list': e7,
  'components/student/mentoring-dropdown': e8,
  'components/student/mentoring-session': e9,
  'components/student/mentoring-session/iteration-view': fa,
  'components/student/mentoring-session/mentoring-request': fb,
  'components/student/mentoring-session/mentoring-request/MentoringRequestFormComponents':
    fc,
  'components/student/MentoringComboButton.tsx': fd,
  'components/student/MentoringSession.tsx': fe,
  'components/student/open-editor-button': ff,
  'components/student/OpenEditorButton.tsx': fg,
  'components/student/published-solution': fh,
  'components/student/PublishSolutionButton.tsx': fi,
  'components/student/RequestMentoringButton.tsx': fj,
  'components/student/solution-summary': fk,
  'components/student/tracks-list': fl,
  'components/student/TracksList.tsx': fm,
  'components/student/UpdateExerciseNotice.tsx': fn,
  'components/test': fo,
  'components/tooltips/ExerciseTooltip.tsx': fp,
  'components/tooltips/student-tooltip': fq,
  'components/tooltips/task-tooltip': fr,
  'components/track/activity-ticker': fs,
  'components/track/build/analyzer-tags': ft,
  'components/track/dig-deeper-components': fu,
  'components/track/dig-deeper-components/community-videos': fv,
  'components/track/dig-deeper-components/no-content-yet': fw,
  'components/track/exercise-community-solutions-list': fx,
  'components/track/ExerciseCommunitySolutionsList.tsx': fy,
  'components/track/iteration-summary': fz,
  'components/track/IterationSummary.tsx': f0,
  'components/track/Trophies.tsx': f1,
  'components/track/UnlockHelpButton.tsx': f2,
  'components/training-data/code-tagger': f3,
  'components/training-data/dashboard': f4,
  'discussion-batch': f5,
  'session-batch-1': f6,
  'session-batch-2': f7,
  'session-batch-3': f8,
}
