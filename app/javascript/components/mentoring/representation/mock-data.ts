export const MOCK_REPRESENTATION_DATA = {
  student: {
    handle: 'alice',
    name: 'Alice',
    bio: null,
    location: null,
    languagesSpoken: ['english', 'spanish'],
    avatarUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
    reputation: '0',
    isFavorited: false,
    isBlocked: false,
    trackObjectives: 'get better',
    numTotalDiscussions: 1,
    numDiscussionsWithMentor: 1,
    links: {
      block: '/api/v2/mentoring/students/alice/block',
      favorite: '/api/v2/mentoring/students/alice/favorite',
      previousSessions:
        '/api/v2/mentoring/discussions?exclude_uuid=63b2c29073304a00b453c6d0e3dd0d31&status=all&student=alice',
    },
  },
  track: {
    slug: 'ruby',
    title: 'Ruby',
    highlightjsLanguage: 'ruby',
    indentSize: 2,
    medianWaitTime: null,
    iconUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg',
  },
  exercise: {
    slug: 'lasagna',
    title: 'Lasagna',
    iconUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/lasagna.svg',
    links: {
      self: '/tracks/ruby/exercises/lasagna',
    },
  },
}

export const MOCK_ITERATION_DATA = {
  iterations: [
    {
      uuid: 'a83c0631bc9943348425ea11595db094',
      submissionUuid: 'fce30fca58b7483f84de9e8d4d660230',
      idx: 1,
      status: 'no_automated_feedback',
      numEssentialAutomatedComments: 0,
      numActionableAutomatedComments: 0,
      numNonActionableAutomatedComments: 0,
      submissionMethod: 'api',
      createdAt: '2022-08-10T12:41:18Z',
      testsStatus: 'passed',
      isPublished: false,
      isLatest: true,
      links: {
        self: 'http://local.exercism.io:3020/tracks/ruby/exercises/lasagna/iterations?idx=1',
        automatedFeedback:
          'http://local.exercism.io:3020/api/v2/solutions/cc7eee710d3e4469be15867f7f898ea7/iterations/a83c0631bc9943348425ea11595db094/automated_feedback',
        delete:
          'http://local.exercism.io:3020/api/v2/solutions/cc7eee710d3e4469be15867f7f898ea7/iterations/a83c0631bc9943348425ea11595db094',
        solution: 'http://local.exercism.io:3020/tracks/ruby/exercises/lasagna',
        testRun:
          'http://local.exercism.io:3020/api/v2/solutions/cc7eee710d3e4469be15867f7f898ea7/submissions/fce30fca58b7483f84de9e8d4d660230/test_run',
        files:
          'http://local.exercism.io:3020/api/v2/solutions/cc7eee710d3e4469be15867f7f898ea7/submissions/fce30fca58b7483f84de9e8d4d660230/files',
      },
      unread: false,
    },
  ],
  instructions:
    '<p>In this exercise you\'re going to write some code to help you cook a brilliant lasagna from your favorite cooking book.</p>\n<p>You have four tasks, all related to the time spent cooking the lasagna.</p>\n<h3>1. Define the expected oven time in minutes</h3>\n<p>Define the <code>Lasagna::EXPECTED_MINUTES_IN_OVEN</code> constant that returns how many minutes the lasagna should be in the oven. According to the cooking book, the expected oven time in minutes is 40:</p>\n<pre><code class="language-ruby">Lasagna::EXPECTED_MINUTES_IN_OVEN\n# =&gt; 40\n</code></pre>\n<h3>2. Calculate the remaining oven time in minutes</h3>\n<p>Define the <code>Lasagna#remaining_minutes_in_oven</code> method that takes the actual minutes the lasagna has been in the oven as a parameter and returns how many minutes the lasagna still has to remain in the oven, based on the expected oven time in minutes from the previous task.</p>\n<pre><code class="language-ruby">lasagna = Lasagna.new\nlasagna.remaining_minutes_in_oven(30)\n# =&gt; 10\n</code></pre>\n<h3>3. Calculate the preparation time in minutes</h3>\n<p>Define the <code>Lasagna#preparation_time_in_minutes</code> method that takes the number of layers you added to the lasagna as a parameter and returns how many minutes you spent preparing the lasagna, assuming each layer takes you 2 minutes to prepare.</p>\n<pre><code class="language-ruby">lasagna = Lasagna.new\nlasagna.preparation_time_in_minutes(2)\n# =&gt; 4\n</code></pre>\n<h3>4. Calculate the total working time in minutes</h3>\n<p>Define the <code>Lasagna#total_time_in_minutes</code> method that takes two named parameters: the <code>number_of_layers</code> parameter is the number of layers you added to the lasagna, and the <code>actual_minutes_in_oven</code> parameter is the number of minutes the lasagna has been in the oven. The function should return how many minutes in total you\'ve worked on cooking the lasagna, which is the sum of the preparation time in minutes, and the time in minutes the lasagna has spent in the oven at the moment.</p>\n<pre><code class="language-ruby">lasagna = Lasagna.new\nlasagna.total_time_in_minutes(number_of_layers: 3, actual_minutes_in_oven: 20)\n# =&gt; 26\n</code></pre>\n',
  tests:
    "# frozen_string_literal: true\n\nrequire 'minitest/autorun'\nrequire_relative 'lasagna'\n\nclass LasagnaTest < Minitest::Test\n  def test_expected_minutes_in_oven\n    assert_equal 40, Lasagna::EXPECTED_MINUTES_IN_OVEN\n  end\n\n  def test_remaining_minutes_in_oven\n    assert_equal 15, Lasagna.new.remaining_minutes_in_oven(25)\n  end\n\n  def test_preparation_time_in_minutes_with_one_layer\n    assert_equal 2, Lasagna.new.preparation_time_in_minutes(1)\n  end\n\n  def test_preparation_time_in_minutes_with_multiple_layers\n    assert_equal 8, Lasagna.new.preparation_time_in_minutes(4)\n  end\n\n  def test_total_time_in_minutes_for_one_layer\n    assert_equal 32, Lasagna.new.total_time_in_minutes(\n      number_of_layers: 1,\n      actual_minutes_in_oven: 30\n    )\n  end\n\n  def test_total_time_in_minutes_for_multiple_layer\n    assert_equal 16, Lasagna.new.total_time_in_minutes(\n      number_of_layers: 4,\n      actual_minutes_in_oven: 8\n    )\n  end\nend\n",
  currentIteration: {
    uuid: 'a83c0631bc9943348425ea11595db094',
    submissionUuid: 'fce30fca58b7483f84de9e8d4d660230',
    idx: 1,
    status: 'no_automated_feedback',
    numEssentialAutomatedComments: 0,
    numActionableAutomatedComments: 0,
    numNonActionableAutomatedComments: 0,
    submissionMethod: 'api',
    createdAt: '2022-08-10T12:41:18Z',
    testsStatus: 'passed',
    isPublished: false,
    isLatest: true,
    links: {
      self: 'http://local.exercism.io:3020/tracks/ruby/exercises/lasagna/iterations?idx=1',
      automatedFeedback:
        'http://local.exercism.io:3020/api/v2/solutions/cc7eee710d3e4469be15867f7f898ea7/iterations/a83c0631bc9943348425ea11595db094/automated_feedback',
      delete:
        'http://local.exercism.io:3020/api/v2/solutions/cc7eee710d3e4469be15867f7f898ea7/iterations/a83c0631bc9943348425ea11595db094',
      solution: 'http://local.exercism.io:3020/tracks/ruby/exercises/lasagna',
      testRun:
        'http://local.exercism.io:3020/api/v2/solutions/cc7eee710d3e4469be15867f7f898ea7/submissions/fce30fca58b7483f84de9e8d4d660230/test_run',
      files:
        'http://local.exercism.io:3020/api/v2/solutions/cc7eee710d3e4469be15867f7f898ea7/submissions/fce30fca58b7483f84de9e8d4d660230/files',
    },
    unread: false,
  },
  language: 'ruby',
  indentSize: 2,
  isOutOfDate: false,
  isLinked: false,
  discussion: null,
  downloadCommand: 'exercism download --uuid=cc7eee710d3e4469be15867f7f898ea7',
}

