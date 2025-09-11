# Glossary Entries Components Documentation

This documentation covers the React components for managing localization glossary entries, including both list and show views. The system handles translation proposals, reviews, and approvals through a workflow-based approach.

## Overview

The glossary entries system allows translators to:

- View and filter glossary entries by status and locale
- Create new glossary term proposals
- Edit and propose modifications to existing translations
- Approve or reject translation proposals (with proper permissions)
- Navigate through entries for efficient reviewing

## Architecture

### Component Structure

```
glossary-entries/
├── list/                          # List view components
│   ├── index.tsx                 # Main list container with context
│   ├── Table.tsx                 # Search, filters, and proposal modal
│   ├── GlossaryEntriesTableList.tsx  # Paginated results display
│   ├── GlossaryEntriesTableListElement.tsx  # Individual entry row
│   ├── Tabs.tsx                  # Status filter tabs
│   └── LocaleSelect.tsx          # Locale dropdown filter
├── show/                         # Detail view components
│   ├── index.tsx                 # Main show container with context
│   ├── Unchecked.tsx             # Component for unchecked entries
│   ├── Checked.tsx               # Component for approved/rejected entries
│   ├── Proposed/                 # Proposed entries workflow
│   │   ├── index.tsx            # Main proposed container
│   │   ├── ProposalCard.tsx     # Individual proposal display
│   │   ├── ProposalActions.tsx   # Approve/reject actions
│   │   ├── EditActions.tsx      # Edit proposal actions
│   │   ├── FeedbackBlock.tsx    # LLM feedback display
│   │   └── ...other subcomponents
│   └── useRequestWithNextRedirect.ts  # Navigation helper
└── types.d.ts                    # TypeScript definitions
```

## List Component (`list/index.tsx`)

### Purpose

Displays a paginated, filterable list of glossary entries that the current user can translate based on their locale permissions.

### Key Features

- **Pagination**: Uses `usePaginatedRequestQuery` for efficient data loading
- **Search**: Debounced search across term and translation fields
- **Filtering**: By status (all, unchecked, proposed, checked) and locale
- **Real-time updates**: Automatically refetches data when filters change
- **Proposal creation**: Modal for creating new glossary term proposals

### Context Provider

```typescript
type GlossaryEntriesListContextType = {
  glossaryEntries: GlossaryEntry[];
  translationLocales: string[];
  links: {
    localizationGlossaryEntriesPath: string;
    endpoint: string;
    createGlossaryEntry: string;
  };
  mayCreateTranslationProposals: boolean;
  mayManageTranslationProposals: boolean;
  // ... filtering and pagination methods
};
```

### API Calls

#### 1. List Entries (`GET /api/localization/glossary_entries`)

**Controller**: `API::Localization::GlossaryEntriesController#index`
**Command**: `AssembleLocalizationGlossaryEntries`
**Purpose**: Fetch filtered and paginated glossary entries

**Parameters**:

- `criteria`: Search term for filtering by term or translation text
- `status`: Filter by entry status (`unchecked`, `proposed`, `checked`)
- `filter_locale`: Filter by specific locale
- `page`: Pagination page number

**Side Effects**:

- Executes `Localization::GlossaryEntry::Search` command
- Filters entries by user's translator locales (excludes `:en`)
- Returns paginated results with metadata

**Response Structure**:

```json
{
  "results": [
    {
      "uuid": "string",
      "locale": "string",
      "term": "string",
      "translation": "string",
      "status": "unchecked|proposed|checked",
      "llm_instructions": "string",
      "proposals_count": 0
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 100,
    "unscoped_total": 500
  }
}
```

#### 2. Create New Term Proposal (`POST /api/localization/glossary_entries`)

**Controller**: `API::Localization::GlossaryEntriesController#create`
**Command**: `Localization::GlossaryEntryProposal::CreateAddition`
**Triggered By**: ProposeTermModal save action in `Table.tsx:102-125`

**Request Body**:

```json
{
  "glossary_entry": {
    "term": "string",
    "locale": "string",
    "translation": "string",
    "llm_instructions": "string"
  }
}
```

**Side Effects**:

- Creates new `GlossaryEntryProposal` with type `:addition`
- Sets proposal status to `:pending`
- Queues LLM verification via `VerifyWithLLM.defer(proposal)`
- Shows success toast notification
- Closes modal on success

### Key Flows

#### Search Flow

1. User types in search input (`Table.tsx:43-47`)
2. Input is debounced by 300ms (`Table.tsx:24`)
3. `setCriteria()` updates request query (`Table.tsx:26-28`)
4. `usePaginatedRequestQuery` automatically refetches data
5. Results update in real-time

#### Filtering Flow

1. User selects status tab (`Tabs.tsx:17-29`)
2. `setQuery()` updates request with new status and resets page
3. User selects locale (`LocaleSelect.tsx:51-58`)
4. `setQuery()` updates request with new locale filter and resets page
5. Data refetches automatically via query change

#### Proposal Creation Flow

