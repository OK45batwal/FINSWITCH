import { chromium } from 'playwright';
import { writeFileSync, mkdirSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const assets = resolve(__dirname, '..', 'assets');
const android = resolve(__dirname, '..', 'flutter_app/android/app/src/main/res');

const sizes = {
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

async function generateIcon(browser, size) {
  const p = await browser.newPage({ viewport: { width: size, height: size }, deviceScaleFactor: 1 });
  await p.setContent(`<html><body style="margin:0;display:flex;align-items:center;justify-content:center;height:100vh;background:transparent">
<svg viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}">
<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stop-color="#1D4ED8"/><stop offset="100%" stop-color="#2563EB"/></linearGradient></defs>
<rect width="512" height="512" rx="104" fill="url(#g)"/>
<path d="M200 380V132h80c32 0 56 8 72 24s24 36 24 60c0 28-10 50-30 66s-48 24-84 24h-38l92 74" stroke="#F8FAFC" stroke-width="36" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
<path d="M280 200l-80 0" stroke="#fff" stroke-width="20" stroke-linecap="round" fill="none" opacity="0.4"/>
</svg></body></html>`);
  const buf = await p.screenshot({ path: `/tmp/icon-${size}.png` });
  await p.close();
  return `/tmp/icon-${size}.png`;
}

async function run() {
  const browser = await chromium.launch();
  
  // Generate master 1024x1024
  console.log('Generating master icon...');
  const master = await generateIcon(browser, 1024);
  writeFileSync(resolve(assets, 'app-icon-1024.png'), '');
  
  // Copy as app-icon.png
  const p = await browser.newPage({ viewport: { width: 1024, height: 1024 }, deviceScaleFactor: 1 });
  await p.setContent(`<html><body style="margin:0;display:flex;align-items:center;justify-content:center;height:100vh;background:transparent">
<svg viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg" width="1024" height="1024">
<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stop-color="#1D4ED8"/><stop offset="100%" stop-color="#2563EB"/></linearGradient></defs>
<rect width="512" height="512" rx="104" fill="url(#g)"/>
<path d="M200 380V132h80c32 0 56 8 72 24s24 36 24 60c0 28-10 50-30 66s-48 24-84 24h-38l92 74" stroke="#F8FAFC" stroke-width="36" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
<path d="M280 200l-80 0" stroke="#fff" stroke-width="20" stroke-linecap="round" fill="none" opacity="0.4"/>
</svg></body></html>`);
  await p.screenshot({ path: resolve(assets, 'app-icon.png') });
  await p.close();

  // Generate Android icons for each density
  for (const [dir, size] of Object.entries(sizes)) {
    console.log(`  ${dir} (${size}x${size})`);
    const p2 = await browser.newPage({ viewport: { width: size, height: size }, deviceScaleFactor: 1 });
    await p2.setContent(`<html><body style="margin:0;display:flex;align-items:center;justify-content:center;height:100vh;background:transparent">
<svg viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}">
<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stop-color="#1D4ED8"/><stop offset="100%" stop-color="#2563EB"/></linearGradient></defs>
<rect width="512" height="512" rx="104" fill="url(#g)"/>
<path d="M200 380V132h80c32 0 56 8 72 24s24 36 24 60c0 28-10 50-30 66s-48 24-84 24h-38l92 74" stroke="#F8FAFC" stroke-width="36" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
<path d="M280 200l-80 0" stroke="#fff" stroke-width="20" stroke-linecap="round" fill="none" opacity="0.4"/>
</svg></body></html>`);
    await p2.screenshot({ path: resolve(android, dir, 'ic_launcher.png') });
    await p2.close();
  }

  await browser.close();
  console.log('Done! All icons generated.');
}

run().catch(e => { console.error(e); process.exit(1); });
