import aa from './automation-batch'
import ab from './components-common-CLIWalkthroughButton.tsx'
import ac from './components-common-ComboButton.tsx'
import ad from './components-common-CommunitySolution.tsx'
import ae from './components-common-CopyToClipboardButton.tsx'
import af from './components-common-Credits.tsx'
import ag from './components-common-exercise-widget'
import ah from './components-common-ExerciseIcon.tsx'
import ai from './components-common-HandleWithFlair.tsx'
import aj from './components-common-Introducer.tsx'
import ak from './components-common-Loading.tsx'
import al from './components-common-markdown-editor-form'
import am from './components-common-MarkdownEditor.tsx'
import an from './components-common-MarkdownEditorForm.tsx'
import ao from './components-common-MedianWaitTime.tsx'
import ap from './components-common-MentorDiscussionSummary.tsx'
import aq from './components-common-MultipleSelect.tsx'
import ar from './components-common-Pagination.tsx'
import as from './components-common-ProcessingStatusSummary.tsx'
import at from './components-common-ProminentLink.tsx'
import au from './components-common-Pronouns.tsx'
import av from './components-common-Reputation.tsx'
import aw from './components-common-share-panel'
import ax from './components-common-ShareButton.tsx'
import ay from './components-common-ShareLink.tsx'
import az from './components-common-SingleSelect.tsx'
import a0 from './components-common-site-updates-list-PullRequestWidget.tsx'
import a1 from './components-common-ThemeToggleButton.tsx'
import a2 from './components-common-TrackIcon.tsx'
import a3 from './components-community'
import a4 from './components-community-solutions'
import a5 from './components-concept-map'
import a6 from './components-contributing'
import a7 from './components-contributing-tasks-list-task'
import a8 from './components-donations'
import a9 from './components-donations-stripe-form-useStripeForm.ts'
import ba from './components-donations-subscription-form'
import bb from './components-dropdowns'
import bc from './components-dropdowns-notifications'
import bd from './components-dropdowns-reputation'
import be from './components-dropdowns-track-menu'
import bf from './components-Editor.tsx'
import bg from './components-editor-AssistantChat'
import bh from './components-editor-AssistantChat-useTurnstile.ts'
import bi from './components-editor-EditorStatusSummary.tsx'
import bj from './components-editor-FeedbackPanel'
import bk from './components-editor-GetHelp'
import bl from './components-editor-header'
import bm from './components-editor-legacy-file-banner'
import bn from './components-editor-LegacyFileBanner.tsx'
import bo from './components-editor-panels'
import bp from './components-editor-RunTestsButton.tsx'
import bq from './components-editor-SubmitButton.tsx'
import br from './components-editor-tabs'
import bs from './components-editor-testComponents'
import bt from './components-ErrorBoundary.tsx'
import bu from './components-favorites-list'
import bv from './components-github-syncer-widget'
import bw from './components-impact-chart-elements'
import bx from './components-impact-ImpactTestimonial.tsx'
import by from './components-impact-map.tsx'
import bz from './components-impact-TopLearningCountries.tsx'
import b0 from './components-insiders'
import b1 from './components-journey'
import b2 from './components-journey-badges-list'
import b3 from './components-journey-contribution-results'
import b4 from './components-journey-contributions-list'
import b5 from './components-journey-overview'
import b6 from './components-journey-overview-badges-section'
import b7 from './components-journey-overview-contributing-section'
import b8 from './components-journey-overview-learning-section'
import b9 from './components-journey-overview-learning-section-track-summary-TrackProgressBar.tsx'
import ca from './components-journey-overview-mentoring-section'
import cb from './components-journey-overview-TrackHeaderSummaryText.tsx'
import cc from './components-journey-solutions-list'
import cd from './components-journey-UnrevealedBadge.tsx'
import ce from './components-maintaining'
import cf from './components-mentoring-automation-AutomationListElement.tsx'
import cg from './components-mentoring-automation-Representation.tsx'
import ch from './components-mentoring-automation-RepresentationList.tsx'
import ci from './components-mentoring-automation-TrackFilterList.tsx'
import cj from './components-mentoring-discussion-discussion-post'
import ck from './components-mentoring-discussion-DiscussionDetails.tsx'
import cl from './components-mentoring-discussion-DiscussionPostList.tsx'
import cm from './components-mentoring-discussion-finished-wizard'
import cn from './components-mentoring-discussion-FinishedWizard.tsx'
import co from './components-mentoring-discussion-MarkAsNothingToDoButton.tsx'
import cp from './components-mentoring-discussion-NewMessageAlert.tsx'
import cq from './components-mentoring-inbox'
import cr from './components-mentoring-Inboxtsx'
import cs from './components-mentoring-queue'
import ct from './components-mentoring-Queuetsx'
import cu from './components-mentoring-representation-common'
import cv from './components-mentoring-representation-left-pane'
import cw from './components-mentoring-representation-modals'
import cx from './components-mentoring-representation-right-pane'
import cy from './components-mentoring-representation-right-pane-MentoringConversation.tsx'
import cz from './components-mentoring-representation-right-pane-RadioGroup.tsx'
import c0 from './components-mentoring-request-locked-solution-mentoring-note'
import c1 from './components-mentoring-request-StartMentoringPanel.tsx'
import c2 from './components-mentoring-Session.tsx'
import c3 from './components-mentoring-session-CloseButton.tsx'
import c4 from './components-mentoring-session-favorite-button'
import c5 from './components-mentoring-session-iteration-view'
import c6 from './components-mentoring-session-mobile-code-panel-MobileIterationView.tsx'
import c7 from './components-mentoring-session-mobile-code-panel-SessionInfoHamburgerButton.tsx'
import c8 from './components-mentoring-session-mobile-code-panel-SessionInfoModal.tsx'
import c9 from './components-mentoring-session-Scratchpad.tsx'
import da from './components-mentoring-session-SessionInfo.tsx'
import db from './components-mentoring-session-student-info'
import dc from './components-mentoring-session-StudentInfo.tsx'
import dd from './components-mentoring-testimonials-list'
import de from './components-mentoring-testimonials-list-revealed-testimonial'
import df from './components-mentoring-TestimonialsList.tsx'
import dg from './components-mentoring-track-selector'
import dh from './components-modals-BadgeModal.tsx'
import di from './components-modals-BegModal.tsx'
import dj from './components-modals-BugReportModal.tsx'
import dk from './components-modals-ChangePublishedIterationModal.tsx'
import dl from './components-modals-complete-exercise-modal'
import dm from './components-modals-complete-exercise-modal-exercise-completed-modal-Unlocks.tsx'
import dn from './components-modals-ConceptMakersModal.tsx'
import dp from './components-modals-DeleteAccountModal.tsx'
import dq from './components-modals-DisableSolutionCommentsModal.tsx'
import dr from './components-modals-EnableSolutionCommentsModal.tsx'
import ds from './components-modals-exercise-update-modal'
import dt from './components-modals-ExerciseMakersModal.tsx'
import du from './components-modals-ExerciseUpdateModal.tsx'
import dv from './components-modals-mentor'
import dw from './components-modals-mentor-registration-modal'
import dx from './components-modals-mentor-registration-modal-commit-step'
import dy from './components-modals-MentorChangeTracksModal.tsx'
import dz from './components-modals-MentorRegistrationModal.tsx'
import d0 from './components-modals-Modal.tsx'
import d1 from './components-modals-PreviousMentoringSessionsModal.tsx'
import d2 from './components-modals-profile'
import d3 from './components-modals-PublishSolutionModal.tsx'
import d4 from './components-modals-realtime-feedback-modal'
import d5 from './components-modals-realtime-feedback-modal-components'
import d6 from './components-modals-realtime-feedback-modal-feedback-content'
import d7 from './components-modals-realtime-feedback-modal-feedback-content-found-automated-feedback'
import d8 from './components-modals-realtime-feedback-modal-feedback-content-no-automated-feedback'
import d9 from './components-modals-RequestMentoringModal.tsx'
import ea from './components-modals-ResetAccountModal.tsx'
import eb from './components-modals-seniority-survey-modal'
import ec from './components-modals-student'
import ed from './components-modals-student-finish-mentor-discussion-modal'
import ee from './components-modals-TaskHintsModal.tsx'
import ef from './components-modals-TestimonialModal.tsx'
import eg from './components-modals-track-welcome-modal-LHS'
import eh from './components-modals-track-welcome-modal-LHS-steps'
import ei from './components-modals-track-welcome-modal-LHS-steps-components'
import ej from './components-modals-track-welcome-modal-RHS'
import ek from './components-modals-UnpublishSolutionModal.tsx'
import el from './components-modals-upload-video'
import em from './components-modals-upload-video-elements'
import en from './components-modals-welcome-modal'
import eo from './components-modals-WelcomeToInsidersModal.tsx'
import ep from './components-notifications-'
import eq from './components-notifications-notifications-list'
import er from './components-perks'
import es from './components-profile'
import et from './components-profile-avatar-selector'
import eu from './components-profile-avatar-selector-cropping-modal'
import ev from './components-profile-avatar-selector-photo'
import ew from './components-profile-community-solutions-list'
import ex from './components-profile-contributions-list'
import ey from './components-profile-contributions-summary'
import ez from './components-profile-testimonials-list'
import e0 from './components-ResultsZone.tsx'
import e1 from './components-settings-BootcampAffiliateCouponForm.tsx'
import e2 from './components-settings-BootcampFreeCouponForm.tsx'
import e3 from './components-settings-comments-preference-form'
import e4 from './components-settings-CommunicationPreferencesForm.tsx'
import e5 from './components-settings-delete-profile-form'
import e6 from './components-settings-DeleteAccountButton.tsx'
import e7 from './components-settings-DeleteProfileForm.tsx'
import e8 from './components-settings-EmailForm.tsx'
import e9 from './components-settings-FormMessage.tsx'
import fa from './components-settings-github-syncer-common'
import fb from './components-settings-github-syncer-sections-ConnectedSection'
import fc from './components-settings-github-syncer-sections-ConnectedSection-ManualSyncSection.tsx'
import fd from './components-settings-github-syncer-sections-ConnectedSection-SyncBehaviourSection.tsx'
import fe from './components-settings-github-syncer-sections-ConnectToGithubSection'
import ff from './components-settings-HandleForm.tsx'
import fg from './components-settings-InsiderBenefitsForm.tsx'
import fh from './components-settings-LanguagePreferenceForm.tsx'
import fi from './components-settings-PasswordForm.tsx'
import fj from './components-settings-PhotoForm.tsx'
import fk from './components-settings-ProfileForm.tsx'
import fl from './components-settings-PronounsForm.tsx'
import fm from './components-settings-ResetAccountButton.tsx'
import fn from './components-settings-ShowOnSupportersPageButton.tsx'
import fo from './components-settings-theme-preference-form'
import fp from './components-settings-ThemePreferenceForm.tsx'
import fq from './components-settings-TokenForm.tsx'
import fr from './components-settings-useInvalidField.tsx'
import fs from './components-settings-UserPreferencesForm.tsx'
import ft from './components-settings-useSettingsMutation.tsx'
import fu from './components-student-CompleteExerciseButton.tsx'
import fv from './components-student-ExerciseList.tsx'
import fw from './components-student-ExerciseStatusChart.tsx'
import fx from './components-student-ExerciseStatusDot.tsx'
import fy from './components-student-iterations-list'
import fz from './components-student-mentoring-dropdown'
import f0 from './components-student-mentoring-session'
import f1 from './components-student-mentoring-session-iteration-view'
import f2 from './components-student-mentoring-session-mentoring-request'
import f3 from './components-student-mentoring-session-mentoring-request-MentoringRequestFormComponents'
import f4 from './components-student-MentoringComboButton.tsx'
import f5 from './components-student-MentoringSession.tsx'
import f6 from './components-student-open-editor-button'
import f7 from './components-student-OpenEditorButton.tsx'
import f8 from './components-student-published-solution'
import f9 from './components-student-PublishSolutionButton.tsx'
import ga from './components-student-RequestMentoringButton.tsx'
import gb from './components-student-solution-summary'
import gc from './components-student-tracks-list'
import gd from './components-student-TracksList.tsx'
import ge from './components-student-UpdateExerciseNotice.tsx'
import gf from './components-test'
import gg from './components-tooltips-AutomationLockedTooltip.tsx'
import gh from './components-tooltips-ConceptTooltip.tsx'
import gi from './components-tooltips-ExerciseTooltip.tsx'
import gj from './components-tooltips-studentTooltip'
import gk from './components-tooltips-task-tooltip'
import gl from './components-tooltips-ToolingTooltip.tsx'
import gm from './components-tooltips-UserTooltip.tsx'
import gn from './components-track'
import go from './components-track-activity-ticker'
import gp from './components-track-dig-deeper-components'
import gq from './components-track-dig-deeper-components-community-videos'
import gr from './components-track-dig-deeper-components-no-content-yet'
import gs from './components-track-exercise-community-solutions-list'
import gt from './components-track-ExerciseCommunitySolutionsList.tsx'
import gu from './components-track-iteration-summary'
import gv from './components-track-IterationSummary.tsx'
import gw from './components-track-Trophies.tsx'
import gx from './components-track-UnlockHelpButton.tsx'
import gy from './components-training-data-code-tagger'
import gz from './components-training-data-dashboard'
import g0 from './discussion-batch'
import g1 from './session-batch-1'
import g2 from './session-batch-2'
import g3 from './session-batch-3'
import g4 from './utils-date'

