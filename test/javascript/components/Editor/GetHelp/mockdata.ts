export const MOCK_DATA = {
  HELP: `<p>To get help if you're having trouble, you can use one of the following resources:</p>
  <ul>
  <li><a href="http://ruby-doc.org/" target="_blank" rel="noreferrer">Ruby Documentation</a></li>
  <li><a href="http://stackoverflow.com/questions/tagged/ruby" target="_blank" rel="noreferrer">StackOverflow</a></li>
  <li>
  <a href="https://www.reddit.com/r/ruby" target="_blank" rel="noreferrer">/r/ruby</a> is the Ruby subreddit.</li>
  </ul>
  <p>Should those resources not suffice, check the following pages:</p>
  <ul>
  <li>The <a href="https://exercism.org/docs/tracks/ruby">Ruby track's documentation</a>
  </li>
  <li>The <a href="https://forum.exercism.org/c/programming/ruby" target="_blank" rel="noreferrer">Ruby track's programming category on the forum</a>
  </li>
  <li><a href="https://forum.exercism.org/c/programming/5" target="_blank" rel="noreferrer">Exercism's programming category on the forum</a></li>
  <li>The <a href="https://exercism.org/docs/using/faqs">Frequently Asked Questions</a>
  </li>
  </ul>`,
  ASSIGNMENT: {
    overview:
      "<p>In this exercise you're going to write some code to help you cook a brilliant lasagna from your favorite cooking book.</p>\n<p>You have four tasks, all related to the time spent cooking the lasagna.</p>\n",
    generalHints: [],
    tasks: [
      {
        id: 1,
        title: 'Define the expected oven time in minutes',
        text: '<p>Define the <code>Lasagna::EXPECTED_MINUTES_IN_OVEN</code> constant that returns how many minutes the lasagna should be in the oven.\nAccording to the cooking book, the expected oven time in minutes is 40:</p>\n<pre><code class="language-ruby">Lasagna::EXPECTED_MINUTES_IN_OVEN\n# =&gt; 40\n</code></pre>\n',
        hints: [
          '<ul>\n<li>You need to define a <a href="https://www.rubyguides.com/2017/07/ruby-constants/" target="_blank" rel="noreferrer">constant</a> that should contain the\n<a href="https://ruby-doc.org/core-2.7.0/Integer.html" target="_blank" rel="noreferrer">integer</a> value specified in the recipe.</li>\n<li>The <code>::</code> used in <code>Lasagna::EXPECTED_MINUTES_IN_OVEN</code> means that <code>EXPECTED_MINUTES_IN_OVEN</code> needs to be defined\nwithin the <code>Lasagna</code> class.</li>\n</ul>\n',
        ],
      },
      {
        id: 2,
        title: 'Calculate the remaining oven time in minutes',
        text: '<p>Define the <code>Lasagna#remaining_minutes_in_oven</code> method that takes the actual minutes the lasagna has been in the oven as\na parameter and returns how many minutes the lasagna still has to remain in the oven, based on the expected oven time in\nminutes from the previous task.</p>\n<pre><code class="language-ruby">lasagna = Lasagna.new\nlasagna.remaining_minutes_in_oven(30)\n# =&gt; 10\n</code></pre>\n',
        hints: [
          '<ul>\n<li>You need to define a <a href="https://launchschool.com/books/ruby/read/methods" target="_blank" rel="noreferrer">method</a> with a single parameter for the\nactual time so far.</li>\n<li>You can <a href="https://www.freecodecamp.org/news/idiomatic-ruby-writing-beautiful-code-6845c830c664/#implicit-return" target="_blank" rel="noreferrer">implicitly return an\ninteger</a> from\nthe method.</li>\n<li>You can use the <a href="https://www.w3resource.com/ruby/ruby-arithmetic-operators.php" target="_blank" rel="noreferrer">mathematical operator for\nsubtraction</a> to subtract values.</li>\n</ul>\n',
        ],
      },
      {
        id: 3,
        title: 'Calculate the preparation time in minutes',
        text: '<p>Define the <code>Lasagna#preparation_time_in_minutes</code> method that takes the number of layers you added to the lasagna as a\nparameter and returns how many minutes you spent preparing the lasagna, assuming each layer takes you 2 minutes to\nprepare.</p>\n<pre><code class="language-ruby">lasagna = Lasagna.new\nlasagna.preparation_time_in_minutes(2)\n# =&gt; 4\n</code></pre>\n',
        hints: [
          '<ul>\n<li>You need to define a <a href="https://launchschool.com/books/ruby/read/methods" target="_blank" rel="noreferrer">method</a> with a single parameter for the\nnumber of layers.</li>\n<li>You can <a href="https://www.freecodecamp.org/news/idiomatic-ruby-writing-beautiful-code-6845c830c664/#implicit-return" target="_blank" rel="noreferrer">implicitly return an\ninteger</a> from\nthe method.</li>\n<li>You can use the <a href="https://www.w3resource.com/ruby/ruby-arithmetic-operators.php" target="_blank" rel="noreferrer">mathematical operator for\nmultiplication</a> to multiply values.</li>\n<li>You could define an extra constant for the time in minutes per layer, or use a "magic number" in the code.</li>\n</ul>\n',
        ],
      },
      {
        id: 4,
        title: 'Calculate the total working time in minutes',
        text: '<p>Define the <code>Lasagna#total_time_in_minutes</code> method that takes two named parameters: the <code>number_of_layers</code> parameter is\nthe number of layers you added to the lasagna, and the <code>actual_minutes_in_oven</code> parameter is the number of minutes the\nlasagna has been in the oven. The function should return how many minutes in total you\'ve worked on cooking the lasagna,\nwhich is the sum of the preparation time in minutes, and the time in minutes the lasagna has spent in the oven at the\nmoment.</p>\n<pre><code class="language-ruby">lasagna = Lasagna.new\nlasagna.total_time_in_minutes(number_of_layers: 3, actual_minutes_in_oven: 20)\n# =&gt; 26\n</code></pre>\n',
        hints: [
          '<ul>\n<li>You need to define a <a href="https://launchschool.com/books/ruby/read/methods" target="_blank" rel="noreferrer">method</a> with two named parameters:\n<code>number_of_layers</code> and <code>actual_minutes_in_oven</code>.</li>\n<li>You can <a href="https://www.freecodecamp.org/news/idiomatic-ruby-writing-beautiful-code-6845c830c664/#implicit-return" target="_blank" rel="noreferrer">implicitly return an\ninteger</a> from\nthe method.</li>\n<li>You can <a href="http://ruby-for-beginners.rubymonstas.org/objects/calling.html" target="_blank" rel="noreferrer">invoke</a> one of the other methods you\'ve\ndefined previously.</li>\n<li>You can use the <a href="https://www.w3resource.com/ruby/ruby-arithmetic-operators.php" target="_blank" rel="noreferrer">mathematical operator for addition</a>\nto add values.</li>\n</ul>\n',
        ],
      },
    ],
  },
}
