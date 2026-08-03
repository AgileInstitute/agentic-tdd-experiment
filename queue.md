# Queue

See `docs/working_agreement.md` for the format: themes (`## N. Theme name`) grouping numbered stories (`### N.M Headline`), each with a description and `- [ ] started` / `- [ ] done` checkboxes. Spikes are stories tagged `(spike)` in the headline. Completed stories move to `story_archive.md` during periodic retrospectives.

## 1. Facebook Import

### 1.1 Parse a Facebook data export (spike)
Investigate whether/how we can parse a Facebook data export archive into structured data the app can use.
- Examples:
  - Given a real Facebook export, identify the format (JSON/HTML) and locate where post content lives
  - Extract text and timestamp for a handful of posts
  - Document findings (format, structure, gotchas) for the team to design against

- [x] started
- [x] done

### 1.2 Import and display a text-only post
A user can import a single text-only post from a Facebook export and see it on their journal.
- Examples:
  - A text post "Had a great day today!" from the export becomes a post in the app with that text
  - The imported post appears on the user's timeline
  - A post with only text (no photos/links) imports cleanly

- [x] started
- [x] done

### 1.3 Repair mis-encoded characters on import
Facebook's export mis-encodes non-ASCII text (UTF-8 bytes double-encoded as Latin-1 before JSON-escaping, e.g. "pâté" comes through as "pÃ¢tÃ©"). We repair this once at import time so every downstream consumer (display, future search, federation) sees correct text.
- Examples:
  - A post containing "pÃ¢tÃ©" in the raw export is stored/displayed as "pâté"
  - A post with only plain ASCII text is unaffected by the repair
  - Correctly-encoded text (e.g. from a future export where Facebook has fixed the bug) is left untouched, not mangled by a false-positive "fix"

- [x] started
- [x] done

### 1.4 Import a post with a photo
A user can import a Facebook post that has an uncaptioned (or captioned) photo attachment and see it on their journal, not have it silently skipped.
- Examples:
  - A post with one photo and no caption text imports and displays the photo
  - A post with one photo and caption text imports both
  - A post with multiple photos imports all of them

- [ ] started
- [ ] done

### 1.5 Import a link-share post
A user can import a Facebook post that's just a shared link (no photo) and see it on their journal.
- Examples:
  - A post whose only attachment is `external_context.url` imports with that URL
  - A link share with added commentary text imports both the text and the link

- [ ] started
- [ ] done

### 1.6 Import an auto-generated activity post
Some exported posts have no `data[].post` text and no attachments — the entire content is Facebook's generated narration in `title` (e.g. "Rob Myers recommends The Hobbit."). We import these using `title` as the post text instead of skipping them.
- Examples:
  - A post with only a `title` sentence and no `data`/`attachments` imports using that sentence as its text
  - A post with real `data`/`attachments` content is unaffected — `title` is never preferred over actual content

- [ ] started
- [ ] done

### 1.7 Prefer backdated_timestamp for post date
When a post's `data` includes a `backdated_timestamp`, it reflects when the post actually happened, not when it was entered into Facebook — we should display that instead of `timestamp` when it's present.
- Examples:
  - A post with both `timestamp` and `backdated_timestamp` displays using `backdated_timestamp`
  - A post with only `timestamp` displays using `timestamp`, as today

- [ ] started
- [ ] done

## 2. Federation

### 2.1 Get discoverable and exchange one activity with a real server (spike)
Investigate what's needed to make our app speak ActivityPub with the outside world, starting from zero.
- Examples:
  - Our server exposes a WebFinger endpoint that resolves a handle like @rob@example.com to an actor document
  - The actor document includes inbox/outbox URLs and a public key
  - Successfully send or receive one signed activity to/from a real ActivityPub server (e.g., a test Mastodon account)
  - Document what we learned: what's required, what's optional, where the friction is

- [x] started
- [ ] done

## 3. UI

## 4. Host monetization

## 5. Search