export default {
  'automation-batch': aa,
  'components/common/CLIWalkthroughButton.tsx': ab,
  'components/common/ComboButton.tsx': ac,
  'components/common/CommunitySolution.tsx': ad,
  'components/common/CopyToClipboardButton.tsx': ae,
  'components/common/Credits.tsx': af,
  'components/common/exercise-widget': ag,
  'components/common/ExerciseIcon.tsx': ah,
  'components/common/HandleWithFlair.tsx': ai,
  'components/common/Introducer.tsx': aj,
  'components/common/Loading.tsx': ak,
  'components/common/markdown-editor-form': al,
  'components/common/MarkdownEditor.tsx': am,
  'components/common/MarkdownEditorForm.tsx': an,
  'components/common/MedianWaitTime.tsx': ao,
  'components/common/MentorDiscussionSummary.tsx': ap,
  'components/common/MultipleSelect.tsx': aq,
  'components/common/Pagination.tsx': ar,
  'components/common/ProcessingStatusSummary.tsx': as,
  'components/common/ProminentLink.tsx': at,
  'components/common/Pronouns.tsx': au,
  'components/common/Reputation.tsx': av,
  'components/common/share-panel': aw,
  'components/common/ShareButton.tsx': ax,
  'components/common/ShareLink.tsx': ay,
  'components/common/SingleSelect.tsx': az,
  'components/common/site-updates-list/PullRequestWidget.tsx': a0,
  'components/common/ThemeToggleButton.tsx': a1,
  'components/common/TrackIcon.tsx': a2,
  'components/community': a3,
  'components/community-solutions': a4,
  'components/concept-map': a5,
  'components/contributing': a6,
  'components/contributing/tasks-list/task': a7,
  'components/donations': a8,
  'components/donations/stripe-form/useStripeForm.ts': a9,
  'components/donations/subscription-form': ba,
  'components/dropdowns': bb,
  'components/dropdowns/notifications': bc,
  'components/dropdowns/reputation': bd,
  'components/dropdowns/track-menu': be,
  'components/Editor.tsx': bf,
  'components/editor/AssistantChat': bg,
  'components/editor/AssistantChat/useTurnstile.ts': bh,
  'components/editor/EditorStatusSummary.tsx': bi,
  'components/editor/FeedbackPanel': bj,
  'components/editor/GetHelp': bk,
  'components/editor/header': bl,
  'components/editor/legacy-file-banner': bm,
  'components/editor/LegacyFileBanner.tsx': bn,
  'components/editor/panels': bo,
  'components/editor/RunTestsButton.tsx': bp,
  'components/editor/SubmitButton.tsx': bq,
  'components/editor/tabs': br,
  'components/editor/testComponents': bs,
  'components/ErrorBoundary.tsx': bt,
  'components/favorites-list': bu,
  'components/github-syncer-widget': bv,
  'components/impact/chart-elements': bw,
  'components/impact/ImpactTestimonial.tsx': bx,
  'components/impact/map.tsx': by,
  'components/impact/TopLearningCountries.tsx': bz,
  'components/insiders': b0,
  'components/journey': b1,
  'components/journey/badges-list': b2,
  'components/journey/contribution-results': b3,
  'components/journey/contributions-list': b4,
  'components/journey/overview': b5,
  'components/journey/overview/badges-section': b6,
  'components/journey/overview/contributing-section': b7,
  'components/journey/overview/learning-section': b8,
  'components/journey/overview/learning-section/track-summary/TrackProgressBar.tsx':
    b9,
  'components/journey/overview/mentoring-section': ca,
  'components/journey/overview/TrackHeaderSummaryText.tsx': cb,
  'components/journey/solutions-list': cc,
  'components/journey/UnrevealedBadge.tsx': cd,
  'components/maintaining': ce,
  'components/mentoring/automation/AutomationListElement.tsx': cf,
  'components/mentoring/automation/Representation.tsx': cg,
  'components/mentoring/automation/RepresentationList.tsx': ch,
  'components/mentoring/automation/TrackFilterList.tsx': ci,
  'components/mentoring/discussion/discussion-post': cj,
  'components/mentoring/discussion/DiscussionDetails.tsx': ck,
  'components/mentoring/discussion/DiscussionPostList.tsx': cl,
  'components/mentoring/discussion/finished-wizard': cm,
  'components/mentoring/discussion/FinishedWizard.tsx': cn,
  'components/mentoring/discussion/MarkAsNothingToDoButton.tsx': co,
  'components/mentoring/discussion/NewMessageAlert.tsx': cp,
  'components/mentoring/inbox': cq,
  'components/mentoring/Inboxtsx': cr,
  'components/mentoring/queue': cs,
  'components/mentoring/Queuetsx': ct,
  'components/mentoring/representation/common': cu,
  'components/mentoring/representation/left-pane': cv,
  'components/mentoring/representation/modals': cw,
  'components/mentoring/representation/right-pane': cx,
  'components/mentoring/representation/right-pane/MentoringConversation.tsx':
    cy,
  'components/mentoring/representation/right-pane/RadioGroup.tsx': cz,
  'components/mentoring/request/locked-solution-mentoring-note': c0,
  'components/mentoring/request/StartMentoringPanel.tsx': c1,
  'components/mentoring/Session.tsx': c2,
  'components/mentoring/session/CloseButton.tsx': c3,
  'components/mentoring/session/favorite-button': c4,
  'components/mentoring/session/iteration-view': c5,
  'components/mentoring/session/mobile-code-panel/MobileIterationView.tsx': c6,
  'components/mentoring/session/mobile-code-panel/SessionInfoHamburgerButton.tsx':
    c7,
  'components/mentoring/session/mobile-code-panel/SessionInfoModal.tsx': c8,
  'components/mentoring/session/Scratchpad.tsx': c9,
  'components/mentoring/session/SessionInfo.tsx': da,
  'components/mentoring/session/student-info': db,
  'components/mentoring/session/StudentInfo.tsx': dc,
  'components/mentoring/testimonials-list': dd,
  'components/mentoring/testimonials-list/revealed-testimonial': de,
  'components/mentoring/TestimonialsList.tsx': df,
  'components/mentoring/track-selector': dg,
  'components/modals/BadgeModal.tsx': dh,
  'components/modals/BegModal.tsx': di,
  'components/modals/BugReportModal.tsx': dj,
  'components/modals/ChangePublishedIterationModal.tsx': dk,
  'components/modals/complete-exercise-modal': dl,
  'components/modals/complete-exercise-modal/exercise-completed-modal/Unlocks.tsx':
    dm,
  'components/modals/ConceptMakersModal.tsx': dn,
  'components/modals/DeleteAccountModal.tsx': dp,
  'components/modals/DisableSolutionCommentsModal.tsx': dq,
  'components/modals/EnableSolutionCommentsModal.tsx': dr,
  'components/modals/exercise-update-modal': ds,
  'components/modals/ExerciseMakersModal.tsx': dt,
  'components/modals/ExerciseUpdateModal.tsx': du,
  'components/modals/mentor': dv,
  'components/modals/mentor-registration-modal': dw,
  'components/modals/mentor-registration-modal/commit-step': dx,
  'components/modals/MentorChangeTracksModal.tsx': dy,
  'components/modals/MentorRegistrationModal.tsx': dz,
  'components/modals/Modal.tsx': d0,
  'components/modals/PreviousMentoringSessionsModal.tsx': d1,
  'components/modals/profile': d2,
  'components/modals/PublishSolutionModal.tsx': d3,
  'components/modals/realtime-feedback-modal': d4,
  'components/modals/realtime-feedback-modal/components': d5,
  'components/modals/realtime-feedback-modal/feedback-content': d6,
  'components/modals/realtime-feedback-modal/feedback-content/found-automated-feedback':
    d7,
  'components/modals/realtime-feedback-modal/feedback-content/no-automated-feedback':
    d8,
  'components/modals/RequestMentoringModal.tsx': d9,
  'components/modals/ResetAccountModal.tsx': ea,
  'components/modals/seniority-survey-modal': eb,
  'components/modals/student': ec,
  'components/modals/student/finish-mentor-discussion-modal': ed,
  'components/modals/TaskHintsModal.tsx': ee,
  'components/modals/TestimonialModal.tsx': ef,
  'components/modals/track-welcome-modal/LHS': eg,
  'components/modals/track-welcome-modal/LHS/steps': eh,
  'components/modals/track-welcome-modal/LHS/steps/components': ei,
  'components/modals/track-welcome-modal/RHS': ej,
  'components/modals/UnpublishSolutionModal.tsx': ek,
  'components/modals/upload-video': el,
  'components/modals/upload-video/elements': em,
  'components/modals/welcome-modal': en,
  'components/modals/WelcomeToInsidersModal.tsx': eo,
  'components/notifications/': ep,
  'components/notifications/notifications-list': eq,
  'components/perks': er,
  'components/profile': es,
  'components/profile/avatar-selector': et,
  'components/profile/avatar-selector/cropping-modal': eu,
  'components/profile/avatar-selector/photo': ev,
  'components/profile/community-solutions-list': ew,
  'components/profile/contributions-list': ex,
  'components/profile/contributions-summary': ey,
  'components/profile/testimonials-list': ez,
  'components/ResultsZone.tsx': e0,
  'components/settings/BootcampAffiliateCouponForm.tsx': e1,
  'components/settings/BootcampFreeCouponForm.tsx': e2,
  'components/settings/comments-preference-form': e3,
  'components/settings/CommunicationPreferencesForm.tsx': e4,
  'components/settings/delete-profile-form': e5,
  'components/settings/DeleteAccountButton.tsx': e6,
  'components/settings/DeleteProfileForm.tsx': e7,
  'components/settings/EmailForm.tsx': e8,
  'components/settings/FormMessage.tsx': e9,
  'components/settings/github-syncer/common': fa,
  'components/settings/github-syncer/sections/ConnectedSection': fb,
  'components/settings/github-syncer/sections/ConnectedSection/ManualSyncSection.tsx':
    fc,
  'components/settings/github-syncer/sections/ConnectedSection/SyncBehaviourSection.tsx':
    fd,
  'components/settings/github-syncer/sections/ConnectToGithubSection': fe,
  'components/settings/HandleForm.tsx': ff,
  'components/settings/InsiderBenefitsForm.tsx': fg,
  'components/settings/LanguagePreferenceForm.tsx': fh,
  'components/settings/PasswordForm.tsx': fi,
  'components/settings/PhotoForm.tsx': fj,
  'components/settings/ProfileForm.tsx': fk,
  'components/settings/PronounsForm.tsx': fl,
  'components/settings/ResetAccountButton.tsx': fm,
  'components/settings/ShowOnSupportersPageButton.tsx': fn,
  'components/settings/theme-preference-form': fo,
  'components/settings/ThemePreferenceForm.tsx': fp,
  'components/settings/TokenForm.tsx': fq,
  'components/settings/useInvalidField.tsx': fr,
  'components/settings/UserPreferencesForm.tsx': fs,
  'components/settings/useSettingsMutation.tsx': ft,
  'components/student/CompleteExerciseButton.tsx': fu,
  'components/student/ExerciseList.tsx': fv,
  'components/student/ExerciseStatusChart.tsx': fw,
  'components/student/ExerciseStatusDot.tsx': fx,
  'components/student/iterations-list': fy,
  'components/student/mentoring-dropdown': fz,
  'components/student/mentoring-session': f0,
  'components/student/mentoring-session/iteration-view': f1,
  'components/student/mentoring-session/mentoring-request': f2,
  'components/student/mentoring-session/mentoring-request/MentoringRequestFormComponents':
    f3,
  'components/student/MentoringComboButton.tsx': f4,
  'components/student/MentoringSession.tsx': f5,
  'components/student/open-editor-button': f6,
  'components/student/OpenEditorButton.tsx': f7,
  'components/student/published-solution': f8,
  'components/student/PublishSolutionButton.tsx': f9,
  'components/student/RequestMentoringButton.tsx': ga,
  'components/student/solution-summary': gb,
  'components/student/tracks-list': gc,
  'components/student/TracksList.tsx': gd,
  'components/student/UpdateExerciseNotice.tsx': ge,
  'components/test': gf,
  'components/tooltips/AutomationLockedTooltip.tsx': gg,
  'components/tooltips/ConceptTooltip.tsx': gh,
  'components/tooltips/ExerciseTooltip.tsx': gi,
  'components/tooltips/student-tooltip': gj,
  'components/tooltips/task-tooltip': gk,
  'components/tooltips/ToolingTooltip.tsx': gl,
  'components/tooltips/UserTooltip.tsx': gm,
  'components/track': gn,
  'components/track/activity-ticker': go,
  'components/track/dig-deeper-components': gp,
  'components/track/dig-deeper-components/community-videos': gq,
  'components/track/dig-deeper-components/no-content-yet': gr,
  'components/track/exercise-community-solutions-list': gs,
  'components/track/ExerciseCommunitySolutionsList.tsx': gt,
  'components/track/iteration-summary': gu,
  'components/track/IterationSummary.tsx': gv,
  'components/track/Trophies.tsx': gw,
  'components/track/UnlockHelpButton.tsx': gx,
  'components/training-data/code-tagger': gy,
  'components/training-data/dashboard': gz,
  'discussion-batch': g0,
  'session-batch-1': g1,
  'session-batch-2': g2,
  'session-batch-3': g3,
  'utils/date': g4,
}
