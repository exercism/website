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
import av from './components-common-Loading.tsx'
import aw from './components-common-markdown-editor-form'
import ax from './components-common-MarkdownEditor.tsx'
import ay from './components-common-MarkdownEditorForm.tsx'
import az from './components-common-share-panel'
import a0 from './components-community'
import a1 from './components-community-solutions'
import a2 from './components-concept-map'
import a3 from './components-contributing'
import a4 from './components-contributing-tasks-list-task'
import a5 from './components-donations'
import a6 from './components-donations-subscription-form'
import a7 from './components-dropdowns'
import a8 from './components-dropdowns-reputation'
import a9 from './components-dropdowns-track-menu'
import ba from './components-editor-ChatGptFeedback'
import bb from './components-editor-EditorStatusSummary.tsx'
import bc from './components-editor-FeedbackPanel'
import bd from './components-editor-GetHelp'
import be from './components-editor-header'
import bf from './components-editor-legacy-file-banner'
import bg from './components-editor-LegacyFileBanner.tsx'
import bh from './components-editor-panels'
import bi from './components-editor-RunTestsButton.tsx'
import bj from './components-editor-SubmitButton.tsx'
import bk from './components-editor-tabs'
import bl from './components-editor-testComponents'
import bm from './components-github-syncer-widget'
import bn from './components-impact-ImpactTestimonial.tsx'
import bo from './components-impact-TopLearningCountries.tsx'
import bp from './components-insiders'
import bq from './components-journey'
import br from './components-journey-badges-list'
import bs from './components-journey-contribution-results'
import bt from './components-journey-contributions-list'
import bu from './components-journey-overview'
import bv from './components-journey-overview-badges-section'
import bw from './components-journey-overview-contributing-section'
import bx from './components-journey-overview-learning-section'
import by from './components-journey-overview-mentoring-section'
import bz from './components-journey-solutions-list'
import b0 from './components-maintaining'
import b1 from './components-mentoring-automation-AutomationListElement.tsx'
import b2 from './components-mentoring-automation-Representation.tsx'
import b3 from './components-mentoring-automation-RepresentationList.tsx'
import b4 from './components-mentoring-discussion-discussion-post'
import b5 from './components-mentoring-discussion-finished-wizard'
import b6 from './components-mentoring-discussion-FinishedWizard.tsx'
import b7 from './components-mentoring-discussion-MarkAsNothingToDoButton.tsx'
import b8 from './components-mentoring-discussion-NewMessageAlert.tsx'
import b9 from './components-mentoring-inbox'
import ca from './components-mentoring-Inboxtsx'
import cb from './components-mentoring-queue'
import cc from './components-mentoring-Queuetsx'
import cd from './components-mentoring-representation-common'
import ce from './components-mentoring-representation-left-pane'
import cf from './components-mentoring-representation-modals'
import cg from './components-mentoring-representation-right-pane'
import ch from './components-mentoring-representation-right-pane-RadioGroup.tsx'
import ci from './components-mentoring-request-locked-solution-mentoring-note'
import cj from './components-mentoring-request-StartMentoringPanel.tsx'
import ck from './components-mentoring-Session.tsx'
import cl from './components-mentoring-session-favorite-button'
import cm from './components-mentoring-session-iteration-view'
import cn from './components-mentoring-session-mobile-code-panel-MobileIterationView.tsx'
import co from './components-mentoring-session-mobile-code-panel-SessionInfoModal.tsx'
import cp from './components-mentoring-session-Scratchpad.tsx'
import cq from './components-mentoring-session-SessionInfo.tsx'
import cr from './components-mentoring-session-student-info'
import cs from './components-mentoring-session-StudentInfo.tsx'
import ct from './components-mentoring-testimonials-list'
import cu from './components-mentoring-testimonials-list-revealed-testimonial'
import cv from './components-mentoring-TestimonialsList.tsx'
import cw from './components-mentoring-track-selector'
import cx from './components-modals-BadgeModal.tsx'
import cy from './components-modals-BegModal.tsx'
import cz from './components-modals-BugReportModal.tsx'
import c0 from './components-modals-ChangePublishedIterationModal.tsx'
import c1 from './components-modals-complete-exercise-modal'
import c2 from './components-modals-complete-exercise-modal-exercise-completed-modal-Unlocks.tsx'
import c3 from './components-modals-ConceptMakersModal.tsx'
import c4 from './components-modals-DeleteAccountModal.tsx'
import c5 from './components-modals-DisableSolutionCommentsModal.tsx'
import c6 from './components-modals-EnableSolutionCommentsModal.tsx'
import c7 from './components-modals-exercise-update-modal'
import c8 from './components-modals-ExerciseMakersModal.tsx'
import c9 from './components-modals-ExerciseUpdateModal.tsx'
import da from './components-modals-mentor'
import db from './components-modals-mentor-registration-modal'
import dc from './components-modals-mentor-registration-modal-commit-step'
import dd from './components-modals-MentorChangeTracksModal.tsx'
import de from './components-modals-MentorRegistrationModal.tsx'
import df from './components-modals-PreviousMentoringSessionsModal.tsx'
import dg from './components-modals-profile'
import dh from './components-modals-PublishSolutionModal.tsx'
import di from './components-modals-realtime-feedback-modal'
import dj from './components-modals-realtime-feedback-modal-components'
import dk from './components-modals-realtime-feedback-modal-feedback-content'
import dl from './components-modals-realtime-feedback-modal-feedback-content-found-automated-feedback'
import dm from './components-modals-realtime-feedback-modal-feedback-content-no-automated-feedback'
import dn from './components-modals-RequestMentoringModal.tsx'
import dp from './components-modals-ResetAccountModal.tsx'
import dq from './components-modals-seniority-survey-modal'
import dr from './components-modals-student'
import ds from './components-modals-student-finish-mentor-discussion-modal'
import dt from './components-modals-TaskHintsModal.tsx'
import du from './components-modals-TestimonialModal.tsx'
import dv from './components-modals-track-welcome-modal-LHS'
import dw from './components-modals-track-welcome-modal-LHS-steps'
import dx from './components-modals-track-welcome-modal-LHS-steps-components'
import dy from './components-modals-track-welcome-modal-RHS'
import dz from './components-modals-UnpublishSolutionModal.tsx'
import d0 from './components-modals-upload-video'
import d1 from './components-modals-upload-video-elements'
import d2 from './components-modals-welcome-modal'
import d3 from './components-modals-WelcomeToInsidersModal.tsx'
import d4 from './components-notifications-'
import d5 from './components-notifications-notifications-list'
import d6 from './components-perks'
import d7 from './components-profile'
import d8 from './components-profile-avatar-selector'
import d9 from './components-profile-avatar-selector-cropping-modal'
import ea from './components-profile-avatar-selector-photo'
import eb from './components-profile-community-solutions-list'
import ec from './components-profile-contributions-list'
import ed from './components-profile-contributions-summary'
import ee from './components-profile-testimonials-list'
import ef from './components-settings-BootcampAffiliateCouponForm.tsx'
import eg from './components-settings-BootcampFreeCouponForm.tsx'
import eh from './components-settings-comments-preference-form'
import ei from './components-settings-CommunicationPreferencesForm.tsx'
import ej from './components-settings-delete-profile-form'
import ek from './components-settings-DeleteAccountButton.tsx'
import el from './components-settings-DeleteProfileForm.tsx'
import em from './components-settings-EmailForm.tsx'
import en from './components-settings-FormMessage.tsx'
import eo from './components-settings-github-syncer-common'
import ep from './components-settings-github-syncer-sections-ConnectedSection'
import eq from './components-settings-github-syncer-sections-ConnectedSection-ManualSyncSection.tsx'
import er from './components-settings-github-syncer-sections-ConnectedSection-SyncBehaviourSection.tsx'
import es from './components-settings-HandleForm.tsx'
import et from './components-settings-InsiderBenefitsForm.tsx'
import eu from './components-settings-PasswordForm.tsx'
import ev from './components-settings-PhotoForm.tsx'
import ew from './components-settings-ProfileForm.tsx'
import ex from './components-settings-PronounsForm.tsx'
import ey from './components-settings-ResetAccountButton.tsx'
import ez from './components-settings-ShowOnSupportersPageButton.tsx'
import e0 from './components-settings-theme-preference-form'
import e1 from './components-settings-ThemePreferenceForm.tsx'
import e2 from './components-settings-TokenForm.tsx'
import e3 from './components-settings-useInvalidField.tsx'
import e4 from './components-settings-UserPreferencesForm.tsx'
import e5 from './components-settings-useSettingsMutation.tsx'
import e6 from './components-student-CompleteExerciseButton.tsx'
import e7 from './components-student-ExerciseList.tsx'
import e8 from './components-student-ExerciseStatusChart.tsx'
import e9 from './components-student-ExerciseStatusDot.tsx'
import fa from './components-student-iterations-list'
import fb from './components-student-mentoring-dropdown'
import fc from './components-student-mentoring-session'
import fd from './components-student-mentoring-session-iteration-view'
import fe from './components-student-mentoring-session-mentoring-request'
import ff from './components-student-mentoring-session-mentoring-request-MentoringRequestFormComponents'
import fg from './components-student-MentoringComboButton.tsx'
import fh from './components-student-MentoringSession.tsx'
import fi from './components-student-open-editor-button'
import fj from './components-student-OpenEditorButton.tsx'
import fk from './components-student-published-solution'
import fl from './components-student-PublishSolutionButton.tsx'
import fm from './components-student-RequestMentoringButton.tsx'
import fn from './components-student-solution-summary'
import fo from './components-student-tracks-list'
import fp from './components-student-TracksList.tsx'
import fq from './components-student-UpdateExerciseNotice.tsx'
import fr from './components-test'
import fs from './components-tooltips-ExerciseTooltip.tsx'
import ft from './components-tooltips-studentTooltip'
import fu from './components-tooltips-task-tooltip'
import fv from './components-track-activity-ticker'
import fw from './components-track-build-analyzer-tags'
import fx from './components-track-dig-deeper-components'
import fy from './components-track-dig-deeper-components-community-videos'
import fz from './components-track-dig-deeper-components-no-content-yet'
import f0 from './components-track-exercise-community-solutions-list'
import f1 from './components-track-ExerciseCommunitySolutionsList.tsx'
import f2 from './components-track-iteration-summary'
import f3 from './components-track-IterationSummary.tsx'
import f4 from './components-track-Trophies.tsx'
import f5 from './components-track-UnlockHelpButton.tsx'
import f6 from './components-training-data-code-tagger'
import f7 from './components-training-data-dashboard'
import f8 from './discussion-batch'
import f9 from './session-batch-1'
import ga from './session-batch-2'
import gb from './session-batch-3'

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
  'components/common/Loading.tsx': av,
  'components/common/markdown-editor-form': aw,
  'components/common/MarkdownEditor.tsx': ax,
  'components/common/MarkdownEditorForm.tsx': ay,
  'components/common/share-panel': az,
  'components/community': a0,
  'components/community-solutions': a1,
  'components/concept-map': a2,
  'components/contributing': a3,
  'components/contributing/tasks-list/task': a4,
  'components/donations': a5,
  'components/donations/subscription-form': a6,
  'components/dropdowns': a7,
  'components/dropdowns/reputation': a8,
  'components/dropdowns/track-menu': a9,
  'components/editor/ChatGptFeedback': ba,
  'components/editor/EditorStatusSummary.tsx': bb,
  'components/editor/FeedbackPanel': bc,
  'components/editor/GetHelp': bd,
  'components/editor/header': be,
  'components/editor/legacy-file-banner': bf,
  'components/editor/LegacyFileBanner.tsx': bg,
  'components/editor/panels': bh,
  'components/editor/RunTestsButton.tsx': bi,
  'components/editor/SubmitButton.tsx': bj,
  'components/editor/tabs': bk,
  'components/editor/testComponents': bl,
  'components/github-syncer-widget': bm,
  'components/impact/ImpactTestimonial.tsx': bn,
  'components/impact/TopLearningCountries.tsx': bo,
  'components/insiders': bp,
  'components/journey': bq,
  'components/journey/badges-list': br,
  'components/journey/contribution-results': bs,
  'components/journey/contributions-list': bt,
  'components/journey/overview': bu,
  'components/journey/overview/badges-section': bv,
  'components/journey/overview/contributing-section': bw,
  'components/journey/overview/learning-section': bx,
  'components/journey/overview/mentoring-section': by,
  'components/journey/solutions-list': bz,
  'components/maintaining': b0,
  'components/mentoring/automation/AutomationListElement.tsx': b1,
  'components/mentoring/automation/Representation.tsx': b2,
  'components/mentoring/automation/RepresentationList.tsx': b3,
  'components/mentoring/discussion/discussion-post': b4,
  'components/mentoring/discussion/finished-wizard': b5,
  'components/mentoring/discussion/FinishedWizard.tsx': b6,
  'components/mentoring/discussion/MarkAsNothingToDoButton.tsx': b7,
  'components/mentoring/discussion/NewMessageAlert.tsx': b8,
  'components/mentoring/inbox': b9,
  'components/mentoring/Inboxtsx': ca,
  'components/mentoring/queue': cb,
  'components/mentoring/Queuetsx': cc,
  'components/mentoring/representation/common': cd,
  'components/mentoring/representation/left-pane': ce,
  'components/mentoring/representation/modals': cf,
  'components/mentoring/representation/right-pane': cg,
  'components/mentoring/representation/right-pane/RadioGroup.tsx': ch,
  'components/mentoring/request/locked-solution-mentoring-note': ci,
  'components/mentoring/request/StartMentoringPanel.tsx': cj,
  'components/mentoring/Session.tsx': ck,
  'components/mentoring/session/favorite-button': cl,
  'components/mentoring/session/iteration-view': cm,
  'components/mentoring/session/mobile-code-panel/MobileIterationView.tsx': cn,
  'components/mentoring/session/mobile-code-panel/SessionInfoModal.tsx': co,
  'components/mentoring/session/Scratchpad.tsx': cp,
  'components/mentoring/session/SessionInfo.tsx': cq,
  'components/mentoring/session/student-info': cr,
  'components/mentoring/session/StudentInfo.tsx': cs,
  'components/mentoring/testimonials-list': ct,
  'components/mentoring/testimonials-list/revealed-testimonial': cu,
  'components/mentoring/TestimonialsList.tsx': cv,
  'components/mentoring/track-selector': cw,
  'components/modals/BadgeModal.tsx': cx,
  'components/modals/BegModal.tsx': cy,
  'components/modals/BugReportModal.tsx': cz,
  'components/modals/ChangePublishedIterationModal.tsx': c0,
  'components/modals/complete-exercise-modal': c1,
  'components/modals/complete-exercise-modal/exercise-completed-modal/Unlocks.tsx':
    c2,
  'components/modals/ConceptMakersModal.tsx': c3,
  'components/modals/DeleteAccountModal.tsx': c4,
  'components/modals/DisableSolutionCommentsModal.tsx': c5,
  'components/modals/EnableSolutionCommentsModal.tsx': c6,
  'components/modals/exercise-update-modal': c7,
  'components/modals/ExerciseMakersModal.tsx': c8,
  'components/modals/ExerciseUpdateModal.tsx': c9,
  'components/modals/mentor': da,
  'components/modals/mentor-registration-modal': db,
  'components/modals/mentor-registration-modal/commit-step': dc,
  'components/modals/MentorChangeTracksModal.tsx': dd,
  'components/modals/MentorRegistrationModal.tsx': de,
  'components/modals/PreviousMentoringSessionsModal.tsx': df,
  'components/modals/profile': dg,
  'components/modals/PublishSolutionModal.tsx': dh,
  'components/modals/realtime-feedback-modal': di,
  'components/modals/realtime-feedback-modal/components': dj,
  'components/modals/realtime-feedback-modal/feedback-content': dk,
  'components/modals/realtime-feedback-modal/feedback-content/found-automated-feedback':
    dl,
  'components/modals/realtime-feedback-modal/feedback-content/no-automated-feedback':
    dm,
  'components/modals/RequestMentoringModal.tsx': dn,
  'components/modals/ResetAccountModal.tsx': dp,
  'components/modals/seniority-survey-modal': dq,
  'components/modals/student': dr,
  'components/modals/student/finish-mentor-discussion-modal': ds,
  'components/modals/TaskHintsModal.tsx': dt,
  'components/modals/TestimonialModal.tsx': du,
  'components/modals/track-welcome-modal/LHS': dv,
  'components/modals/track-welcome-modal/LHS/steps': dw,
  'components/modals/track-welcome-modal/LHS/steps/components': dx,
  'components/modals/track-welcome-modal/RHS': dy,
  'components/modals/UnpublishSolutionModal.tsx': dz,
  'components/modals/upload-video': d0,
  'components/modals/upload-video/elements': d1,
  'components/modals/welcome-modal': d2,
  'components/modals/WelcomeToInsidersModal.tsx': d3,
  'components/notifications/': d4,
  'components/notifications/notifications-list': d5,
  'components/perks': d6,
  'components/profile': d7,
  'components/profile/avatar-selector': d8,
  'components/profile/avatar-selector/cropping-modal': d9,
  'components/profile/avatar-selector/photo': ea,
  'components/profile/community-solutions-list': eb,
  'components/profile/contributions-list': ec,
  'components/profile/contributions-summary': ed,
  'components/profile/testimonials-list': ee,
  'components/settings/BootcampAffiliateCouponForm.tsx': ef,
  'components/settings/BootcampFreeCouponForm.tsx': eg,
  'components/settings/comments-preference-form': eh,
  'components/settings/CommunicationPreferencesForm.tsx': ei,
  'components/settings/delete-profile-form': ej,
  'components/settings/DeleteAccountButton.tsx': ek,
  'components/settings/DeleteProfileForm.tsx': el,
  'components/settings/EmailForm.tsx': em,
  'components/settings/FormMessage.tsx': en,
  'components/settings/github-syncer/common': eo,
  'components/settings/github-syncer/sections/ConnectedSection': ep,
  'components/settings/github-syncer/sections/ConnectedSection/ManualSyncSection.tsx':
    eq,
  'components/settings/github-syncer/sections/ConnectedSection/SyncBehaviourSection.tsx':
    er,
  'components/settings/HandleForm.tsx': es,
  'components/settings/InsiderBenefitsForm.tsx': et,
  'components/settings/PasswordForm.tsx': eu,
  'components/settings/PhotoForm.tsx': ev,
  'components/settings/ProfileForm.tsx': ew,
  'components/settings/PronounsForm.tsx': ex,
  'components/settings/ResetAccountButton.tsx': ey,
  'components/settings/ShowOnSupportersPageButton.tsx': ez,
  'components/settings/theme-preference-form': e0,
  'components/settings/ThemePreferenceForm.tsx': e1,
  'components/settings/TokenForm.tsx': e2,
  'components/settings/useInvalidField.tsx': e3,
  'components/settings/UserPreferencesForm.tsx': e4,
  'components/settings/useSettingsMutation.tsx': e5,
  'components/student/CompleteExerciseButton.tsx': e6,
  'components/student/ExerciseList.tsx': e7,
  'components/student/ExerciseStatusChart.tsx': e8,
  'components/student/ExerciseStatusDot.tsx': e9,
  'components/student/iterations-list': fa,
  'components/student/mentoring-dropdown': fb,
  'components/student/mentoring-session': fc,
  'components/student/mentoring-session/iteration-view': fd,
  'components/student/mentoring-session/mentoring-request': fe,
  'components/student/mentoring-session/mentoring-request/MentoringRequestFormComponents':
    ff,
  'components/student/MentoringComboButton.tsx': fg,
  'components/student/MentoringSession.tsx': fh,
  'components/student/open-editor-button': fi,
  'components/student/OpenEditorButton.tsx': fj,
  'components/student/published-solution': fk,
  'components/student/PublishSolutionButton.tsx': fl,
  'components/student/RequestMentoringButton.tsx': fm,
  'components/student/solution-summary': fn,
  'components/student/tracks-list': fo,
  'components/student/TracksList.tsx': fp,
  'components/student/UpdateExerciseNotice.tsx': fq,
  'components/test': fr,
  'components/tooltips/ExerciseTooltip.tsx': fs,
  'components/tooltips/student-tooltip': ft,
  'components/tooltips/task-tooltip': fu,
  'components/track/activity-ticker': fv,
  'components/track/build/analyzer-tags': fw,
  'components/track/dig-deeper-components': fx,
  'components/track/dig-deeper-components/community-videos': fy,
  'components/track/dig-deeper-components/no-content-yet': fz,
  'components/track/exercise-community-solutions-list': f0,
  'components/track/ExerciseCommunitySolutionsList.tsx': f1,
  'components/track/iteration-summary': f2,
  'components/track/IterationSummary.tsx': f3,
  'components/track/Trophies.tsx': f4,
  'components/track/UnlockHelpButton.tsx': f5,
  'components/training-data/code-tagger': f6,
  'components/training-data/dashboard': f7,
  'discussion-batch': f8,
  'session-batch-1': f9,
  'session-batch-2': ga,
  'session-batch-3': gb,
}
