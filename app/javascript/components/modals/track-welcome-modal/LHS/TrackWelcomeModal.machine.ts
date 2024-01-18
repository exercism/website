import { assign, createMachine } from 'xstate'

export type StateEvent =
  | 'HAS_LEARNING_MODE'
  | 'HAS_NO_LEARNING_MODE'
  | 'SELECT_LEARNING_MODE'
  | 'SELECT_PRACTICE_MODE'
  | 'CONTINUE'
  | 'SELECT_LOCAL_MACHINE'
  | 'SELECT_ONLINE_EDITOR'
  | 'RESET'

export type StateValue =
  | 'hasLearningMode'
  | 'hasNoLearningMode'
  | 'learningEnvironmentSelector'
  | 'selectedLocalMachine'
  | 'selectedOnlineEditor'
  | 'openModal'

export const UNSET_CHOICES = { Mode: 'Unset', Interface: 'Unset' }
export type ChoicesType = typeof UNSET_CHOICES
export type MachineType = typeof machine
export const machine = createMachine({
  /** @xstate-layout N4IgpgJg5mDOIC5QBcBOBDAxgawOpgBtMB7AWzAFliJ0CBlZMAB1gDpimwA7KmggYgASAQToB9ADIBRYQCUAcgEl5AcTEUA8gBEpAbQAMAXUSgmxWAEtkF4lxMgAHogCMAdlesATPteeALABsAMxBAJx+ABwArH5+ADQgAJ6IoUFe+lEBfkEBPlGeEZ5BAL7FCWhYeIQk5Ly0DMxsHNx1AiLi8hqSMgrKapo6BsZIIGaW1rb2TghuHt6+gSHh0bEJyQg5zqwBEbs7oZ7OufrOpeUYOPhEZJTU9YwsrAAW6LASYOioXBZcULxg-GkciUqnU2j0RnsYysNjsI2mAW821CoX0+lR7n0QSOaxcQTmvmcYRiKKOzgiZxAFUu1RurQajxebw+Xx+f2oAIACrJhABhAAqil5UjBg0hI2hEzhoARSICKLRGNcWJxSUQEQCrFcqLJGqihSioQpZSpFyq11qd3oDzYTPkxHen2+v3+-F5GnkgvkAFUIcNTOYYZN4Slgtt8UFoiFnFFcTNUaxAob9EVQjEsq4opTqeaarc+Ay2JgCBYNKgJMRMLQ3RJFEMoYGpVNQ2lgq5I1Fo7G1QgIls-KFnM50REMtrM9mzVc8-Sbaxi6Xy5XqxINLzhBJ6xLG7DmwhQmG2x2u3GiaFWEawv5XEP8X59ZPKtO6VbC-OS2WK1WBAAhPkAaS3ANxl3EN90PCMo2xbt1n8fQLz8VxdjRbUohJY0TS4Dl4BGHNn0tAsbQbEDgxlRAAFoAjjSjHxpC183uRp2E4HgrWIoNpUcRA-E8U80VYIdMnCZxEJvbJPFo3MX0IpimUdVkXQ5dimzA7JNR8TETn0REDkQuNUi1NFyV8fxAgCKJXEk-CGOtWTXnteTnXZCAwGU0CyJmYcoi1czPCKTIbyCeIe38NJwn8AIRJ2PsYxKE08NpAjGMeBdP2XAg3NIrjeyHLUDxTHxnG8IJPFcfS-FYTsgnyDILO1FErMSmy3wXTLOOmIcMh8-J-ICQLgvWPsL2ieUhzTDI-FOeKpya2cmIIdK2r3TrvNcXzev608-HgxDom04dtOxKbSiAA */
  tsTypes: {} as import('./TrackWelcomeModal.machine.typegen').Typegen0,
  id: 'trackWelcomeModalSteps',
  initial: 'openModal',
  schema: {
    context: { choices: {} as { Mode: string; Interface: string } },
    events: {} as { type: StateEvent },
  },
  states: {
    openModal: {
      on: {
        HAS_LEARNING_MODE: 'hasLearningMode',
        HAS_NO_LEARNING_MODE: {
          target: 'hasNoLearningMode',
        },
      },
    },
    hasLearningMode: {
      id: 'hasLearningMode',
      on: {
        SELECT_LEARNING_MODE: {
          target: 'learningEnvironmentSelector',
          actions: 'handleSelectLearningMode',
        },
        SELECT_PRACTICE_MODE: {
          target: 'learningEnvironmentSelector',
          actions: 'handleSelectPracticeMode',
        },
      },
    },
    hasNoLearningMode: {
      id: 'hasNoLearningMode',
      on: {
        CONTINUE: 'learningEnvironmentSelector',
      },
    },
    learningEnvironmentSelector: {
      id: 'learningEnvironmentSelector',
      on: {
        SELECT_LOCAL_MACHINE: {
          target: 'selectedLocalMachine',
        },
        SELECT_ONLINE_EDITOR: {
          target: 'selectedOnlineEditor',
        },
        RESET: {
          target: 'openModal',
        },
      },
    },
    selectedLocalMachine: {
      id: 'selectedLocalMachine',
      on: {
        CONTINUE: {
          actions: 'handleContinueToLocalMachine',
        },
        RESET: {
          target: 'openModal',
        },
      },
    },
    selectedOnlineEditor: {
      id: 'selectedOnlineEditor',
      on: {
        CONTINUE: {
          actions: 'handleContinueToOnlineEditor',
        },
        RESET: {
          target: 'openModal',
        },
      },
    },
  },
})