export const GENERAL_ITERATION = {
  userHandle: 'alice',
  discussion: null,
  mentorSolution: {
    uuid: '5137779c65b34924b104fe7b6ad5d15c',
    snippet: null,
    numViews: 0,
    numStars: 0,
    numComments: 0,
    numIterations: 0,
    numLoc: null,
    iterationStatus: null,
    publishedIterationHeadTestsStatus: 'not_queued',
    publishedAt: null,
    isOutOfDate: false,
    language: 'ruby',
    author: {
      handle: 'alice',
      avatarUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
    },
    exercise: {
      title: 'Meetup',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/meetup.svg',
    },
    track: {
      title: 'Ruby',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg',
      highlightjsLanguage: 'ruby',
    },
    links: {
      publicUrl:
        'http://local.exercism.io:3020/tracks/ruby/exercises/meetup/solutions/alice',
      privateIterationsUrl:
        'http://local.exercism.io:3020/tracks/ruby/exercises/meetup/iterations',
    },
  },
  exemplarFiles: [],
  student: {
    handle: 'erikSchierboom',
    name: 'Erik Schierboom',
    bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best.",
    location: null,
    languagesSpoken: ['english', 'spanish'],
    avatarUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
    reputation: '2,986',
    isFavorited: false,
    isBlocked: false,
    trackObjectives: 'pleas',
    numTotalDiscussions: 0,
    numDiscussionsWithMentor: 0,
    links: {
      block: '/api/v2/mentoring/students/erikSchierboom/block',
      previousSessions:
        '/api/v2/mentoring/discussions?status=all&student=erikSchierboom',
    },
  },
  track: {
    slug: 'ruby',
    title: 'Ruby',
    highlightjsLanguage: 'ruby',
    indentSize: 2,
    medianWaitTime: null,
    iconUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg',
  },
  exercise: {
    slug: 'meetup',
    title: 'Meetup',
    iconUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/meetup.svg',
    links: {
      self: '/tracks/ruby/exercises/meetup',
    },
  },
  iterations: [
    {
      uuid: 'c47183f61ab34b93b064361a282df941',
      submissionUuid: '81421e93694148b3b3337b2d4b7a882c',
      idx: 1,
      status: 'no_automated_feedback',
      numEssentialAutomatedComments: 0,
      numActionableAutomatedComments: 0,
      numNonActionableAutomatedComments: 0,
      submissionMethod: 'api',
      createdAt: '2022-08-19T15:05:34Z',
      testsStatus: 'passed',
      isPublished: false,
      isLatest: true,
      links: {
        self: 'http://local.exercism.io:3020/tracks/ruby/exercises/meetup/iterations?idx=1',
        automatedFeedback:
          'http://local.exercism.io:3020/api/v2/solutions/c2a1818af2944372b35752385dc6082c/iterations/c47183f61ab34b93b064361a282df941/automated_feedback',
        delete:
          'http://local.exercism.io:3020/api/v2/solutions/c2a1818af2944372b35752385dc6082c/iterations/c47183f61ab34b93b064361a282df941',
        solution: 'http://local.exercism.io:3020/tracks/ruby/exercises/meetup',
        testRun:
          'http://local.exercism.io:3020/api/v2/solutions/c2a1818af2944372b35752385dc6082c/submissions/81421e93694148b3b3337b2d4b7a882c/test_run',
        files:
          'http://local.exercism.io:3020/api/v2/solutions/c2a1818af2944372b35752385dc6082c/submissions/81421e93694148b3b3337b2d4b7a882c/files',
      },
      unread: false,
    },
  ],
  instructions:
    '<p>Calculate the date of meetups.</p>\n<p>Typically meetups happen on the same day of the week.  In this exercise, you\nwill take a description of a meetup date, and return the actual meetup date.</p>\n<p>Examples of general descriptions are:</p>\n<ul>\n<li>The first Monday of January 2017</li>\n<li>The third Tuesday of January 2017</li>\n<li>The wednesteenth of January 2017</li>\n<li>The last Thursday of January 2017</li>\n</ul>\n<p>The descriptors you are expected to parse are:\nfirst, second, third, fourth, fifth, last, monteenth, tuesteenth, wednesteenth,\nthursteenth, friteenth, saturteenth, sunteenth</p>\n<p>Note that "monteenth", "tuesteenth", etc are all made up words. There was a\nmeetup whose members realized that there are exactly 7 numbered days in a month\nthat end in \'-teenth\'. Therefore, one is guaranteed that each day of the week\n(Monday, Tuesday, ...) will have exactly one date that is named with \'-teenth\'\nin every month.</p>\n<p>Given examples of meetup dates, each containing a month, day, year, and\ndescriptor calculate the date of the actual meetup.  For example, if given\n"The first Monday of January 2017", the correct meetup date is 2017/1/2.</p>\n',
  tests:
    'require \'minitest/autorun\'\nrequire_relative \'meetup\'\n\n# rubocop:disable Naming/VariableNumber\n\n# Common test data version: 1.1.0 56cdfa5\nclass MeetupTest < Minitest::Test\n  def test_monteenth_of_may_2013\n    # skip\n    meetup = Meetup.new(5, 2013).day(:monday, :teenth)\n    assert_equal Date.parse("2013-05-13"), meetup\n  end\n\n  def test_monteenth_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:monday, :teenth)\n    assert_equal Date.parse("2013-08-19"), meetup\n  end\n\n  def test_monteenth_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:monday, :teenth)\n    assert_equal Date.parse("2013-09-16"), meetup\n  end\n\n  def test_tuesteenth_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:tuesday, :teenth)\n    assert_equal Date.parse("2013-03-19"), meetup\n  end\n\n  def test_tuesteenth_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:tuesday, :teenth)\n    assert_equal Date.parse("2013-04-16"), meetup\n  end\n\n  def test_tuesteenth_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:tuesday, :teenth)\n    assert_equal Date.parse("2013-08-13"), meetup\n  end\n\n  def test_wednesteenth_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:wednesday, :teenth)\n    assert_equal Date.parse("2013-01-16"), meetup\n  end\n\n  def test_wednesteenth_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:wednesday, :teenth)\n    assert_equal Date.parse("2013-02-13"), meetup\n  end\n\n  def test_wednesteenth_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:wednesday, :teenth)\n    assert_equal Date.parse("2013-06-19"), meetup\n  end\n\n  def test_thursteenth_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:thursday, :teenth)\n    assert_equal Date.parse("2013-05-16"), meetup\n  end\n\n  def test_thursteenth_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:thursday, :teenth)\n    assert_equal Date.parse("2013-06-13"), meetup\n  end\n\n  def test_thursteenth_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :teenth)\n    assert_equal Date.parse("2013-09-19"), meetup\n  end\n\n  def test_friteenth_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:friday, :teenth)\n    assert_equal Date.parse("2013-04-19"), meetup\n  end\n\n  def test_friteenth_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:friday, :teenth)\n    assert_equal Date.parse("2013-08-16"), meetup\n  end\n\n  def test_friteenth_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:friday, :teenth)\n    assert_equal Date.parse("2013-09-13"), meetup\n  end\n\n  def test_saturteenth_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :teenth)\n    assert_equal Date.parse("2013-02-16"), meetup\n  end\n\n  def test_saturteenth_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:saturday, :teenth)\n    assert_equal Date.parse("2013-04-13"), meetup\n  end\n\n  def test_saturteenth_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:saturday, :teenth)\n    assert_equal Date.parse("2013-10-19"), meetup\n  end\n\n  def test_sunteenth_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:sunday, :teenth)\n    assert_equal Date.parse("2013-05-19"), meetup\n  end\n\n  def test_sunteenth_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:sunday, :teenth)\n    assert_equal Date.parse("2013-06-16"), meetup\n  end\n\n  def test_sunteenth_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:sunday, :teenth)\n    assert_equal Date.parse("2013-10-13"), meetup\n  end\n\n  def test_first_monday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:monday, :first)\n    assert_equal Date.parse("2013-03-04"), meetup\n  end\n\n  def test_first_monday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:monday, :first)\n    assert_equal Date.parse("2013-04-01"), meetup\n  end\n\n  def test_first_tuesday_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:tuesday, :first)\n    assert_equal Date.parse("2013-05-07"), meetup\n  end\n\n  def test_first_tuesday_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:tuesday, :first)\n    assert_equal Date.parse("2013-06-04"), meetup\n  end\n\n  def test_first_wednesday_of_july_2013\n    skip\n    meetup = Meetup.new(7, 2013).day(:wednesday, :first)\n    assert_equal Date.parse("2013-07-03"), meetup\n  end\n\n  def test_first_wednesday_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:wednesday, :first)\n    assert_equal Date.parse("2013-08-07"), meetup\n  end\n\n  def test_first_thursday_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :first)\n    assert_equal Date.parse("2013-09-05"), meetup\n  end\n\n  def test_first_thursday_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:thursday, :first)\n    assert_equal Date.parse("2013-10-03"), meetup\n  end\n\n  def test_first_friday_of_november_2013\n    skip\n    meetup = Meetup.new(11, 2013).day(:friday, :first)\n    assert_equal Date.parse("2013-11-01"), meetup\n  end\n\n  def test_first_friday_of_december_2013\n    skip\n    meetup = Meetup.new(12, 2013).day(:friday, :first)\n    assert_equal Date.parse("2013-12-06"), meetup\n  end\n\n  def test_first_saturday_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:saturday, :first)\n    assert_equal Date.parse("2013-01-05"), meetup\n  end\n\n  def test_first_saturday_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :first)\n    assert_equal Date.parse("2013-02-02"), meetup\n  end\n\n  def test_first_sunday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:sunday, :first)\n    assert_equal Date.parse("2013-03-03"), meetup\n  end\n\n  def test_first_sunday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:sunday, :first)\n    assert_equal Date.parse("2013-04-07"), meetup\n  end\n\n  def test_second_monday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:monday, :second)\n    assert_equal Date.parse("2013-03-11"), meetup\n  end\n\n  def test_second_monday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:monday, :second)\n    assert_equal Date.parse("2013-04-08"), meetup\n  end\n\n  def test_second_tuesday_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:tuesday, :second)\n    assert_equal Date.parse("2013-05-14"), meetup\n  end\n\n  def test_second_tuesday_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:tuesday, :second)\n    assert_equal Date.parse("2013-06-11"), meetup\n  end\n\n  def test_second_wednesday_of_july_2013\n    skip\n    meetup = Meetup.new(7, 2013).day(:wednesday, :second)\n    assert_equal Date.parse("2013-07-10"), meetup\n  end\n\n  def test_second_wednesday_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:wednesday, :second)\n    assert_equal Date.parse("2013-08-14"), meetup\n  end\n\n  def test_second_thursday_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :second)\n    assert_equal Date.parse("2013-09-12"), meetup\n  end\n\n  def test_second_thursday_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:thursday, :second)\n    assert_equal Date.parse("2013-10-10"), meetup\n  end\n\n  def test_second_friday_of_november_2013\n    skip\n    meetup = Meetup.new(11, 2013).day(:friday, :second)\n    assert_equal Date.parse("2013-11-08"), meetup\n  end\n\n  def test_second_friday_of_december_2013\n    skip\n    meetup = Meetup.new(12, 2013).day(:friday, :second)\n    assert_equal Date.parse("2013-12-13"), meetup\n  end\n\n  def test_second_saturday_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:saturday, :second)\n    assert_equal Date.parse("2013-01-12"), meetup\n  end\n\n  def test_second_saturday_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :second)\n    assert_equal Date.parse("2013-02-09"), meetup\n  end\n\n  def test_second_sunday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:sunday, :second)\n    assert_equal Date.parse("2013-03-10"), meetup\n  end\n\n  def test_second_sunday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:sunday, :second)\n    assert_equal Date.parse("2013-04-14"), meetup\n  end\n\n  def test_third_monday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:monday, :third)\n    assert_equal Date.parse("2013-03-18"), meetup\n  end\n\n  def test_third_monday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:monday, :third)\n    assert_equal Date.parse("2013-04-15"), meetup\n  end\n\n  def test_third_tuesday_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:tuesday, :third)\n    assert_equal Date.parse("2013-05-21"), meetup\n  end\n\n  def test_third_tuesday_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:tuesday, :third)\n    assert_equal Date.parse("2013-06-18"), meetup\n  end\n\n  def test_third_wednesday_of_july_2013\n    skip\n    meetup = Meetup.new(7, 2013).day(:wednesday, :third)\n    assert_equal Date.parse("2013-07-17"), meetup\n  end\n\n  def test_third_wednesday_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:wednesday, :third)\n    assert_equal Date.parse("2013-08-21"), meetup\n  end\n\n  def test_third_thursday_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :third)\n    assert_equal Date.parse("2013-09-19"), meetup\n  end\n\n  def test_third_thursday_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:thursday, :third)\n    assert_equal Date.parse("2013-10-17"), meetup\n  end\n\n  def test_third_friday_of_november_2013\n    skip\n    meetup = Meetup.new(11, 2013).day(:friday, :third)\n    assert_equal Date.parse("2013-11-15"), meetup\n  end\n\n  def test_third_friday_of_december_2013\n    skip\n    meetup = Meetup.new(12, 2013).day(:friday, :third)\n    assert_equal Date.parse("2013-12-20"), meetup\n  end\n\n  def test_third_saturday_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:saturday, :third)\n    assert_equal Date.parse("2013-01-19"), meetup\n  end\n\n  def test_third_saturday_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :third)\n    assert_equal Date.parse("2013-02-16"), meetup\n  end\n\n  def test_third_sunday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:sunday, :third)\n    assert_equal Date.parse("2013-03-17"), meetup\n  end\n\n  def test_third_sunday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:sunday, :third)\n    assert_equal Date.parse("2013-04-21"), meetup\n  end\n\n  def test_fourth_monday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:monday, :fourth)\n    assert_equal Date.parse("2013-03-25"), meetup\n  end\n\n  def test_fourth_monday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:monday, :fourth)\n    assert_equal Date.parse("2013-04-22"), meetup\n  end\n\n  def test_fourth_tuesday_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:tuesday, :fourth)\n    assert_equal Date.parse("2013-05-28"), meetup\n  end\n\n  def test_fourth_tuesday_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:tuesday, :fourth)\n    assert_equal Date.parse("2013-06-25"), meetup\n  end\n\n  def test_fourth_wednesday_of_july_2013\n    skip\n    meetup = Meetup.new(7, 2013).day(:wednesday, :fourth)\n    assert_equal Date.parse("2013-07-24"), meetup\n  end\n\n  def test_fourth_wednesday_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:wednesday, :fourth)\n    assert_equal Date.parse("2013-08-28"), meetup\n  end\n\n  def test_fourth_thursday_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :fourth)\n    assert_equal Date.parse("2013-09-26"), meetup\n  end\n\n  def test_fourth_thursday_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:thursday, :fourth)\n    assert_equal Date.parse("2013-10-24"), meetup\n  end\n\n  def test_fourth_friday_of_november_2013\n    skip\n    meetup = Meetup.new(11, 2013).day(:friday, :fourth)\n    assert_equal Date.parse("2013-11-22"), meetup\n  end\n\n  def test_fourth_friday_of_december_2013\n    skip\n    meetup = Meetup.new(12, 2013).day(:friday, :fourth)\n    assert_equal Date.parse("2013-12-27"), meetup\n  end\n\n  def test_fourth_saturday_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:saturday, :fourth)\n    assert_equal Date.parse("2013-01-26"), meetup\n  end\n\n  def test_fourth_saturday_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :fourth)\n    assert_equal Date.parse("2013-02-23"), meetup\n  end\n\n  def test_fourth_sunday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:sunday, :fourth)\n    assert_equal Date.parse("2013-03-24"), meetup\n  end\n\n  def test_fourth_sunday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:sunday, :fourth)\n    assert_equal Date.parse("2013-04-28"), meetup\n  end\n\n  def test_last_monday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:monday, :last)\n    assert_equal Date.parse("2013-03-25"), meetup\n  end\n\n  def test_last_monday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:monday, :last)\n    assert_equal Date.parse("2013-04-29"), meetup\n  end\n\n  def test_last_tuesday_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:tuesday, :last)\n    assert_equal Date.parse("2013-05-28"), meetup\n  end\n\n  def test_last_tuesday_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:tuesday, :last)\n    assert_equal Date.parse("2013-06-25"), meetup\n  end\n\n  def test_last_wednesday_of_july_2013\n    skip\n    meetup = Meetup.new(7, 2013).day(:wednesday, :last)\n    assert_equal Date.parse("2013-07-31"), meetup\n  end\n\n  def test_last_wednesday_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:wednesday, :last)\n    assert_equal Date.parse("2013-08-28"), meetup\n  end\n\n  def test_last_thursday_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :last)\n    assert_equal Date.parse("2013-09-26"), meetup\n  end\n\n  def test_last_thursday_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:thursday, :last)\n    assert_equal Date.parse("2013-10-31"), meetup\n  end\n\n  def test_last_friday_of_november_2013\n    skip\n    meetup = Meetup.new(11, 2013).day(:friday, :last)\n    assert_equal Date.parse("2013-11-29"), meetup\n  end\n\n  def test_last_friday_of_december_2013\n    skip\n    meetup = Meetup.new(12, 2013).day(:friday, :last)\n    assert_equal Date.parse("2013-12-27"), meetup\n  end\n\n  def test_last_saturday_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:saturday, :last)\n    assert_equal Date.parse("2013-01-26"), meetup\n  end\n\n  def test_last_saturday_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :last)\n    assert_equal Date.parse("2013-02-23"), meetup\n  end\n\n  def test_last_sunday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:sunday, :last)\n    assert_equal Date.parse("2013-03-31"), meetup\n  end\n\n  def test_last_sunday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:sunday, :last)\n    assert_equal Date.parse("2013-04-28"), meetup\n  end\n\n  def test_last_wednesday_of_february_2012\n    skip\n    meetup = Meetup.new(2, 2012).day(:wednesday, :last)\n    assert_equal Date.parse("2012-02-29"), meetup\n  end\n\n  def test_last_wednesday_of_december_2014\n    skip\n    meetup = Meetup.new(12, 2014).day(:wednesday, :last)\n    assert_equal Date.parse("2014-12-31"), meetup\n  end\n\n  def test_last_sunday_of_february_2015\n    skip\n    meetup = Meetup.new(2, 2015).day(:sunday, :last)\n    assert_equal Date.parse("2015-02-22"), meetup\n  end\n\n  def test_first_friday_of_december_2012\n    skip\n    meetup = Meetup.new(12, 2012).day(:friday, :first)\n    assert_equal Date.parse("2012-12-07"), meetup\n  end\n  # rubocop:enable Naming/VariableNumber\nend\n',
  links: {
    mentorDashboard: '/mentoring/inbox',
    exercise: '/tracks/ruby/exercises/meetup',
    improveNotes:
      'https://github.com/exercism/website-copy/new/main/tracks/ruby/exercises/meetup?filename=meetup/mentoring.md',
    mentoringDocs: '/docs/mentoring',
  },
  request: {
    uuid: '5f1c1d70f535445380bfdde6eabd486e',
    comment: {
      uuid: 'request-comment',
      iterationIdx: 1,
      authorHandle: 'erikSchierboom',
      authorAvatarUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
      byStudent: true,
      contentMarkdown: 'help',
      contentHtml: '<p>help</p>\n',
      updatedAt: '2022-08-19T15:06:36Z',
      links: {},
    },
    isLocked: false,
    student: {
      handle: 'erikSchierboom',
      avatarUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
    },
    track: {
      title: 'Ruby',
    },
    links: {
      lock: '/api/v2/mentoring/requests/5f1c1d70f535445380bfdde6eabd486e/lock',
      cancel:
        '/api/v2/mentoring/requests/5f1c1d70f535445380bfdde6eabd486e/cancel',
      discussion: '/api/v2/mentoring/discussions',
    },
  },
  scratchpad: {
    isIntroducerHidden: false,
    links: {
      markdown: 'http://local.exercism.io:3020/docs/mentoring/markdown',
      hideIntroducer: '/api/v2/settings/introducers/scratchpad/hide',
      self: '/api/v2/scratchpad/mentoring:exercise/ruby:meetup',
    },
  },
  notes: '',
  outOfDate: false,
  downloadCommand: 'exercism download --uuid=c2a1818af2944372b35752385dc6082c',
}

