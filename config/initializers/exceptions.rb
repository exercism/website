class BadgeCriteriaNotFulfilledError < RuntimeError; end

class TrophyCriteriaNotFulfilledError < RuntimeError; end

class TrainerCriteriaNotFulfilledError < RuntimeError; end

class DuplicateSubmissionError < RuntimeError; end

class DuplicateVideoError < RuntimeError; end

class ExerciseLockedError < RuntimeError; end

class InvalidTrackSlugsError < RuntimeError
  attr_reader :track_slugs

  def initialize(track_slugs)
    super("Some track slugs were invalid")
    @track_slugs = track_slugs
  end
end

class MissingTracksError < RuntimeError; end

class SubmissionFileTooLargeError < RuntimeError; end

class SolutionHasNoIterationsError < RuntimeError; end

class SolutionLockedByAnotherMentorError < RuntimeError; end

class SolutionCannotBeUnlockedError < RuntimeError; end

class MentorSolutionLockLimitReachedError < RuntimeError; end

class StudentCannotMentorThemselvesError < RuntimeError; end

class SolutionNotFoundError < RuntimeError; end

class TooManyIterationsError < RuntimeError; end

class TrackHasCyclicPrerequisiteError < RuntimeError; end

class TrackSearchStatusWithoutUserError < RuntimeError; end

class TrackSearchInvalidStatusError < RuntimeError; end

class UserTrackNotFoundError < RuntimeError; end

class ReputationTokenLevelUndefined < RuntimeError; end

class ReputationTokenReasonInvalid < RuntimeError; end

class ReputationTokenCategoryInvalid < RuntimeError; end

class NoMentoringSlotsAvailableError < RuntimeError; end

class ProfileCriteriaNotFulfilledError < RuntimeError; end

class MissingMetricPeriodError < RuntimeError; end

class InvalidMetricPeriodError < RuntimeError; end

class InvalidMetricTypeError < RuntimeError; end

class InvalidCommunityVideoUrlError < RuntimeError; end

class ChatGPTTooManyRequestsError < RuntimeError; end

class NoPublishedSolutionForRepresentationError < RuntimeError; end

class RequestLockHasExpired < RuntimeError; end

class InvalidDiscussionStatusError < RuntimeError; end

class TrainingDataCodeTagsSampleLockedError < RuntimeError; end
