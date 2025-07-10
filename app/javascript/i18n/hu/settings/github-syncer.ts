export default {
  connect_section: {
    heading: 'Megoldások mentése GitHub-ra',
    description:
      'Mentsd automatikusan a megoldásaidat GitHub-ra a mentőeszközünkkel.',
    benefits: {
      safe: 'Biztonságos mentés',
      green: 'Zöld négyzetek',
      free: 'Ingyenes!',
    },
    steps: {
      1: 'Hozz létre egy új GitHub tárolót...',
      2: 'Kattints az alábbi gombra...',
      3: 'Használd a "Backup Everything" opciót...',
      4: 'A jövőbeli megoldások mentve lesznek...',
    },
    button: 'Mentés beállítása',
  },
  connect_modal: {
    heading: 'Tároló csatlakoztatása',
    intro1: 'Mielőtt továbblépsz...',
    intro2:
      'A következő képernyőn engedélyt kell adnod. <strong>Csak egy tárolót válassz</strong>.',
    connect_button: 'GitHub tároló csatlakoztatása',
    cancel_button: 'Mégse',
  },
  commit_template_section: {
    heading: 'Commit üzenet sablon',
    intro:
      'Ezzel a lehetőséggel beállíthatod, hogy nézzenek ki a commit és PR üzeneteid.',
    placeholder_intro: 'Használhatod a következő helyettesítő változókat:',
    placeholders: {
      track_slug: 'A track slug-ja (pl. "csharp")',
      track_title: 'A track neve (pl. "C#")',
      exercise_slug: 'A feladat slug-ja (pl. "hello-world")',
      exercise_title: 'A feladat neve (pl. "Hello World")',
      iteration_idx: 'A feladat iterációs sorszáma (pl. "1")',
      sync_object:
        'Az egyik: "Iteration", "Solution", "Track" vagy "Everything" — attól függően, mit szinkronizálsz.',
    },
    note: {
      note: 'Jegyzet',
      text: 'A commit üzenet elején vagy végén található perjeleket és kötőjeleket eltávolítjuk. Az egymás utáni ismétlődő perjelek vagy kötőjelek egyetlenre lesznek cserélve.',
    },
    save_button: 'Változások mentése',
    revert_button: 'Alapértelmezett visszaállítása',
    confirm_modal: {
      title: 'Biztosan visszaállítod az üzenet sablont az alapértelmezettre?',
      confirm: 'Visszaállítás',
      cancel: 'Mégse',
    },
  },
}
