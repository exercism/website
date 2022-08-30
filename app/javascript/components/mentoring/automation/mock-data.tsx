import { MentorDiscussion, MentoredTrack } from '../../types'

export const MOCK_DEFAULT_TRACK = {
  slug: 'ruby',
  title: 'Ruby',
  iconUrl:
    'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg',
  numSolutionsQueued: 0,
  medianWaitTime: null,
  links: {
    exercises:
      'http://local.exercism.io:3020/api/v2/mentoring/requests/exercises?track_slug=ruby',
  },
  exercises: [
    {
      slug: 'accumulate',
      title: 'Accumulate',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/accumulate.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'acronym',
      title: 'Acronym',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/acronym.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'affine-cipher',
      title: 'Affine Cipher',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/affine-cipher.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'all-your-base',
      title: 'All Your Base',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/all-your-base.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'allergies',
      title: 'Allergies',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/allergies.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'alphametics',
      title: 'Alphametics',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/alphametics.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'amusement-park',
      title: 'Amusement Park',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/amusement-park.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'amusement-park-improvements',
      title: 'Amusement Park Improvements',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/amusement-park-improvements.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'anagram',
      title: 'Anagram',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/anagram.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'armstrong-numbers',
      title: 'Armstrong Numbers',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/armstrong-numbers.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'assembly-line',
      title: 'Assembly Line',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/assembly-line.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'atbash-cipher',
      title: 'Atbash Cipher',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/atbash-cipher.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'beer-song',
      title: 'Beer Song',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/beer-song.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'binary',
      title: 'Binary',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/binary.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'binary-search',
      title: 'Binary Search',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/binary-search.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'binary-search-tree',
      title: 'Binary Search Tree',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/binary-search-tree.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'bird-count',
      title: 'Bird Count',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/bird-count.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'bob',
      title: 'Bob',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/bob.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'book-store',
      title: 'Book Store',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/book-store.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'boutique-inventory',
      title: 'Boutique Inventory',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/boutique-inventory.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'boutique-inventory-improvements',
      title: 'Boutique Inventory Improvements',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/boutique-inventory-improvements.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'bowling',
      title: 'Bowling',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/bowling.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'change',
      title: 'Change',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/change.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'circular-buffer',
      title: 'Circular Buffer',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/circular-buffer.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'clock',
      title: 'Clock',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/clock.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'collatz-conjecture',
      title: 'Collatz Conjecture',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/collatz-conjecture.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'complex-numbers',
      title: 'Complex Numbers',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/complex-numbers.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'connect',
      title: 'Connect',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/connect.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'crypto-square',
      title: 'Crypto Square',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/crypto-square.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'custom-set',
      title: 'Custom Set',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/custom-set.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'darts',
      title: 'Darts',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/darts.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'diamond',
      title: 'Diamond',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/diamond.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'difference-of-squares',
      title: 'Difference Of Squares',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/difference-of-squares.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'dominoes',
      title: 'Dominoes',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/dominoes.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'etl',
      title: 'Etl',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/etl.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'flatten-array',
      title: 'Flatten Array',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/flatten-array.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'food-chain',
      title: 'Food Chain',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/food-chain.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'gigasecond',
      title: 'Gigasecond',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/gigasecond.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'grade-school',
      title: 'Grade School',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/grade-school.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'grains',
      title: 'Grains',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/grains.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'grep',
      title: 'Grep',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/grep.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'hamming',
      title: 'Hamming',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/hamming.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'hello-world',
      title: 'Hello World',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/hello-world.svg',
      count: 0,
      completedByMentor: true,
    },
    {
      slug: 'hexadecimal',
      title: 'Hexadecimal',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/hexadecimal.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'high-scores',
      title: 'High Scores',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/high-scores.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'house',
      title: 'House',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/house.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'isbn-verifier',
      title: 'Isbn Verifier',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/isbn-verifier.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'isogram',
      title: 'Isogram',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/isogram.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'kindergarten-garden',
      title: 'Kindergarten Garden',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/kindergarten-garden.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'largest-series-product',
      title: 'Largest Series Product',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/largest-series-product.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'lasagna',
      title: 'Lasagna',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/lasagna.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'leap',
      title: 'Leap',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/leap.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'linked-list',
      title: 'Linked List',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/linked-list.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'list-ops',
      title: 'List Ops',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/list-ops.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'log-line-parser',
      title: 'Log line Parser',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/logs-logs-logs.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'luhn',
      title: 'Luhn',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/luhn.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'matching-brackets',
      title: 'Matching Brackets',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/matching-brackets.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'matrix',
      title: 'Matrix',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/matrix.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'meetup',
      title: 'Meetup',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/meetup.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'microwave',
      title: 'Microwave',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/microwave.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'minesweeper',
      title: 'Minesweeper',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/minesweeper.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'moviegoer',
      title: 'Moviegoer',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/movie-goer.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'nth-prime',
      title: 'Nth Prime',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/nth-prime.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'nucleotide-count',
      title: 'Nucleotide Count',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/nucleotide-count.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'ocr-numbers',
      title: 'Ocr Numbers',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/ocr-numbers.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'octal',
      title: 'Octal',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/octal.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'palindrome-products',
      title: 'Palindrome Products',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/palindrome-products.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'pangram',
      title: 'Pangram',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/pangram.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'pascals-triangle',
      title: 'Pascals Triangle',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/pascals-triangle.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'perfect-numbers',
      title: 'Perfect Numbers',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/perfect-numbers.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'phone-number',
      title: 'Phone Number',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/phone-number.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'pig-latin',
      title: 'Pig Latin',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/pig-latin.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'point-mutations',
      title: 'Point Mutations',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/point-mutations.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'poker',
      title: 'Poker',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/poker.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'prime-factors',
      title: 'Prime Factors',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/prime-factors.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'protein-translation',
      title: 'Protein Translation',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/protein-translation.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'proverb',
      title: 'Proverb',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/proverb.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'pythagorean-triplet',
      title: 'Pythagorean Triplet',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/pythagorean-triplet.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'queen-attack',
      title: 'Queen Attack',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/queen-attack.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'rail-fence-cipher',
      title: 'Rail Fence Cipher',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/rail-fence-cipher.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'raindrops',
      title: 'Raindrops',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/raindrops.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'resistor-color',
      title: 'Resistor Color',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/resistor-color.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'resistor-color-duo',
      title: 'Resistor Color Duo',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/resistor-color-duo.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'resistor-color-trio',
      title: 'Resistor Color Trio',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/resistor-color-trio.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'rna-transcription',
      title: 'Rna Transcription',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/rna-transcription.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'robot-name',
      title: 'Robot Name',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/robot-name.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'robot-simulator',
      title: 'Robot Simulator',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/robot-simulator.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'roman-numerals',
      title: 'Roman Numerals',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/roman-numerals.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'rotational-cipher',
      title: 'Rotational Cipher',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/rotational-cipher.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'run-length-encoding',
      title: 'Run Length Encoding',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/run-length-encoding.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'saddle-points',
      title: 'Saddle Points',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/saddle-points.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'savings-account',
      title: 'Savings Account',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/savings-account.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'say',
      title: 'Say',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/say.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'scale-generator',
      title: 'Scale Generator',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/scale-generator.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'scrabble-score',
      title: 'Scrabble Score',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/scrabble-score.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'secret-handshake',
      title: 'Secret Handshake',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/secret-handshake.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'series',
      title: 'Series',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/series.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'sieve',
      title: 'Sieve',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/sieve.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'simple-calculator',
      title: 'Simple Calculator',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/simple-calculator.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'simple-cipher',
      title: 'Simple Cipher',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/simple-cipher.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'simple-linked-list',
      title: 'Simple Linked List',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/simple-linked-list.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'space-age',
      title: 'Space Age',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/space-age.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'strain',
      title: 'Strain',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/strain.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'sum-of-multiples',
      title: 'Sum Of Multiples',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/sum-of-multiples.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'tournament',
      title: 'Tournament',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/tournament.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'transpose',
      title: 'Transpose',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/transpose.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'triangle',
      title: 'Triangle',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/triangle.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'trinary',
      title: 'Trinary',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/trinary.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'twelve-days',
      title: 'Twelve Days',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/twelve-days.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'two-bucket',
      title: 'Two Bucket',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/two-bucket.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'two-fer',
      title: 'Two Fer',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/two-fer.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'word-count',
      title: 'Word Count',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/word-count.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'wordy',
      title: 'Wordy',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/wordy.svg',
      count: 0,
      completedByMentor: false,
    },
    {
      slug: 'zipper',
      title: 'Zipper',
      iconUrl:
        'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/zipper.svg',
      count: 0,
      completedByMentor: false,
    },
  ],
}

