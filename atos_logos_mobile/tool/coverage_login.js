// Prints a per-file coverage table for the mobile login flow.
// Run from atos_logos_mobile/ root after `flutter test --coverage`.
//
// Supports an explicit exclusion map for lines that are intentionally
// uncoverable from unit tests (framework wiring, debug-only closures, route
// builders for non-login screens, etc.). Every exclusion must carry a human
// reason so future maintainers can re-evaluate it.
const fs = require('fs');
const path = require('path');

const lcovPath = path.join(__dirname, '..', 'coverage', 'lcov.info');
if (!fs.existsSync(lcovPath)) {
  console.error('coverage/lcov.info not found — run `flutter test --coverage` first.');
  process.exit(1);
}

// ── Login flow scope ────────────────────────────────────────────────────────
// Files that make up the login flow on the mobile side.
const loginPathSuffixes = [
  'lib/features/auth/data/auth_repository.dart',
  'lib/features/auth/presentation/cubit/auth_cubit.dart',
  'lib/features/auth/presentation/cubit/auth_state.dart',
  'lib/features/auth/presentation/pages/login_page.dart',
  'lib/features/auth/domain/models/login_request.dart',
  'lib/features/auth/domain/models/auth_response.dart',
  'lib/features/auth/domain/models/church_option.dart',
  'lib/features/auth/domain/models/select_church_request.dart',
  'lib/features/auth/domain/models/user_profile.dart',
  'lib/core/network/auth_interceptor.dart',
  'lib/core/network/dio_client.dart',
  'lib/core/navigation/auth_redirect.dart',
  'lib/core/navigation/app_router.dart',
  'lib/core/error/exceptions.dart',
];

// ── Documented exclusions ───────────────────────────────────────────────────
// Each entry: { file (suffix), lines (Set of numbers), reason }.
// Lines here are subtracted from both the uncovered list AND the denominators
// so the reported coverage reflects "intentional scope" of the login flow.
const EXCLUSIONS = [
  {
    file: 'lib/core/network/dio_client.dart',
    lines: new Set([42]),
    reason:
      'Debug-only LogInterceptor.logPrint closure. Only fires on real HTTP traffic in debug builds; not login business logic.',
  },
  {
    file: 'lib/core/navigation/app_router.dart',
    // Route builders for screens outside the login flow (home, members,
    // profile edit, branches, etc.). Their bodies will be covered by the
    // respective feature-flow audits, not by the login audit.
    lines: new Set([
      44, 48, 52, // /register, /select-church, /home builders
      56, 57, // /secretaria
      63, // /create-member
      67, 68, 69, // /member-profile/:id
      74, 75, // /edit-profile
      81, 82, 83, // /edit-member/:id
      88, 89, // /branches
      95, 96, // /create-branch
      102, // /coming-soon
    ]),
    reason:
      'Route builders for non-login screens. The login-relevant code (redirect + /login builder) is covered by the app_router_test widget test; these other builders will be covered by each feature flow audit.',
  },
];

// ── Parse lcov.info ─────────────────────────────────────────────────────────
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
  const excludedHit = [];
  for (const { line, hits } of record.daEntries) {
    if (excluded.has(line)) {
      excludedHit.push(line);
      continue;
    }
    totalLines += 1;
    if (hits > 0) {
      hitLines += 1;
    } else {
      uncovered.push(line);
    }
  }
  return { totalLines, hitLines, uncovered, excludedCount: excludedHit.length };
}

// ── Collect login-flow files ────────────────────────────────────────────────
const parsed = records.map(parseRecord).filter(Boolean);
const loginFiles = parsed.filter((p) => {
  if (isGenerated(p.sf)) return false;
  return loginPathSuffixes.some((sfx) => p.sf.endsWith(sfx));
});
loginFiles.sort((a, b) => a.sf.localeCompare(b.sf));

// ── Render ──────────────────────────────────────────────────────────────────
const pct = (hit, total) =>
  total === 0 ? '---' : `${((hit / total) * 100).toFixed(1)}%`;

console.log('');
console.log('Login Flow — Mobile Coverage Report');
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

for (const record of loginFiles) {
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
  'TOTAL (login flow, excl. documented skips)'.padEnd(60) +
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
