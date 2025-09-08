# Instructions for Creating a Glossary Translation File

You are tasked with creating a translation file for the Exercism glossary. You will be provided with the source glossary file (`i18n_GLOSSARY.tsv`) and need to create a translated version for a specific locale.

## Input

- Source file: `i18n_GLOSSARY.tsv`
- Target locale: [LOCALE_CODE] (e.g., `hu` for Hungarian, `es` for Spanish, `fr` for French, etc.)

## Output

Create a file at `i18n/glossary/[LOCALE_CODE].tsv` with the following format:

### File Format

The output file should be a tab-separated values (TSV) file with three columns:

1. **term** - The original English term (copied exactly from the source)
2. **translation** - Your translation of the term into the target language
3. **llm_instructions** - The instructions from the source file (copied verbatim)

### Translation Guidelines

1. **Read the llm_instructions carefully** - These provide context about how each term should be translated
2. **Maintain consistency** - Related terms should use consistent translations (e.g., if you translate "mentor" as "mentore", then "mentoring" should be "mentoraggio")
3. **Consider local conventions** - Use terms that are commonly understood in the target language's programming community
4. **Special terms to handle carefully**:
   - **CLI** - May stay as "CLI" or use local equivalent for command-line interface
   - **Insiders** - Should remain as "Insiders" (it's a program name)
   - **Learn**, **Discover**, **Contribute** - These are main navigation items, translate as verbs
   - Technical terms (function, method, parameter, argument) - Use standard programming terminology in the target language

### Example Output (first few lines for Hungarian):

```tsv
term	translation	llm_instructions
CLI	CLI	The command-line interface tool used to download exercises and submit solutions. Keep as CLI or use the standard translation for command-line interface
Insiders	Insiders	Exercism Insiders is the rewards program for contributors, mentors, and donors. Keep 'Insiders' untranslated as it's a program name, but translate 'Exercism Insiders' as 'Exercism Insiders' followed by explanation if needed
achievement	teljesítmény	A goal completed or milestone reached in learning. Use the standard term for achievement or accomplishment
administrator	rendszergazda	Someone who manages and maintains the Exercism platform. Use the standard term for administrator or system administrator
analyzer	elemző	An automated tool that analyzes code and provides feedback on common patterns and improvements. Use a technical term that conveys automated code analysis
```

### Important Notes

1. **Preserve the header row**: The first row should be `term	translation	llm_instructions`
2. **Use tabs as separators**: Not spaces, actual tab characters
3. **Copy the term and llm_instructions exactly**: No modifications to these columns
4. **Skip the first row** of the source file (it contains column headers)
5. **Include all terms**: Don't skip any entries from the source file
6. **Maintain alphabetical order**: The terms should remain in the same order as the source file

## Validation

After creating the file, verify that:

- Every term from the source file is present
- The file uses proper TSV format with tabs
- All three columns are present for each row
- The translations are appropriate for the target language and consistent with each other