export const MOCK_TRACKS: MentoredTrack[] | undefined = [
  {
    slug: 'ruby',
    title: 'Ruby',
    iconUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg',
    numSolutionsQueued: 0,
    medianWaitTime: null,
    links: {
      exercises:
        'http://local.exercism.io:3020/api/v2/mentoring/requests/exercises?track_slug=ruby',
    },
  },
]

export const MOCK_LIST_ELEMENT: MentorDiscussion = {
  uuid: '63b2c29073304a00b453c6d0e3dd0d31',
  status: 'awaiting_student',
  finishedAt: null,
  finishedBy: null,
  track: {
    title: 'Ruby',
    iconUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg',
  },
  exercise: {
    title: 'Lasagna',
    iconUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/lasagna.svg',
  },
  student: {
    handle: 'alice',
    avatarUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
    isFavorited: false,
  },
  mentor: {
    handle: 'erikSchierboom',
    avatarUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
  },
  createdAt: '2022-08-10T12:43:45Z',
  updatedAt: '2022-08-10T12:43:45Z',
  isFinished: false,
  isUnread: true,
  postsCount: 3,
  iterationsCount: 1,
  links: {
    self: 'http://local.exercism.io:3020/mentoring/discussions/63b2c29073304a00b453c6d0e3dd0d31',
    posts:
      'http://local.exercism.io:3020/api/v2/mentoring/discussions/63b2c29073304a00b453c6d0e3dd0d31/posts',
    finish:
      'http://local.exercism.io:3020/api/v2/mentoring/discussions/63b2c29073304a00b453c6d0e3dd0d31/finish',
    markAsNothingToDo:
      'http://local.exercism.io:3020/api/v2/mentoring/discussions/63b2c29073304a00b453c6d0e3dd0d31/mark_as_nothing_to_do',
  },
}
