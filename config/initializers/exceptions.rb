class BadgeCriteriaNotFulfilledError < RuntimeError; end
class DuplicateSubmissionError < RuntimeError; end
class ExerciseUnavailableError < RuntimeError; end
class SubmissionFileTooLargeError < RuntimeError; end
class SolutionLockedByAnotherMentorError < RuntimeError; end
class TooManySubmissionsError < RuntimeError; end
class TrackSearchStatusWithoutUserError < RuntimeError; end
class TrackSearchInvalidStatusError < RuntimeError; end
