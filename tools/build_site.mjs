#!/usr/bin/env node
// Builds the public legal pages for Firebase Hosting from /docs/*.md:
//   /privacy, /terms, /delete-account (+ a small index).
// Support email, company and date come from lib/core/constants/app_constants.dart.
// Run: node tools/build_site.mjs   (firebase deploy runs it automatically)
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const constants = readFileSync(join(root, "lib/core/constants/app_constants.dart"), "utf8");
const constant = (name) => constants.match(new RegExp(`${name} = '([^']*)'`))?.[1] ?? "";

const values = {
  SUPPORT_EMAIL: constant("supportEmail"),
  LEGAL_ENTITY: constant("legalEntity"),
  EFFECTIVE_DATE: constant("legalEffectiveDate"),
};
const missing = Object.entries(values).filter(([, v]) => !v).map(([k]) => k);
if (missing.length) {
  console.error(`build_site: set ${missing.join(", ")} in lib/core/constants/app_constants.dart first.`);
  process.exit(1);
}

const escape = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const inline = (s) =>
  escape(s)
    .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
    .replace(/\*(.+?)\*/g, "<em>$1</em>")
    .replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2">$1</a>');

/** Tiny Markdown subset: headings, paragraphs, lists, tables, bold, italic, links. */
export function markdownToHtml(md) {
  const out = [];
  const lines = md.split("\n");
  for (let i = 0; i < lines.length; ) {
    const line = lines[i];
    const h = line.match(/^(#{1,3}) (.*)$/);
    if (h) {
      out.push(`<h${h[1].length}>${inline(h[2])}</h${h[1].length}>`);
      i++;
    } else if (/^\|/.test(line)) {
      const rows = [];
      while (i < lines.length && /^\|/.test(lines[i])) rows.push(lines[i++]);
      const cells = (r) => r.split("|").slice(1, -1).map((c) => inline(c.trim()));
      const body = rows.slice(2).map((r) => `<tr>${cells(r).map((c) => `<td>${c}</td>`).join("")}</tr>`);
      out.push(`<table><thead><tr>${cells(rows[0]).map((c) => `<th>${c}</th>`).join("")}</tr></thead><tbody>${body.join("")}</tbody></table>`);
    } else if (/^(- |\d+\. )/.test(line)) {
      const ordered = /^\d+\. /.test(line);
      const items = [];
      while (i < lines.length && /^(- |\d+\. )/.test(lines[i])) {
        items.push(`<li>${inline(lines[i++].replace(/^(- |\d+\. )/, ""))}</li>`);
      }
      out.push(ordered ? `<ol>${items.join("")}</ol>` : `<ul>${items.join("")}</ul>`);
    } else if (line.trim() === "") {
      i++;
    } else {
      const para = [];
      while (i < lines.length && lines[i].trim() !== "" && !/^(#|\||- |\d+\. )/.test(lines[i])) para.push(lines[i++]);
      out.push(`<p>${inline(para.join(" "))}</p>`);
    }
  }
  return out.join("\n");
}

const page = (title, body) => `<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escape(title)} · PauseAsk</title>
<style>
:root{color-scheme:light dark;--fg:#111827;--bg:#f7f9fc;--card:#fff;--accent:#0d3b66;--line:#d1d5db}
@media (prefers-color-scheme:dark){:root{--fg:#e5e7eb;--bg:#0b1220;--card:#111a2e;--accent:#8ab4f8;--line:#334155}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--fg);font:18px/1.6 system-ui,-apple-system,"Noto Sans",sans-serif}
main{max-width:760px;margin:0 auto;padding:24px 16px 48px}header a{color:var(--accent);font-weight:700;text-decoration:none}
h1{color:var(--accent);line-height:1.25}h2{margin-top:2em}a{color:var(--accent)}
table{width:100%;border-collapse:collapse;background:var(--card);display:block;overflow-x:auto}
th,td{border:1px solid var(--line);padding:8px 10px;text-align:left;vertical-align:top}
footer{margin-top:3em;font-size:15px;opacity:.8}
</style></head><body><main>
<header><a href="/">PauseAsk</a> · Pause. Ask family. Stay safe.</header>
${body}
<footer><a href="/privacy">Privacy</a> · <a href="/terms">Terms</a> · <a href="/delete-account">Delete account</a> · © ${escape(values.LEGAL_ENTITY)}</footer>
</main></body></html>
`;

const fill = (s) => s.replace(/\{\{(\w+)\}\}/g, (_, k) => values[k] ?? `{{${k}}}`);
const outDir = join(root, "site");
mkdirSync(outDir, { recursive: true });
const pages = [
  ["privacy", "privacy-policy.md", "Privacy Policy"],
  ["terms", "terms.md", "Terms of Use"],
  ["delete-account", "delete-account.md", "Delete your account"],
];
for (const [slug, file, title] of pages) {
  const md = fill(readFileSync(join(root, "docs", file), "utf8"));
  writeFileSync(join(outDir, `${slug}.html`), page(title, markdownToHtml(md)));
}
writeFileSync(
  join(outDir, "index.html"),
  page("PauseAsk", `<h1>PauseAsk</h1><p>Helps families stop scams: pause before acting on a suspicious message and ask your family with one tap.</p>
<ul><li><a href="/privacy">Privacy Policy</a></li><li><a href="/terms">Terms of Use</a></li><li><a href="/delete-account">Delete your account and data</a></li></ul>`),
);
console.log(`build_site: wrote ${pages.length + 1} pages to site/`);