1. User clicks "Propose" button (requires `mayCreateTranslationProposals` permission)
2. Modal opens with form fields (`Table.tsx:89-223`)
3. User fills term, description, locale, and translation
4. Form submits via `sendRequest` to create proposal endpoint
5. Success: Modal closes, toast shows, list may update
6. Error: Error toast displays, modal remains open

## Show Component (`show/index.tsx`)

### Purpose

Detailed view for editing individual glossary entries, handling different states and proposal workflows.

### Key Features

- **State-based rendering**: Different components based on entry status
- **Translation editing**: In-place editing for unchecked entries
- **Proposal management**: View, approve, reject, and edit proposals
- **Navigation**: Automatic redirect to next entry after actions
- **Permission-based actions**: Different UI based on user permissions

### Context Provider

```typescript
type GlossaryEntriesShowContextType = {
  glossaryEntry: GlossaryEntry;
  currentUserId: number;
  links: {
    localizationGlossaryEntriesPath: string;
    glossaryEntriesListPage: string;
    approveLlmTranslation: string;
    createProposal: string;
    approveProposal: string;
    rejectProposal: string;
    updateProposal: string;
    nextEntry: string;
  };
};
```

### Component States

The show component renders different subcomponents based on the entry's status:

#### 1. Unchecked State (`Unchecked.tsx`)

**When**: `glossaryEntry.status === 'unchecked'`
**Features**:

- Displays LLM-generated translation needing review
- In-place editing with textarea
- Local state management for edits
- Reset changes functionality

#### 2. Checked State (`Checked.tsx`)

**When**: `glossaryEntry.status === 'approved'` or `'rejected'`
**Features**:

- Read-only display
- Shows completion status
- No editing capabilities

#### 3. Proposed State (`Proposed/index.tsx`)

**When**: `glossaryEntry.status === 'proposed'`
**Features**:

- Displays all pending proposals
- Individual proposal cards with actions
- Approval/rejection workflow
- Edit functionality for own proposals

### API Calls

#### 1. Get Entry Details (`GET /api/localization/glossary_entries/:id`)

**Controller**: `API::Localization::GlossaryEntriesController#show`
**Purpose**: Load detailed entry data with proposals

**Side Effects**:

- Serializes entry via `SerializeLocalizationGlossaryEntry`
- Includes non-rejected proposals in response
- Provides all necessary data for rendering show view

**Response Structure**:

```json
{
  "glossary_entry": {
    "uuid": "string",
    "locale": "string",
    "term": "string",
    "translation": "string",
    "status": "unchecked|proposed|checked",
    "llm_instructions": "string",
    "proposals": [
      {
        "uuid": "string",
        "type": "addition|modification|deletion",
        "status": "pending|approved|rejected",
        "term": "string",
        "translation": "string",
        "llm_instructions": "string",
        "proposer_id": 123,
        "reviewer_id": 456
      }
    ]
  }
}
```

#### 2. Create Modification Proposal (`POST /api/localization/glossary_entry_proposals`)

**Controller**: `API::Localization::GlossaryEntryProposalsController#create`
**Command**: `Localization::GlossaryEntryProposal::CreateModification`
**Triggered By**: "Submit proposal" button in `Unchecked.tsx:25-34`

**Request Body**:

```json
{
  "translation": "new translation text"
}
```

**Side Effects**:

- Creates new proposal with type `:modification`
- Updates glossary entry status to `:proposed`
- Queues LLM verification via `VerifyWithLLM.defer(proposal)`
- Triggers automatic redirect to next entry
- Returns updated glossary entry data

#### 3. Approve Proposal (`PATCH /api/localization/glossary_entry_proposals/:id/approve`)

**Controller**: `API::Localization::GlossaryEntryProposalsController#approve`  
**Command**: `Localization::GlossaryEntryProposal::Approve`
**Triggered By**: Approve button in proposal cards
**Permission Required**: `user.may_manage_translation_proposals?` (20+ reputation)

**Side Effects**:

- Updates proposal status to `:approved`
- Sets reviewer to current user
- **For additions**: Creates new glossary entry with status `:checked`
- **For modifications**: Updates existing entry translation and sets status to `:checked`
- **For deletions**: Destroys the glossary entry
- Automatically redirects to next entry
- Returns updated glossary entry data

#### 4. Reject Proposal (`PATCH /api/localization/glossary_entry_proposals/:id/reject`)

**Controller**: `API::Localization::GlossaryEntryProposalsController#reject`
**Command**: `Localization::GlossaryEntryProposal::Reject`
**Triggered By**: Reject button in proposal cards
**Permission Required**: `user.may_manage_translation_proposals?` (20+ reputation)

**Side Effects**:

- Updates proposal status to `:rejected`
- Sets reviewer to current user
- **For modifications**: Resets entry status to `:unchecked` if no pending proposals remain
- Automatically redirects to next entry
- Returns updated glossary entry data

#### 5. Update Proposal (`PATCH /api/localization/glossary_entry_proposals/:id`)

