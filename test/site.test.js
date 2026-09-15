const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const root = path.join(__dirname, "..");
const html = fs.readFileSync(path.join(root, "index.html"), "utf8");

test("local page assets exist", () => {
  const references = [...html.matchAll(/(?:src|href)=["']([^"'#?]+)["']/g)]
    .map((match) => match[1])
    .filter((value) => !/^(?:https?:|tel:|mailto:|data:)/.test(value));
  for (const reference of references) {
    assert.ok(fs.existsSync(path.join(root, reference.replace(/^\//, ""))), `Missing local asset: ${reference}`);
  }
});

test("internal navigation targets exist", () => {
  const targets = [...html.matchAll(/href=["']#([^"']+)["']/g)].map((match) => match[1]);
  for (const target of targets) assert.match(html, new RegExp(`id=["']${target}["']`), `Missing section: #${target}`);
});

test("production page has no placeholder domains or missing-image references", () => {
  assert.doesNotMatch(html, /example\.com|placehold\.co|hero-car\.jpg|work-[1-6]\.jpg|og-image\.jpg/i);
});

test("structured business data is valid JSON", () => {
  const blocks = [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)];
  assert.ok(blocks.length > 0, "Expected LocalBusiness structured data");
  for (const block of blocks) assert.doesNotThrow(() => JSON.parse(block[1]));
});

test("Flutter application foundation is present", () => {
  const requiredFiles = [
    "app/pubspec.yaml",
    "app/analysis_options.yaml",
    "app/lib/main.dart",
    "app/lib/app/splash_auto_app.dart",
    "app/test/widget_test.dart",
    "app/web/index.html",
  ];

  for (const file of requiredFiles) {
    assert.ok(fs.existsSync(path.join(root, file)), `Missing Flutter app file: ${file}`);
  }
});
