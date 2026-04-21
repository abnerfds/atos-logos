// Prints a per-file coverage table for the mobile select-church flow.
// Run from atos_logos_mobile/ root after `flutter test --coverage`.
//
// Mirrors the shape of `coverage_login.js` and `coverage_register.js`.
// The select-church flow shares most of its plumbing with login (cubit,
// repository, interceptor, router, models). This report focuses on
// the page + helpers specific to this flow, with the shared pieces
// included for visibility.
const fs = require('fs');
const path = require('path');

const lcovPath = path.join(__dirname, '..', 'coverage', 'lcov.info');
if (!fs.existsSync(lcovPath)) {
  console.error('coverage/lcov.info not found — run `flutter test --coverage` first.');
  process.exit(1);
}

// ── Select-church flow scope ───────────────────────────────────────────────
const selectChurchPathSuffixes = [
  'lib/features/auth/presentation/pages/church_selection_page.dart',
  'lib/features/auth/domain/models/church_option.dart',
  'lib/features/auth/domain/models/select_church_request.dart',
  // Shared with login but exercised by select-church too:
  'lib/features/auth/presentation/cubit/auth_cubit.dart',
  'lib/features/auth/data/auth_repository.dart',
  'lib/features/auth/domain/models/auth_response.dart',
  'lib/core/error/exceptions.dart',
];

// ── Documented exclusions ──────────────────────────────────────────────────
const EXCLUSIONS = [
  // No exclusions today — the select-church page has no provably-uncoverable
  // lines. Add entries here only with a written reason if a line is
  // unreachable from unit tests (decorator metadata, debug-only closures,
  // framework wiring, etc.).
];

// ── Parse lcov.info ────────────────────────────────────────────────────────
const lcov = fs.readFileSync(lcovPath, 'utf8');
const records = lcov.split('end_of_record').filter((r) => r.trim());

const isGenerated = (p) => /(\.freezed\.dart|\.g\.dart|\.config\.dart)$/.test(p);

function parseRecord(rec) {
  const lines = rec.split(/\r?\n/).filter(Boolean);
  const sfLine = lines.find((l) => l.startsWith('SF:'));
  if (!sfLine) return null;
  const sf = sfLine.slice(3).split('\\').join('/');
  const daEntries = lines
    .filter((l) => l.startsWith('DA:'))
    .map((l) => l.slice(3).split(','))
    .map(([line, hits]) => ({ line: Number(line), hits: Number(hits) }));
  return { sf, daEntries };
}

function exclusionFor(sf) {
  return EXCLUSIONS.find((e) => sf.endsWith(e.file));
}

function computeStats(record) {
  const exclusion = exclusionFor(record.sf);
  const excluded = exclusion ? exclusion.lines : new Set();

  let totalLines = 0;
  let hitLines = 0;
  const uncovered = [];
  let excludedHit = 0;
  for (const { line, hits } of record.daEntries) {
    if (excluded.has(line)) {
      excludedHit += 1;
      continue;
    }
    totalLines += 1;
    if (hits > 0) {
      hitLines += 1;
    } else {
      uncovered.push(line);
    }
  }
  return { totalLines, hitLines, uncovered, excludedCount: excludedHit };
}

// ── Collect select-church flow files ───────────────────────────────────────
const parsed = records.map(parseRecord).filter(Boolean);
const flowFiles = parsed.filter((p) => {
  if (isGenerated(p.sf)) return false;
  return selectChurchPathSuffixes.some((sfx) => p.sf.endsWith(sfx));
});
flowFiles.sort((a, b) => a.sf.localeCompare(b.sf));

// ── Render ─────────────────────────────────────────────────────────────────
const pct = (hit, total) =>
  total === 0 ? '---' : `${((hit / total) * 100).toFixed(1)}%`;

console.log('');
console.log('Select-Church Flow — Mobile Coverage Report');
console.log('='.repeat(106));
console.log(
  'File'.padEnd(60) +
    'Covered'.padStart(18) +
    'Excluded'.padStart(12) +
    'Status'.padStart(15),
);
console.log('-'.repeat(106));

let grandTotal = 0;
let grandHit = 0;
let grandExcluded = 0;

for (const record of flowFiles) {
  const stats = computeStats(record);
  grandTotal += stats.totalLines;
  grandHit += stats.hitLines;
  grandExcluded += stats.excludedCount;

  const short = record.sf.replace(/^.*?(lib\/)/, 'lib/');
  const coveredCell = `${stats.hitLines}/${stats.totalLines} (${pct(stats.hitLines, stats.totalLines)})`;
  const excludedCell = stats.excludedCount ? `${stats.excludedCount}` : '-';
  const status =
    stats.totalLines === 0
      ? 'empty'
      : stats.hitLines === stats.totalLines
        ? '✓ 100%'
        : `${stats.uncovered.length} miss`;
  console.log(
    short.padEnd(60) +
      coveredCell.padStart(18) +
      excludedCell.padStart(12) +
      status.padStart(15),
  );
  if (stats.uncovered.length) {
    const list = stats.uncovered.slice(0, 20).join(', ');
    const more =
      stats.uncovered.length > 20 ? ` (+${stats.uncovered.length - 20} more)` : '';
    console.log(`  ↳ uncovered: ${list}${more}`);
  }
}

console.log('-'.repeat(106));
const totalCell = `${grandHit}/${grandTotal} (${pct(grandHit, grandTotal)})`;
console.log(
  'TOTAL (select-church flow, excl. documented skips)'.padEnd(60) +
    totalCell.padStart(18) +
    `${grandExcluded}`.padStart(12),
);

if (EXCLUSIONS.length) {
  console.log('');
  console.log('Documented exclusions:');
  for (const e of EXCLUSIONS) {
    console.log(`  • ${e.file} [${[...e.lines].join(', ')}]`);
    console.log(`    ${e.reason}`);
  }
}
console.log('');
