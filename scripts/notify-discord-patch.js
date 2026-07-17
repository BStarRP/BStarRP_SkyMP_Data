/**
 * Post release patch notes to a Discord channel via webhook.
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
  .replace(/^\*\*Summary\*\*\s*$/gim, '**Summary**')
  .replace(/^\*\*Changes\*\*\s*$/gim, '**Changes**');

const MAX_DESC = 3900;
if (notes.length > MAX_DESC) {
  notes = `${notes.slice(0, MAX_DESC - 20).trimEnd()}\n\n…(truncated)`;
}

const tag = process.env.RELEASE_TAG || `v${version}`;
const repo = process.env.GITHUB_REPOSITORY || '';
const releaseUrl = repo
  ? `https://github.com/${repo}/releases/tag/${tag}`
  : '';

const embed = {
  title: `Server Update — Patch ${version}`,
  description: notes,
  color: 0x5865f2,
  timestamp: new Date().toISOString(),
};

if (releaseUrl) {
  embed.url = releaseUrl;
  embed.footer = { text: tag };
}

const body = {
  embeds: [embed],
  allowed_mentions: { parse: [] },
};

(async () => {
  const res = await fetch(webhook, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => '');
    console.error(`Discord webhook failed: HTTP ${res.status} ${text}`);
    process.exit(1);
  }
  console.log(`Posted patch ${version} notes to Discord`);
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