export const RESOLVED_ITERATION_DATA = [
  {
    filename: 'meetup.rb',
    content:
      "=begin\nWrite your code for the 'Meetup' exercise in this file. Make the tests in\n`meetup_test.rb` pass.\n\nTo get started with TDD, see the `README.md` file in your\n`ruby/meetup` directory.\n=end\n\nrequire 'date'\n\nclass Meetup\n  def self.days_of_week\n    [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]\n  end\n\n  def self.weekday_number(weekday)\n    days_of_week.index(weekday)\n  end\n\n  attr_reader :year, :number\n  def initialize(number, year)\n    @year = year\n    @number = number\n    @first = Date.new(year, number, 1)\n    @eighth = Date.new(year, number, 8)\n    @thirteenth = Date.new(year, number, 13)\n    @fifteenth = Date.new(year, number, 15)\n    @twenty_second = Date.new(year, number, 22)\n    @last = Date.new(year, number, -1)\n  end\n\n  def day(weekday, schedule)\n    case schedule\n    when :teenth then\n      @thirteenth + days_til(weekday, @thirteenth)\n    when :first then\n      @first + days_til(weekday, @first)\n    when :second then\n      @eighth + days_til(weekday, @eighth)\n    when :third then\n      @fifteenth + days_til(weekday, @fifteenth)\n    when :fourth then\n      @twenty_second + days_til(weekday, @twenty_second)\n    when :last then\n      @last - (7 - (self.class.weekday_number(weekday) - @last.wday)) % 7\n    end\n  end\n\n  private\n\n  def days_til(weekday, day)\n    (self.class.weekday_number(weekday) - day.wday) % 7\n  end\nend",
    digest: '43f7e96eaba49d455b8533a9008fe5f087fca96a',
  },
]

