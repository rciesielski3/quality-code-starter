import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { basename, join } from 'node:path';

const agentsDir = '.claude/agents';
const settingsPath = '.claude/settings.json';
const agentsDoc = 'AGENTS.md';
const problems = [];

const parseFrontmatter = (text) => {
  const match = /^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/.exec(text);
  if (!match) return null;
  const fields = {};
  for (const line of match[1].split(/\r?\n/)) {
    const idx = line.indexOf(':');
    if (idx > 0) fields[line.slice(0, idx).trim()] = line.slice(idx + 1).trim();
  }
  return fields;
};

const roster = existsSync(agentsDoc) ? readFileSync(agentsDoc, 'utf8') : null;
if (roster === null) problems.push(`${agentsDoc}: missing`);

const files = readdirSync(agentsDir).filter((f) => f.endsWith('.md'));
if (files.length === 0) problems.push(`${agentsDir}: no agent files found`);

for (const file of files) {
  const path = join(agentsDir, file);
  const fields = parseFrontmatter(readFileSync(path, 'utf8'));
  if (!fields) {
    problems.push(`${path}: missing frontmatter`);
    continue;
  }
  const stem = basename(file, '.md');
  if (!fields.name) problems.push(`${path}: missing name`);
  else if (fields.name !== stem) problems.push(`${path}: name "${fields.name}" != filename "${stem}"`);
  if (!fields.description) problems.push(`${path}: missing description`);
  if (roster !== null && !roster.includes(`\`${stem}\``))
    problems.push(`${path}: "${stem}" not listed in ${agentsDoc}`);
  if (!fields.tools) problems.push(`${path}: missing tools`);
}

try {
  const settings = JSON.parse(readFileSync(settingsPath, 'utf8'));
  if (settings?.attribution?.commit !== '') problems.push(`${settingsPath}: attribution.commit must be ""`);
  if (settings?.attribution?.pr !== '') problems.push(`${settingsPath}: attribution.pr must be ""`);
  if (settings?.attribution?.sessionUrl !== false)
    problems.push(`${settingsPath}: attribution.sessionUrl must be false`);
} catch (error) {
  problems.push(`${settingsPath}: ${error instanceof Error ? error.message : 'unreadable'}`);
}

if (problems.length > 0) {
  for (const p of problems) process.stderr.write(`✖ ${p}\n`);
  process.exit(1);
}
process.stdout.write(`✔ ${String(files.length)} agents valid\n`);
