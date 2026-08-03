/**
 * Post release patch notes to a Discord channel via webhook.
 * Splits across 2nd/3rd/... messages when notes exceed one embed description.
 *
 * Usage:
 *   node scripts/notify-discord-patch.js <version> [notes-file]
 *
 * Env:
 *   DISCORD_WEBHOOK_URL — required (Discord channel webhook)
 *   GITHUB_REPOSITORY — optional (owner/repo for release link)
 *   RELEASE_TAG — optional (e.g. v0.39.0); defaults to v<version>
 */
const fs = require('fs');

const version = (process.argv[2] || process.env.VERSION || '').replace(/^v/, '');
const notesFile = process.argv[3] || 'release-notes.md';
const webhook = process.env.DISCORD_WEBHOOK_URL;

if (!webhook) {
  console.log('DISCORD_WEBHOOK_URL not set; skipping Discord notify');
  process.exit(0);
}
if (!version) {
  console.error('Usage: node scripts/notify-discord-patch.js <version> [notes-file]');
  process.exit(1);
}

let notes = '';
if (fs.existsSync(notesFile)) {
  notes = fs.readFileSync(notesFile, 'utf8').trim();
} else if (fs.existsSync('patch-notes.md')) {
  notes = fs.readFileSync('patch-notes.md', 'utf8').trim();
}

if (!notes) {
  console.log('No patch notes found; skipping Discord notify');
  process.exit(0);
}

// Discord embeds: keep description readable; drop duplicate top title
notes = notes
  .replace(/^#\s*Patch notes\s*\n+/i, '')
  .replace(/^#?\s*Patch\s+[\d.]+\s*\n+/i, '')
  .trim();

// Prefer Discord-friendly emphasis over ATX headers
notes = notes
  .replace(/^##\s+(.+)$/gm, '**$1**')
  .replace(/^###\s+(.+)$/gm, '**$1**')
  .replace(/^\*\*Summary\*\*\s*$/gim, '**Summary**')
  .replace(/^\*\*Changes\*\*\s*$/gim, '**Changes**');

// Discord embed description hard limit is 4096; leave headroom for safety.
const MAX_DESC = 3900;

/**
 * Split notes into chunks that fit Discord embed descriptions.
 * Prefers breaking on blank lines, then single newlines, then hard cut.
 */
function splitNotes(text, maxLen) {
  const src = String(text || '').trim();
  if (!src) return [];
  if (src.length <= maxLen) return [src];

  const chunks = [];
  let rest = src;
  while (rest.length > maxLen) {
    let cut = rest.lastIndexOf('\n\n', maxLen);
    if (cut < Math.floor(maxLen * 0.4)) {
      cut = rest.lastIndexOf('\n', maxLen);
    }
    if (cut < Math.floor(maxLen * 0.4)) {
      cut = maxLen;
    }
    chunks.push(rest.slice(0, cut).trimEnd());
    rest = rest.slice(cut).replace(/^\n+/, '').trimStart();
  }
  if (rest) chunks.push(rest);
  return chunks;
}

const parts = splitNotes(notes, MAX_DESC);
const tag = process.env.RELEASE_TAG || `v${version}`;
const repo = process.env.GITHUB_REPOSITORY || '';
const releaseUrl = repo ? `https://github.com/${repo}/releases/tag/${tag}` : '';

function buildBody(description, partIndex, partCount) {
  const cont =
    partCount > 1 ? ` (${partIndex + 1}/${partCount})` : '';
  const embed = {
    title:
      partIndex === 0
        ? `Server Update — Patch ${version}${cont}`
        : `Server Update — Patch ${version} (cont. ${partIndex + 1}/${partCount})`,
    description,
    color: 0x5865f2,
    timestamp: new Date().toISOString(),
  };

  if (releaseUrl && partIndex === 0) {
    embed.url = releaseUrl;
    embed.footer = { text: tag };
  } else if (releaseUrl && partIndex === partCount - 1) {
    embed.footer = { text: tag };
  }

  return {
    embeds: [embed],
    allowed_mentions: { parse: [] },
  };
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

(async () => {
  for (let i = 0; i < parts.length; i++) {
    const res = await fetch(webhook, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(buildBody(parts[i], i, parts.length)),
    });
    if (!res.ok) {
      const text = await res.text().catch(() => '');
      console.error(`Discord webhook failed on part ${i + 1}/${parts.length}: HTTP ${res.status} ${text}`);
      process.exit(1);
    }
    // Avoid Discord webhook rate limits when posting back-to-back.
    if (i + 1 < parts.length) await sleep(600);
  }
  console.log(
    parts.length === 1
      ? `Posted patch ${version} notes to Discord`
      : `Posted patch ${version} notes to Discord in ${parts.length} messages`
  );
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
