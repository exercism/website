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