export const RAW_SESSION_DATA = {
  student: {
    handle: 'erikSchierboom',
    name: 'Erik Schierboom',
    bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best.",
    location: null,
    languagesSpoken: ['english', 'spanish'],
    avatarUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
    reputation: '2,986',
    isFavorited: false,
    isBlocked: false,
    trackObjectives: 'pleas',
    numTotalDiscussions: 0,
    numDiscussionsWithMentor: 0,
    links: {
      block: '/api/v2/mentoring/students/erikSchierboom/block',
      previousSessions:
        '/api/v2/mentoring/discussions?status=all&student=erikSchierboom',
    },
  },
  track: {
    slug: 'ruby',
    title: 'Ruby',
    highlightjsLanguage: 'ruby',
    indentSize: 2,
    medianWaitTime: null,
    iconUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg',
  },
  exercise: {
    slug: 'meetup',
    title: 'Meetup',
    iconUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/meetup.svg',
    links: {
      self: '/tracks/ruby/exercises/meetup',
    },
  },
  links: {
    mentorDashboard: '/mentoring/inbox',
    exercise: '/tracks/ruby/exercises/meetup',
    improveNotes:
      'https://github.com/exercism/website-copy/new/main/tracks/ruby/exercises/meetup?filename=meetup/mentoring.md',
    mentoringDocs: '/docs/mentoring',
  },
  iterations: [
    {
      uuid: 'c47183f61ab34b93b064361a282df941',
      submissionUuid: '81421e93694148b3b3337b2d4b7a882c',
      idx: 1,
      status: 'no_automated_feedback',
      numEssentialAutomatedComments: 0,
      numActionableAutomatedComments: 0,
      numNonActionableAutomatedComments: 0,
      submissionMethod: 'api',
      createdAt: '2022-08-19T15:05:34Z',
      testsStatus: 'passed',
      isPublished: false,
      isLatest: true,
      links: {
        self: 'http://local.exercism.io:3020/tracks/ruby/exercises/meetup/iterations?idx=1',
        automatedFeedback:
          'http://local.exercism.io:3020/api/v2/solutions/c2a1818af2944372b35752385dc6082c/iterations/c47183f61ab34b93b064361a282df941/automated_feedback',
        delete:
          'http://local.exercism.io:3020/api/v2/solutions/c2a1818af2944372b35752385dc6082c/iterations/c47183f61ab34b93b064361a282df941',
        solution: 'http://local.exercism.io:3020/tracks/ruby/exercises/meetup',
        testRun:
          'http://local.exercism.io:3020/api/v2/solutions/c2a1818af2944372b35752385dc6082c/submissions/81421e93694148b3b3337b2d4b7a882c/test_run',
        files:
          'http://local.exercism.io:3020/api/v2/solutions/c2a1818af2944372b35752385dc6082c/submissions/81421e93694148b3b3337b2d4b7a882c/files',
      },
      unread: false,
    },
  ],
  instructions:
    '<p>Calculate the date of meetups.</p>\n<p>Typically meetups happen on the same day of the week.  In this exercise, you\nwill take a description of a meetup date, and return the actual meetup date.</p>\n<p>Examples of general descriptions are:</p>\n<ul>\n<li>The first Monday of January 2017</li>\n<li>The third Tuesday of January 2017</li>\n<li>The wednesteenth of January 2017</li>\n<li>The last Thursday of January 2017</li>\n</ul>\n<p>The descriptors you are expected to parse are:\nfirst, second, third, fourth, fifth, last, monteenth, tuesteenth, wednesteenth,\nthursteenth, friteenth, saturteenth, sunteenth</p>\n<p>Note that "monteenth", "tuesteenth", etc are all made up words. There was a\nmeetup whose members realized that there are exactly 7 numbered days in a month\nthat end in \'-teenth\'. Therefore, one is guaranteed that each day of the week\n(Monday, Tuesday, ...) will have exactly one date that is named with \'-teenth\'\nin every month.</p>\n<p>Given examples of meetup dates, each containing a month, day, year, and\ndescriptor calculate the date of the actual meetup.  For example, if given\n"The first Monday of January 2017", the correct meetup date is 2017/1/2.</p>\n',
  tests:
    'require \'minitest/autorun\'\nrequire_relative \'meetup\'\n\n# rubocop:disable Naming/VariableNumber\n\n# Common test data version: 1.1.0 56cdfa5\nclass MeetupTest < Minitest::Test\n  def test_monteenth_of_may_2013\n    # skip\n    meetup = Meetup.new(5, 2013).day(:monday, :teenth)\n    assert_equal Date.parse("2013-05-13"), meetup\n  end\n\n  def test_monteenth_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:monday, :teenth)\n    assert_equal Date.parse("2013-08-19"), meetup\n  end\n\n  def test_monteenth_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:monday, :teenth)\n    assert_equal Date.parse("2013-09-16"), meetup\n  end\n\n  def test_tuesteenth_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:tuesday, :teenth)\n    assert_equal Date.parse("2013-03-19"), meetup\n  end\n\n  def test_tuesteenth_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:tuesday, :teenth)\n    assert_equal Date.parse("2013-04-16"), meetup\n  end\n\n  def test_tuesteenth_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:tuesday, :teenth)\n    assert_equal Date.parse("2013-08-13"), meetup\n  end\n\n  def test_wednesteenth_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:wednesday, :teenth)\n    assert_equal Date.parse("2013-01-16"), meetup\n  end\n\n  def test_wednesteenth_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:wednesday, :teenth)\n    assert_equal Date.parse("2013-02-13"), meetup\n  end\n\n  def test_wednesteenth_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:wednesday, :teenth)\n    assert_equal Date.parse("2013-06-19"), meetup\n  end\n\n  def test_thursteenth_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:thursday, :teenth)\n    assert_equal Date.parse("2013-05-16"), meetup\n  end\n\n  def test_thursteenth_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:thursday, :teenth)\n    assert_equal Date.parse("2013-06-13"), meetup\n  end\n\n  def test_thursteenth_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :teenth)\n    assert_equal Date.parse("2013-09-19"), meetup\n  end\n\n  def test_friteenth_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:friday, :teenth)\n    assert_equal Date.parse("2013-04-19"), meetup\n  end\n\n  def test_friteenth_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:friday, :teenth)\n    assert_equal Date.parse("2013-08-16"), meetup\n  end\n\n  def test_friteenth_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:friday, :teenth)\n    assert_equal Date.parse("2013-09-13"), meetup\n  end\n\n  def test_saturteenth_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :teenth)\n    assert_equal Date.parse("2013-02-16"), meetup\n  end\n\n  def test_saturteenth_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:saturday, :teenth)\n    assert_equal Date.parse("2013-04-13"), meetup\n  end\n\n  def test_saturteenth_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:saturday, :teenth)\n    assert_equal Date.parse("2013-10-19"), meetup\n  end\n\n  def test_sunteenth_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:sunday, :teenth)\n    assert_equal Date.parse("2013-05-19"), meetup\n  end\n\n  def test_sunteenth_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:sunday, :teenth)\n    assert_equal Date.parse("2013-06-16"), meetup\n  end\n\n  def test_sunteenth_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:sunday, :teenth)\n    assert_equal Date.parse("2013-10-13"), meetup\n  end\n\n  def test_first_monday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:monday, :first)\n    assert_equal Date.parse("2013-03-04"), meetup\n  end\n\n  def test_first_monday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:monday, :first)\n    assert_equal Date.parse("2013-04-01"), meetup\n  end\n\n  def test_first_tuesday_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:tuesday, :first)\n    assert_equal Date.parse("2013-05-07"), meetup\n  end\n\n  def test_first_tuesday_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:tuesday, :first)\n    assert_equal Date.parse("2013-06-04"), meetup\n  end\n\n  def test_first_wednesday_of_july_2013\n    skip\n    meetup = Meetup.new(7, 2013).day(:wednesday, :first)\n    assert_equal Date.parse("2013-07-03"), meetup\n  end\n\n  def test_first_wednesday_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:wednesday, :first)\n    assert_equal Date.parse("2013-08-07"), meetup\n  end\n\n  def test_first_thursday_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :first)\n    assert_equal Date.parse("2013-09-05"), meetup\n  end\n\n  def test_first_thursday_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:thursday, :first)\n    assert_equal Date.parse("2013-10-03"), meetup\n  end\n\n  def test_first_friday_of_november_2013\n    skip\n    meetup = Meetup.new(11, 2013).day(:friday, :first)\n    assert_equal Date.parse("2013-11-01"), meetup\n  end\n\n  def test_first_friday_of_december_2013\n    skip\n    meetup = Meetup.new(12, 2013).day(:friday, :first)\n    assert_equal Date.parse("2013-12-06"), meetup\n  end\n\n  def test_first_saturday_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:saturday, :first)\n    assert_equal Date.parse("2013-01-05"), meetup\n  end\n\n  def test_first_saturday_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :first)\n    assert_equal Date.parse("2013-02-02"), meetup\n  end\n\n  def test_first_sunday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:sunday, :first)\n    assert_equal Date.parse("2013-03-03"), meetup\n  end\n\n  def test_first_sunday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:sunday, :first)\n    assert_equal Date.parse("2013-04-07"), meetup\n  end\n\n  def test_second_monday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:monday, :second)\n    assert_equal Date.parse("2013-03-11"), meetup\n  end\n\n  def test_second_monday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:monday, :second)\n    assert_equal Date.parse("2013-04-08"), meetup\n  end\n\n  def test_second_tuesday_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:tuesday, :second)\n    assert_equal Date.parse("2013-05-14"), meetup\n  end\n\n  def test_second_tuesday_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:tuesday, :second)\n    assert_equal Date.parse("2013-06-11"), meetup\n  end\n\n  def test_second_wednesday_of_july_2013\n    skip\n    meetup = Meetup.new(7, 2013).day(:wednesday, :second)\n    assert_equal Date.parse("2013-07-10"), meetup\n  end\n\n  def test_second_wednesday_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:wednesday, :second)\n    assert_equal Date.parse("2013-08-14"), meetup\n  end\n\n  def test_second_thursday_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :second)\n    assert_equal Date.parse("2013-09-12"), meetup\n  end\n\n  def test_second_thursday_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:thursday, :second)\n    assert_equal Date.parse("2013-10-10"), meetup\n  end\n\n  def test_second_friday_of_november_2013\n    skip\n    meetup = Meetup.new(11, 2013).day(:friday, :second)\n    assert_equal Date.parse("2013-11-08"), meetup\n  end\n\n  def test_second_friday_of_december_2013\n    skip\n    meetup = Meetup.new(12, 2013).day(:friday, :second)\n    assert_equal Date.parse("2013-12-13"), meetup\n  end\n\n  def test_second_saturday_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:saturday, :second)\n    assert_equal Date.parse("2013-01-12"), meetup\n  end\n\n  def test_second_saturday_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :second)\n    assert_equal Date.parse("2013-02-09"), meetup\n  end\n\n  def test_second_sunday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:sunday, :second)\n    assert_equal Date.parse("2013-03-10"), meetup\n  end\n\n  def test_second_sunday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:sunday, :second)\n    assert_equal Date.parse("2013-04-14"), meetup\n  end\n\n  def test_third_monday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:monday, :third)\n    assert_equal Date.parse("2013-03-18"), meetup\n  end\n\n  def test_third_monday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:monday, :third)\n    assert_equal Date.parse("2013-04-15"), meetup\n  end\n\n  def test_third_tuesday_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:tuesday, :third)\n    assert_equal Date.parse("2013-05-21"), meetup\n  end\n\n  def test_third_tuesday_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:tuesday, :third)\n    assert_equal Date.parse("2013-06-18"), meetup\n  end\n\n  def test_third_wednesday_of_july_2013\n    skip\n    meetup = Meetup.new(7, 2013).day(:wednesday, :third)\n    assert_equal Date.parse("2013-07-17"), meetup\n  end\n\n  def test_third_wednesday_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:wednesday, :third)\n    assert_equal Date.parse("2013-08-21"), meetup\n  end\n\n  def test_third_thursday_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :third)\n    assert_equal Date.parse("2013-09-19"), meetup\n  end\n\n  def test_third_thursday_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:thursday, :third)\n    assert_equal Date.parse("2013-10-17"), meetup\n  end\n\n  def test_third_friday_of_november_2013\n    skip\n    meetup = Meetup.new(11, 2013).day(:friday, :third)\n    assert_equal Date.parse("2013-11-15"), meetup\n  end\n\n  def test_third_friday_of_december_2013\n    skip\n    meetup = Meetup.new(12, 2013).day(:friday, :third)\n    assert_equal Date.parse("2013-12-20"), meetup\n  end\n\n  def test_third_saturday_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:saturday, :third)\n    assert_equal Date.parse("2013-01-19"), meetup\n  end\n\n  def test_third_saturday_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :third)\n    assert_equal Date.parse("2013-02-16"), meetup\n  end\n\n  def test_third_sunday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:sunday, :third)\n    assert_equal Date.parse("2013-03-17"), meetup\n  end\n\n  def test_third_sunday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:sunday, :third)\n    assert_equal Date.parse("2013-04-21"), meetup\n  end\n\n  def test_fourth_monday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:monday, :fourth)\n    assert_equal Date.parse("2013-03-25"), meetup\n  end\n\n  def test_fourth_monday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:monday, :fourth)\n    assert_equal Date.parse("2013-04-22"), meetup\n  end\n\n  def test_fourth_tuesday_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:tuesday, :fourth)\n    assert_equal Date.parse("2013-05-28"), meetup\n  end\n\n  def test_fourth_tuesday_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:tuesday, :fourth)\n    assert_equal Date.parse("2013-06-25"), meetup\n  end\n\n  def test_fourth_wednesday_of_july_2013\n    skip\n    meetup = Meetup.new(7, 2013).day(:wednesday, :fourth)\n    assert_equal Date.parse("2013-07-24"), meetup\n  end\n\n  def test_fourth_wednesday_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:wednesday, :fourth)\n    assert_equal Date.parse("2013-08-28"), meetup\n  end\n\n  def test_fourth_thursday_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :fourth)\n    assert_equal Date.parse("2013-09-26"), meetup\n  end\n\n  def test_fourth_thursday_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:thursday, :fourth)\n    assert_equal Date.parse("2013-10-24"), meetup\n  end\n\n  def test_fourth_friday_of_november_2013\n    skip\n    meetup = Meetup.new(11, 2013).day(:friday, :fourth)\n    assert_equal Date.parse("2013-11-22"), meetup\n  end\n\n  def test_fourth_friday_of_december_2013\n    skip\n    meetup = Meetup.new(12, 2013).day(:friday, :fourth)\n    assert_equal Date.parse("2013-12-27"), meetup\n  end\n\n  def test_fourth_saturday_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:saturday, :fourth)\n    assert_equal Date.parse("2013-01-26"), meetup\n  end\n\n  def test_fourth_saturday_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :fourth)\n    assert_equal Date.parse("2013-02-23"), meetup\n  end\n\n  def test_fourth_sunday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:sunday, :fourth)\n    assert_equal Date.parse("2013-03-24"), meetup\n  end\n\n  def test_fourth_sunday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:sunday, :fourth)\n    assert_equal Date.parse("2013-04-28"), meetup\n  end\n\n  def test_last_monday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:monday, :last)\n    assert_equal Date.parse("2013-03-25"), meetup\n  end\n\n  def test_last_monday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:monday, :last)\n    assert_equal Date.parse("2013-04-29"), meetup\n  end\n\n  def test_last_tuesday_of_may_2013\n    skip\n    meetup = Meetup.new(5, 2013).day(:tuesday, :last)\n    assert_equal Date.parse("2013-05-28"), meetup\n  end\n\n  def test_last_tuesday_of_june_2013\n    skip\n    meetup = Meetup.new(6, 2013).day(:tuesday, :last)\n    assert_equal Date.parse("2013-06-25"), meetup\n  end\n\n  def test_last_wednesday_of_july_2013\n    skip\n    meetup = Meetup.new(7, 2013).day(:wednesday, :last)\n    assert_equal Date.parse("2013-07-31"), meetup\n  end\n\n  def test_last_wednesday_of_august_2013\n    skip\n    meetup = Meetup.new(8, 2013).day(:wednesday, :last)\n    assert_equal Date.parse("2013-08-28"), meetup\n  end\n\n  def test_last_thursday_of_september_2013\n    skip\n    meetup = Meetup.new(9, 2013).day(:thursday, :last)\n    assert_equal Date.parse("2013-09-26"), meetup\n  end\n\n  def test_last_thursday_of_october_2013\n    skip\n    meetup = Meetup.new(10, 2013).day(:thursday, :last)\n    assert_equal Date.parse("2013-10-31"), meetup\n  end\n\n  def test_last_friday_of_november_2013\n    skip\n    meetup = Meetup.new(11, 2013).day(:friday, :last)\n    assert_equal Date.parse("2013-11-29"), meetup\n  end\n\n  def test_last_friday_of_december_2013\n    skip\n    meetup = Meetup.new(12, 2013).day(:friday, :last)\n    assert_equal Date.parse("2013-12-27"), meetup\n  end\n\n  def test_last_saturday_of_january_2013\n    skip\n    meetup = Meetup.new(1, 2013).day(:saturday, :last)\n    assert_equal Date.parse("2013-01-26"), meetup\n  end\n\n  def test_last_saturday_of_february_2013\n    skip\n    meetup = Meetup.new(2, 2013).day(:saturday, :last)\n    assert_equal Date.parse("2013-02-23"), meetup\n  end\n\n  def test_last_sunday_of_march_2013\n    skip\n    meetup = Meetup.new(3, 2013).day(:sunday, :last)\n    assert_equal Date.parse("2013-03-31"), meetup\n  end\n\n  def test_last_sunday_of_april_2013\n    skip\n    meetup = Meetup.new(4, 2013).day(:sunday, :last)\n    assert_equal Date.parse("2013-04-28"), meetup\n  end\n\n  def test_last_wednesday_of_february_2012\n    skip\n    meetup = Meetup.new(2, 2012).day(:wednesday, :last)\n    assert_equal Date.parse("2012-02-29"), meetup\n  end\n\n  def test_last_wednesday_of_december_2014\n    skip\n    meetup = Meetup.new(12, 2014).day(:wednesday, :last)\n    assert_equal Date.parse("2014-12-31"), meetup\n  end\n\n  def test_last_sunday_of_february_2015\n    skip\n    meetup = Meetup.new(2, 2015).day(:sunday, :last)\n    assert_equal Date.parse("2015-02-22"), meetup\n  end\n\n  def test_first_friday_of_december_2012\n    skip\n    meetup = Meetup.new(12, 2012).day(:friday, :first)\n    assert_equal Date.parse("2012-12-07"), meetup\n  end\n  # rubocop:enable Naming/VariableNumber\nend\n',
  discussion: null,
  notes: '',
  mentorSolution: {
    uuid: '5137779c65b34924b104fe7b6ad5d15c',
    snippet: null,
    numViews: 0,
    numStars: 0,
    numComments: 0,
    numIterations: 0,
    numLoc: null,
    iterationStatus: null,
    publishedIterationHeadTestsStatus: 'not_queued',
    publishedAt: null,
    isOutOfDate: false,
    language: 'ruby',
    author: {
      handle: 'alice',
      avatarUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
    },
    exercise: {
      title: 'Meetup',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/meetup.svg',
    },
    track: {
      title: 'Ruby',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg',
      highlightjsLanguage: 'ruby',
    },
    links: {
      publicUrl:
        'http://local.exercism.io:3020/tracks/ruby/exercises/meetup/solutions/alice',
      privateIterationsUrl:
        'http://local.exercism.io:3020/tracks/ruby/exercises/meetup/iterations',
    },
  },
  exemplarFiles: [],
  outOfDate: false,
  request: {
    uuid: '5f1c1d70f535445380bfdde6eabd486e',
    comment: {
      uuid: 'request-comment',
      iterationIdx: 1,
      authorHandle: 'erikSchierboom',
      authorAvatarUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
      byStudent: true,
      contentMarkdown: 'help',
      contentHtml: '<p>help</p>\n',
      updatedAt: '2022-08-19T15:06:36Z',
      links: {},
    },
    isLocked: false,
    student: {
      handle: 'erikSchierboom',
      avatarUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
    },
    track: {
      title: 'Ruby',
    },
    links: {
      lock: '/api/v2/mentoring/requests/5f1c1d70f535445380bfdde6eabd486e/lock',
      cancel:
        '/api/v2/mentoring/requests/5f1c1d70f535445380bfdde6eabd486e/cancel',
      discussion: '/api/v2/mentoring/discussions',
    },
  },
  scratchpad: {
    isIntroducerHidden: false,
    links: {
      markdown: 'http://local.exercism.io:3020/docs/mentoring/markdown',
      hideIntroducer: '/api/v2/settings/introducers/scratchpad/hide',
      self: '/api/v2/scratchpad/mentoring:exercise/ruby:meetup',
    },
  },
  userHandle: 'alice',
  downloadCommand: 'exercism download --uuid=c2a1818af2944372b35752385dc6082c',
}