**Controller**: `API::Localization::GlossaryEntryProposalsController#update`
**Triggered By**: Edit actions in proposal cards

**Logic**:

- **If current user is proposer**: Updates proposal value via `UpdateValue` command
- **If current user is different**: Rejects old proposal and creates new modification proposal

**Side Effects**:

- Either updates existing proposal or creates new one
- May trigger LLM verification for new proposals
- Returns updated glossary entry data

#### 6. Get Next Entry (`GET /api/localization/glossary_entries/next`)

**Controller**: `API::Localization::GlossaryEntriesController#next`
**Purpose**: Find next entry for navigation after completing actions
**Used By**: `useRequestWithNextRedirect.ts:15-27`

**Parameters**:

- `status`: Current entry status for filtering similar entries
- `locale`: Current locale for consistent navigation

**Side Effects**:

- Executes search with same filters to find next available entry
- Returns UUID of next entry or null if none available
- Used for automatic navigation workflow

### Key Flows

#### Navigation with Auto-Redirect Flow

1. User performs action (approve, reject, submit proposal)
2. `useRequestWithNextRedirect` hook handles the flow (`useRequestWithNextRedirect.ts:29-41`)
3. API call executes successfully
4. Hook calls `redirectToNext()` (`useRequestWithNextRedirect.ts:15-27`)
5. Fetches next entry with same status/locale parameters
6. Redirects to next entry URL for continued workflow

#### Unchecked Entry Editing Flow

1. User clicks "Edit Translation" (`Unchecked.tsx:89-94`)
2. Component enters edit mode with textarea
3. User modifies translation text
4. User clicks "Update" to save locally (`Unchecked.tsx:18-23`)
5. User clicks "Submit proposal" to save remotely (`Unchecked.tsx:25-34`)
6. Creates modification proposal via API
7. Automatically redirects to next entry

#### Proposal Review Flow (Multiple Proposals)

1. Entry has status "proposed" with multiple pending proposals
2. `Proposed/index.tsx` renders all proposals in cards
3. Reviewer sees all proposals with approve/reject options
4. **Approve action**:
   - Calls approve API endpoint
   - Proposal becomes approved, others automatically rejected
   - Entry status changes to "checked"
   - Auto-redirects to next entry
5. **Reject action**:
   - Calls reject API endpoint
   - Individual proposal becomes rejected
   - If all proposals rejected, entry returns to "unchecked"
   - Auto-redirects to next entry

## Models and Data Layer

### GlossaryEntry Model

```ruby
# app/models/localization/glossary_entry.rb
enum :status,
     {
       # Initial state during LLM generation
       # Needs human review
       # Has pending proposals
       generating: 0, unchecked: 1, proposed: 2, checked: 3 # Approved by reviewers
     }
```

**Relationships**:

- `has_many :proposals` - Associated modification proposals

### GlossaryEntryProposal Model

```ruby
# app/models/localization/glossary_entry_proposal.rb
enum type: {
       # Propose new glossary entry
       # Modify existing entry
       addition: 1, modification: 2, deletion: 3 # Delete existing entry
     }

enum :status,
     {
       # Awaiting review
       # Accepted by reviewer
       pending: 0, approved: 1, rejected: 2 # Rejected by reviewer
     }
```

**Relationships**:

- `belongs_to :glossary_entry, optional: true` - May not exist for additions
- `belongs_to :proposer, class_name: 'User'` - User who made proposal
- `belongs_to :reviewer, class_name: 'User', optional: true` - User who reviewed

## Permissions and Access Control

### Translation Permissions

- **View entries**: User must have translator locales configured (excludes `:en`)
- **Create proposals**: `mayCreateTranslationProposals` permission
- **Approve/reject proposals**: `mayManageTranslationProposals` permission (20+ reputation)

### Filtered Access

- Users only see entries for their configured translator locales
- Search and filters respect user's locale permissions
- Cannot access entries outside permitted locales

## Error Handling and Edge Cases

### API Error Handling

- All API calls include error boundaries and user-friendly error messages
- Toast notifications for success/failure states
- Graceful degradation when permissions are insufficient

### Edge Cases Handled

- **Empty results**: Shows "No glossary entries found" fallback
- **Permission changes**: Buttons become disabled when permissions revoked
- **Concurrent edits**: Update logic handles different users editing same proposal
- **Navigation failures**: Fallback when no next entry available
- **Malformed data**: Components gracefully handle missing or invalid data

## Performance Considerations

### Optimization Strategies

- **Pagination**: Limited to 24 entries per page by default
- **Debounced search**: 300ms delay prevents excessive API calls
- **Memoization**: Key data and computations are memoized
- **Context optimization**: Separate contexts prevent unnecessary re-renders
- **Lazy loading**: Proposal details loaded only when needed

### Caching

- Uses React Query (`usePaginatedRequestQuery`) for intelligent caching
- Cache keys include all filter parameters for proper invalidation
- Automatic background refetching keeps data fresh

This comprehensive system enables efficient localization workflow management with proper permissions, real-time updates, and smooth user experience for translators and reviewers.
