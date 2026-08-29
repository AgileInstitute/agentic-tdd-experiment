# Spike findings: Facebook data export format

Story 1.1, using `sample facebook export.zip` (a real, JSON-format Facebook data export, ~2.4GB including media).

## Format

JSON (this export was requested in JSON format; Facebook also offers HTML — not investigated here). Post content lives in `posts/your_posts_1.json`: a flat array of 8,646 post objects, ordered oldest-to-newest by `timestamp`.

## Structure

Every post has:
- `timestamp` — Unix epoch, seconds.
- `data` — an array of content items.

Observed post shapes:

- **Text-only**: `data: [{"post": "..."}]`, no `attachments` key. **1,910 of 8,646 posts (22%)** match this exactly — a good starting slice for story 1.2. "Text-only" must be defined as: `data` contains a `post` key and nothing else, *and* there is no `attachments` key at all — some posts have a caption-less photo/check-in with no `post` text, and those are not text posts.
- **Photo/video**: adds an `attachments` array; each attachment's `data` includes a `media` object (`uri` pointing into `posts/media/...`, plus `creation_timestamp`, `title`, `description`).
- **Link share**: `attachments[].data[].external_context.url`.
- Other attachment `data` shapes seen: `place` (check-ins), `event`, `fundraiser`, `tags` (people tagged), `text`.
- `title` is a human-readable sentence Facebook generated (e.g. "Rob Myers updated his status.", "Rob Myers added a new photo."). Present on most non-text-only posts, often absent on plain status updates. Not a reliable type discriminator on its own — use presence/absence of `attachments` and the shape of `data` instead.
- **Tags**: a `tags` key shows up as a top-level sibling of `data`/`attachments`/`timestamp`/`title` (not nested inside either). Shape is a bare array of name-only objects, e.g. `"tags": [{"name": "John Doe"}]` — no user ID, no profile URL, nothing linkable. Appears (across several key-combination shapes) on **497 of 8,646 posts**. Since it's free text, there's no way to resolve a tag to an actual account from this export alone, and two tags with the same name aren't guaranteed to be the same person — a real limitation if tags are ever meant to be more than decorative. Future-schema territory, not a gotcha to fix now — neither 1.2 nor 1.3 touches it.

Example text-only post:

```json
{
  "timestamp": 1224121959,
  "data": [
    { "post": "is visiting Austin TX for the very first time!" }
  ],
  "title": "Rob Myers updated his status."
}
```

## Gotchas

1. **Mojibake in non-ASCII text.** Facebook's exporter mis-encodes non-ASCII characters: UTF-8 bytes get interpreted as Latin-1 codepoints before JSON-escaping, so `"pâté"` comes through the JSON as `"pÃ¢tÃ©"`. Affects **231 of the 1,910 text-only posts** in this sample. Fix on read: `text.encode('latin1').decode('utf8')` (Ruby: `text.encode('ISO-8859-1').force_encoding('UTF-8')`, roughly — needs verifying against Ruby's encoding API when we implement).
2. **"No `post` text" doesn't mean "no content."** 1,144 of 8,646 posts have no `post` key anywhere in `data` (`data` holds only `update_timestamp`/`backdated_timestamp`, which is metadata, not content). That splits three ways:
   - **1,029** have an `attachments` array carrying the real content — an uncaptioned photo, a bare link share, etc. `data` is just noise here; the content lives in `attachments`.
   - A subset of the remainder are **auto-generated activity posts** ("Rob Myers recommends The Hobbit.", "Rob Myers was with John Doe.") where the `title` sentence *is* the entire content — there's no separate caption because Facebook generated the whole narration.
   - **~29** are bare `{"timestamp": ..., "title": "Rob Myers updated his status."}` with no `data` content and no `attachments` — genuinely empty as far as this export goes (likely the original post was later deleted, or it predates Facebook capturing text/attachments the same way). Content is unrecoverable from this JSON.

   So the rule for finding a post's content isn't "does `data` have a `post` key" — check `data[].post` for text, `attachments[].data[]` for media/links/places, and fall back to `title` for auto-generated narrations. A small residue (~0.3%) has none of those and should just be skipped.
3. A few posts (5 in this sample) carry `backdated_timestamp` alongside the top-level `timestamp`, and it's the *user-intended display date*, not a repost/attribution artifact — all examples are the same user's own content. Two patterns observed:
   - **"Add old photos/video" backdating**: `title` says e.g. "...added a new photo from November 20, 2015." Facebook lets you backdate a post when uploaded media has an earlier EXIF capture date than the upload itself. `backdated_timestamp` sometimes matches the media's EXIF `taken_timestamp` exactly, sometimes not quite (EXIF can be approximate, or the user nudged the date manually).
   - **Manual "Edit Date"**: no EXIF gap, no "from `<date>`" title — a link share and a check-in in this sample, where the user seemingly just moved the post's displayed date after the fact.

   For import purposes: `backdated_timestamp` is the more meaningful "when did this happen" date and should be preferred for display when present, falling back to `timestamp` otherwise.
4. The full export archive is huge (2.4GB, almost entirely media in `posts/media/`). Story 1.2 (text-only import) only needs `posts/your_posts_1.json` — no need to unzip or process the rest of the archive for that story.

## Open questions for design (not yet decided)

- Where to do the mojibake fix — at import time, or should we detect and warn if it looks unfixed? (Leaning import time — see story 1.3.)
- How to detect mojibake safely: a blind `text.encode('latin1').decode('utf8')` isn't safe to apply to all text going forward. It fails loudly (raises, so we can skip) for anything outside the Latin-1 range (emoji, CJK, etc.), but genuinely correct UTF-8 text using accented Latin-1-range characters (e.g. "café") can, by coincidence, round-trip through that transform without raising and come out as different garbage. This export is from 2021 — if Facebook has since fixed the underlying bug, a blind transform risks corrupting clean future exports. Safer approach: detect known mojibake *signatures* first (e.g. `Ã©`, `Ã¨`, `â€™`, `Â ` — these arise because the UTF-8 lead bytes for common European accented characters, 0xC3/0xC2, always mojibake into `Ã`/`Â`) and only repair matches, rather than transforming everything and hoping exceptions catch the bad cases.
- Confirm the timestamp precedence for display: `backdated_timestamp` > `timestamp` (with `update_timestamp` treated as metadata, not a display date) — likely right based on findings above, but worth a deliberate decision before implementing.
