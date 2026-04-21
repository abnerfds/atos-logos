// Prints a per-file coverage table for the mobile members (secretariat) flow.
// Run from atos_logos_mobile/ root after `flutter test --coverage`.
//
// Mirrors coverage_home.js / coverage_login.js / coverage_register.js / coverage_select_church.js.
// Scopes to the /members feature + the new core/enums it depends on.
const fs = require('fs');
const path = require('path');

const lcovPath = path.join(__dirname, '..', 'coverage', 'lcov.info');
if (!fs.existsSync(lcovPath)) {
  console.error('coverage/lcov.info not found — run `flutter test --coverage` first.');
  process.exit(1);
}

// Members flow scope
const memberPathSuffixes = [
  // Members feature
  'lib/features/members/data/members_repository.dart',
  'lib/features/members/domain/models/member_profile.dart',
  'lib/features/members/domain/models/membership.dart',
  'lib/features/members/presentation/cubit/members_cubit.dart',
  'lib/features/members/presentation/cubit/members_state.dart',
  'lib/features/members/presentation/pages/create_member_page.dart',
  'lib/features/members/presentation/pages/edit_member_page.dart',
  'lib/features/members/presentation/pages/members_page.dart',
  'lib/features/members/presentation/widgets/inactivate_member_dialog.dart',
  // Identity enums introduced for the form
  'lib/core/enums/sex.dart',
  'lib/core/enums/civil_status.dart',
];

// Documented exclusions
const EXCLUSIONS = [
  // No exclusions today.
];

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

const parsed = records.map(parseRecord).filter(Boolean);
const flowFiles = parsed.filter((p) => {
  if (isGenerated(p.sf)) return false;
  return memberPathSuffixes.some((sfx) => p.sf.endsWith(sfx));
});
flowFiles.sort((a, b) => a.sf.localeCompare(b.sf));

const pct = (hit, total) =>
  total === 0 ? '---' : `${((hit / total) * 100).toFixed(1)}%`;

console.log('');
console.log('Members Flow — Mobile Coverage Report');
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
  'TOTAL (members flow, excl. documented skips)'.padEnd(60) +
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
