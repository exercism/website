import { Extension } from '@codemirror/state'
import { TagStyle } from '@codemirror/language'
interface Options {
  /**
   * Theme variant. Determines which styles CodeMirror will apply by default.
   */
  variant: Variant
  /**
   * Settings to customize the look of the editor, like background, gutter, selection and others.
   */
  settings: Settings
  /**
   * Syntax highlighting styles.
   */
  styles: TagStyle[]
}
declare type Variant = 'light' | 'dark'
interface Settings {
  /**
   * Editor background.
   */
  background: string
  /**
   * Default text color.
   */
  foreground: string
  /**
   * Caret color.
   */
  caret: string
  /**
   * Selection background.
   */
  selection: string
  /**
   * Background of highlighted lines.
   */
  lineHighlight: string
  /**
   * Gutter background.
   */
  gutterBackground: string
  /**
   * Text color inside gutter.
   */
  gutterForeground: string
}
declare const createTheme: ({ variant, settings, styles }: Options) => Extension
export default createTheme
