// namespace: components/settings/github-syncer/sections/ConnectedSection
export default {
  'index.syncerConnected': 'Syncer connected',
  'dangerZoneSection.pauseSyncer': 'Pause Syncer',
  'dangerZoneSection.wantToPause': 'Want to pause your syncer for a while?',
  'dangerZoneSection.useButtonBelow':
    'Use the button below. You can restart it at any time.',
  'dangerZoneSection.disconnectSyncer': 'Disconnect Syncer',
  'dangerZoneSection.wantToDisconnect':
    'Want to disconnect the syncer from your GitHub repository? Use the button below.',
  'dangerZoneSection.noteWillDeleteSettings':
    '<strong>Note: </strong> This will also delete all settings on this page, so please manually save any settings you might wish to reuse in the future (e.g. your path template).',
  'dangerZoneSection.disconnectGithub': 'Disconnect GitHub',
  'dangerZoneSection.areYouSureDisconnect':
    'Are you sure you want to disconnect your GitHub repository?',
  'dangerZoneSection.thisActionCannotUndone': 'This action cannot be undone.',
  'dangerZoneSection.disconnectSyncerConfirm': 'Disconnect Syncer',
  'dangerZoneSection.cancel': 'Cancel',
  'fileStructureSection.fileStructure': 'File structure',
  'fileStructureSection.configureFolderStructure':
    'Use this option to configure the folder structure for your repository.',
  'fileStructureSection.placeholderValues':
    'You can use the following placeholder values, which will be interpolated for each commit:',
  'fileStructureSection.trackSlug':
    '<code>$track_slug</code>: The slug of the track (e.g. "csharp").',
  'fileStructureSection.trackTitle':
    '<code>$track_title</code>: The name of the track (e.g. "C#")',
  'fileStructureSection.exerciseSlug':
    '<code>$exercise_slug</code>: The slug of the exercise (e.g.  "hello-world")',
  'fileStructureSection.exerciseTitle':
    '<code>$exercise_title</code>: The name of the exercise (e.g. "Hello World")',
  'fileStructureSection.iterationIdx':
    '<code>$iteration_idx</code>: The iteration index of the exercise (e.g. "1")',
  'fileStructureSection.note1YourPath':
    '<strong>Note 1:</strong> Your path must contain a track placeholder (<code>$track_slug</code> or <code>$track_title</code>) and an exercise placeholder ( <code>$exercise_slug</code> or <code>$exercise_title</code>.',
  'fileStructureSection.note2Iteration':
    '<strong>Note 2:</strong> The <code>$iteration_idx</code> placeholder is optional, but if you omit it, each iteration will override the previous one. This allows you to use Git for version controlling your solutions. Including the iteration index will result in a different folder for every iteration.',
  'fileStructureSection.pathTemplateMustInclude':
    'Your path template must include either <code>$track_slug</code> or <code>$track_title</code>, and either <code>$exercise_slug</code> or <code>$exercise_title</code>.',
  'fileStructureSection.saveChanges': 'Save changes',
  'fileStructureSection.revertToDefault': 'Revert to default',
  'fileStructureSection.areYouSureWantRevert':
    'Are you sure you want to revert your path template to default?',
  'fileStructureSection.revert': 'Revert',
  'fileStructureSection.cancel': 'Cancel',
  'statusSection.status':
    'Status: <span style={{ color: textColor }}>{{status}}</span>',
  'statusSection.githubSyncerLinked':
    'Your GitHub syncer is linked to <code>{{repoFullName}}</code>.',
  'statusSection.enableSyncer': 'Enable Syncer',
  'statusSection.areYouSureResumeSyncing':
    'Are you sure you want to resume syncing solutions with GitHub?',
  'statusSection.resume': 'Resume',
  'commitMessageTemplateSection.heading': 'Commit message template',
  'commitMessageTemplateSection.intro':
    'Use this option to determine what your commit and PR messages should look like.',
  'commitMessageTemplateSection.placeholder_intro':
    'You can use the following placeholder values:',
  'commitMessageTemplateSection.placeholders.track_slug':
    'The slug of the track (e.g. "csharp").',
  'commitMessageTemplateSection.placeholders.track_title':
    'The name of the track (e.g. "C#")',
  'commitMessageTemplateSection.placeholders.exercise_slug':
    'The slug of the exercise (e.g. "hello-world")',
  'commitMessageTemplateSection.placeholders.exercise_title':
    'The name of the exercise (e.g. "Hello World")',
  'commitMessageTemplateSection.placeholders.iteration_idx':
    'The iteration index of the exercise (e.g. "1")',
  'commitMessageTemplateSection.placeholders.sync_object':
    'One of "Iteration", "Solution", "Track", or "Everything" depending on what is syncing.',
  'commitMessageTemplateSection.note.note': 'Note',
  'commitMessageTemplateSection.note.text':
    'If your commit message contains leading or trailing slashes or dashes, these will be stripped. Multiple consecutive slashes or dashes will be reduced to single ones.',
  'commitMessageTemplateSection.save_button': 'Save changes',
  'commitMessageTemplateSection.revert_button': 'Revert to default',
  'commitMessageTemplateSection.confirm_modal.title':
    'Are you sure you want to revert your commit message template to default?',
  'commitMessageTemplateSection.confirm_modal.confirm': 'Revert',
  'commitMessageTemplateSection.confirm_modal.cancel': 'Cancel',
  'processingMethodSection.processingMethod': 'Processing method',
  'processingMethodSection.commitDirectly': 'Commit directly',
  'processingMethodSection.createPullRequest': 'Create pull request',
  'processingMethodSection.whatIsTheName':
    'What is the name of your main branch?',
  'processingMethodSection.ourBot':
    'Our bot can commit directly to your repository for a fully automated setup, or create a pull request which you can approve each time. Which method would you prefer?',
  'processingMethodSection.saveChange': 'Save changes',
  'justConnectedModal.repositoryConnected':
    'Repository connected successfully!',
  'justConnectedModal.accountConnected':
    "We've connected your Exercism account to your chosen repository.",
  'justConnectedModal.happyWithDefaults':
    "If you're happy with the defaults, you can back everything up now. Or you can tweak your settings, then use the button at the bottom of the settings page to back up later. Do you want to backup everything now?",
  'justConnectedModal.backUpEverythingNow': 'Back up everything now',
  'justConnectedModal.backUpLater': 'Back up later',
  'manualSyncSection.backupTrack': 'Backup a track',
  'manualSyncSection.backupTrackInfo':
    'If you want to backup a track to GitHub, you can use this function.',
  'manualSyncSection.pleaseUseSparing':
    '<strong className="font-medium">Note:</strong> Please use this sparingly, for example when you want to backup a track for the first time. This is not designed to be part of your normal workflow and will likely hit rate-limits if over-used.',
  'manualSyncSection.selectTrackToBackup': 'Select track to backup',
  'manualSyncSection.backupTrackButton': 'Backup Track',
  'manualSyncSection.backupEverything': 'Backup everything',
  'manualSyncSection.backupEverythingInfo':
    'If you want to backup all your exercises across all tracks to GitHub, you can use this function.',
  'manualSyncSection.pleaseUseSparingBootstrap':
    '<strong className="font-medium">Note:</strong> Please use this sparingly, for example when you want to bootstrap a new repo. This is not designed to be part of your normal workflow.',
  'manualSyncSection.backupEverythingButton': 'Backup Everything',
  'iterationFilesSection.iterationFiles': 'Iteration files',
  'iterationFilesSection.whenSyncing':
    'When syncing, do you want all the files in the exercise (e.g. your solution, the tests, the README, the hints, etc) to be synced to GitHub, or only your solution file(s)?',
  'iterationFilesSection.theFullExercise': 'The full exercise',
  'iterationFilesSection.onlyMySolutionFiles': 'Only my solution file(s)',
  'iterationFilesSection.saveChanges': 'Save changes',
  'syncBehaviourSection.syncBehaviour': 'Sync behaviour',
  'syncBehaviourSection.chooseWhetherSyncing':
    'Choose whether syncing should happen automatically when you create a new iteration, or manually when you trigger it yourself. <strong>Automatic</strong> keeps your GitHub repo up to date, while <strong>manual</strong> gives you full control.',
  'syncBehaviourSection.automatic': 'Automatic',
  'syncBehaviourSection.manual': 'Manual',
}
