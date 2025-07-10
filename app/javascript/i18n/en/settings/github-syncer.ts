export default {
  connect_section: {
    heading: 'Backup your Solutions to GitHub',
    description:
      'Automatically backup your solutions to GitHub with our automated backup tool.',
    benefits: {
      safe: 'Safe Backup',
      green: 'Green Squares',
      free: "It's Free!",
    },
    steps: {
      1: 'Create a new GitHub repository...',
      2: 'Click the button below...',
      3: 'Use the "Backup Everything" option...',
      4: 'Future solutions will be backed up...',
    },
    button: 'Setup Backup',
  },
  connect_modal: {
    heading: 'Connect a Repository',
    intro1: 'Before continuing...',
    intro2:
      'On the next screen you will be asked to give permission to that repository. Please <strong>select only one repository</strong>.',
    connect_button: 'Connect a GitHub repository',
    cancel_button: 'Cancel',
  },
  commit_message_template_section: {
    heading: 'Commit message template',
    intro:
      'Use this option to determine what your commit and PR messages should look like.',
    placeholder_intro: 'You can use the following placeholder values:',
    placeholders: {
      track_slug: 'The slug of the track (e.g. "csharp")',
      track_title: 'The name of the track (e.g. "C#")',
      exercise_slug: 'The slug of the exercise (e.g. "hello-world")',
      exercise_title: 'The name of the exercise (e.g. "Hello World")',
      iteration_idx: 'The iteration index of the exercise (e.g. "1")',
      sync_object:
        'One of "Iteration", "Solution", "Track", or "Everything" depending on what is syncing.',
    },
    note: {
      note: 'Note',
      text: 'If your commit message contains leading or trailing slashes or dashes, these will be stripped. Multiple consecutive slashes or dashes will be reduced to single ones.',
    },
    save_button: 'Save changes',
    revert_button: 'Revert to default',
    confirm_modal: {
      title:
        'Are you sure you want to revert your commit message template to default?',
      confirm: 'Revert',
      cancel: 'Cancel',
    },
  },
}
