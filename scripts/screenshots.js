import { chromium } from 'playwright';
import { writeFileSync, mkdirSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const out = resolve(__dirname, '..', 'assets');
mkdirSync(out, { recursive: true });

const BASE = 'http://localhost:3000';
const APP_WIDTH = 390;

function appHTML(page, name) {
  const screens = {
    home: {
      title: 'Home',
      body: `
        <div style="padding:20px">
          <div style="background:linear-gradient(135deg,#1D4ED8,#2563EB);border-radius:20px;padding:24px;color:#fff;margin-bottom:16px">
            <div style="opacity:.6;font-size:12px">Portfolio Value</div>
            <div style="font-size:28px;font-weight:800;letter-spacing:-1px">₹12,45,890</div>
            <div style="margin-top:6px;display:flex;gap:12px">
              <span style="background:rgba(16,185,129,.2);padding:3px 8px;border-radius:6px;font-size:11px;font-weight:600">+2.34% today</span>
              <span style="font-size:12px;opacity:.7">Net +₹28,450</span>
            </div>
          </div>
          <div style="display:flex;justify-content:space-around;margin-bottom:20px">
            ${['Invest','SIP','Sell','History'].map(l => `
              <div style="text-align:center">
                <div style="width:44px;height:44px;background:rgba(37,99,235,.15);border-radius:14px;display:flex;align-items:center;justify-content:center;margin:0 auto 6px">
                  <div style="width:18px;height:18px;border-radius:4px;background:#2563EB"></div>
                </div>
                <div style="font-size:11px;color:#64748B">${l}</div>
              </div>
            `).join('')}
          </div>
          <div style="background:#131D2E;border-radius:16px;padding:16px;border:1px solid rgba(255,255,255,.08);margin-bottom:16px">
            ${[['NIFTY 50','24,682.75','+0.76%'],['SENSEX','81,523.40','+0.76%'],['BANK NIFTY','52,891.15','-0.23%']].map(([n,v,c]) => `
              <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid rgba(255,255,255,.06)">
                <span style="color:#64748B;font-size:13px">${n}</span>
                <span style="text-align:right"><span style="font-weight:700;font-size:14px;color:#F8FAFC">${v}</span><br><span style="font-size:11px;font-weight:600;color:${c.startsWith('+')?'#10B981':'#EF4444'}">${c}</span></span>
              </div>
            `).join('')}
          </div>
        </div>`
    },
    markets: {
      title: 'Markets',
      body: `
        <div style="padding:20px">
          <div style="background:linear-gradient(135deg,#0F2239,#1A2538);border-radius:20px;padding:20px;display:flex;justify-content:space-around;border:1px solid rgba(255,255,255,.08);margin-bottom:20px">
            ${[['NIFTY','24,682','+0.76%'],['SENSEX','81,523','+0.76%'],['BANK NIFTY','52,891','-0.23%']].map(([n,v,c]) => `
              <div style="text-align:center"><div style="color:#64748B;font-size:11px">${n}</div><div style="font-weight:700;font-size:13px;color:#F8FAFC;margin:4px 0">${v}</div><div style="font-size:11px;font-weight:600;color:${c.startsWith('+')?'#10B981':'#EF4444'}">${c}</div></div>
            `).join('')}
          </div>
          ${[['RELIANCE',2890.45,'+12.30','₹2.3T'],['TCS',4120.80,'+45.20','₹1.5T'],['HDFCBANK',1678.25,'-8.50','₹9.4L'],['INFY',1892.60,'+32.40','₹8.1L']].map(([s,p,c,m]) => `
            <div style="display:flex;align-items:center;gap:12px;padding:14px 16px;background:#131D2E;border-radius:14px;border:1px solid rgba(255,255,255,.08);margin-bottom:8px">
              <div style="width:36px;height:36px;background:rgba(37,99,235,.15);border-radius:10px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:14px;color:#2563EB">${s[0]}</div>
              <div style="flex:1"><div style="font-weight:700;font-size:13px;color:#F8FAFC">${s}</div><div style="color:#64748B;font-size:11px">${m}</div></div>
              <div style="text-align:right"><div style="font-weight:700;font-size:13px;color:#F8FAFC">₹${p.toFixed(2)}</div><div style="font-size:11px;font-weight:600;color:${c.startsWith('+')?'#10B981':'#EF4444'}">${c}</div></div>
            </div>
          `).join('')}
        </div>`
    },
    ai: {
      title: 'AI Chat',
      body: `
        <div style="padding:20px;display:flex;flex-direction:column;gap:12px">
          <div style="display:flex;gap:10px">
            <div style="width:28px;height:28px;background:rgba(56,189,248,.2);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:12px">✦</div>
            <div style="background:#1A2538;padding:12px 14px;border-radius:14px 14px 14px 4px;max-width:80%">
              <div style="font-size:13px;color:#F8FAFC;line-height:1.5">Hi! I'm your financial intelligence assistant. Ask me about any stock or investment.</div>
            </div>
          </div>
          <div style="display:flex;gap:10px;justify-content:flex-end">
            <div style="background:#2563EB;padding:12px 14px;border-radius:14px 14px 4px 14px;max-width:70%">
              <div style="font-size:13px;color:#fff;line-height:1.5">Analyze TCS for long term investment</div>
            </div>
          </div>
          <div style="display:flex;gap:10px">
            <div style="width:28px;height:28px;background:rgba(56,189,248,.2);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:12px">✦</div>
            <div style="background:#1A2538;padding:12px 14px;border-radius:14px 14px 14px 4px;max-width:85%">
              <div style="font-size:13px;color:#F8FAFC;line-height:1.5">TCS has strong fundamentals: P/E 28.6, Revenue CAGR 11.4%, FCF Yield 3.2%. Consider SIP for rupee-cost averaging. Would you like a detailed report?</div>
            </div>
          </div>
          <div style="margin-top:auto;display:flex;gap:8px;padding:12px 0;border-top:1px solid rgba(255,255,255,.08)">
            <div style="background:#1A2538;flex:1;border-radius:12px;padding:12px 14px;color:#64748B;font-size:13px">Ask about stocks, markets...</div>
            <div style="width:44px;height:44px;background:#2563EB;border-radius:12px;display:flex;align-items:center;justify-content:center;color:#fff">↑</div>
          </div>
        </div>`
    },
    portfolio: {
      title: 'Portfolio',
      body: `
        <div style="padding:20px">
          <div style="background:linear-gradient(135deg,#1E3A5F,#131D2E);border-radius:20px;padding:24px;border:1px solid rgba(255,255,255,.08);margin-bottom:20px">
            <div style="display:flex;justify-content:space-between;margin-bottom:12px">
              ${[['Total Value','₹12,45,890'],['Invested','₹11,20,000'],['Returns','+₹1,25,890']].map(([l,v]) => `
                <div style="text-align:center"><div style="color:#64748B;font-size:11px">${l}</div><div style="font-weight:700;font-size:13px;color:#F8FAFC;margin-top:4px">${v}</div></div>
              `).join('')}
            </div>
            <div style="background:rgba(16,185,129,.1);border-radius:10px;padding:10px;text-align:center">
              <span style="color:#10B981;font-size:12px;font-weight:600">↗ Portfolio up 2.34% today</span>
            </div>
          </div>
          ${[['RELIANCE','Reliance Industries',10,'₹28,904','+1.42%'],['TCS','Tata Consultancy Services',5,'₹20,604','+1.75%'],['HDFCBANK','HDFC Bank',20,'₹33,565','+1.71%'],['INFY','Infosys',15,'₹28,389','+2.30%']].map(([s,n,q,v,p]) => `
            <div style="display:flex;align-items:center;gap:12px;padding:14px 16px;background:#131D2E;border-radius:14px;border:1px solid rgba(255,255,255,.08);margin-bottom:8px">
              <div style="width:36px;height:36px;background:rgba(37,99,235,.15);border-radius:10px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:14px;color:#2563EB">${s[0]}</div>
              <div style="flex:1"><div style="font-weight:700;font-size:13px;color:#F8FAFC">${s}</div><div style="color:#64748B;font-size:11px">${q} shares</div></div>
              <div style="text-align:right"><div style="font-weight:700;font-size:13px;color:#F8FAFC">${v}</div><div style="background:rgba(16,185,129,.15);padding:2px 6px;border-radius:6px;font-size:11px;font-weight:600;color:#10B981">${p}</div></div>
            </div>
          `).join('')}
        </div>`
    },
    news: {
      title: 'News',
      body: `
        <div style="padding:20px">
          <div style="background:linear-gradient(135deg,#1D4ED8,#2563EB);border-radius:20px;padding:20px;height:160px;display:flex;flex-direction:column;justify-content:flex-end;margin-bottom:20px">
            <div style="background:rgba(255,255,255,.2);padding:3px 8px;border-radius:6px;font-size:10px;font-weight:600;color:#fff;width:fit-content;margin-bottom:8px">Featured</div>
            <div style="color:#fff;font-size:17px;font-weight:700;line-height:1.2">Budget 2026: Key Announcements & Market Impact</div>
            <div style="color:rgba(255,255,255,.7);font-size:12px;margin-top:4px">Read the full analysis</div>
          </div>
          ${[['SEBI New F&O Rules','SEBI tightens index derivatives norms effective April 2026','Markets','2h ago'],['RBI Holds Repo Rate at 6.50%','Eighth straight MPC meet maintains neutral stance','Economy','5h ago'],['TCS Q3 Results Beat Estimates','12% net profit growth, strong deal pipeline','Earnings','8h ago']].map(([t,s,c,ti]) => `
            <div style="display:flex;gap:12px;padding:14px;background:#131D2E;border-radius:14px;border:1px solid rgba(255,255,255,.08);margin-bottom:8px">
              <div style="width:40px;height:40px;background:rgba(37,99,235,.15);border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:18px">📰</div>
              <div style="flex:1"><div style="color:#64748B;font-size:10px;font-weight:600;margin-bottom:2px">${c} · ${ti}</div><div style="font-weight:600;font-size:13px;color:#F8FAFC">${t}</div><div style="color:#64748B;font-size:11px;margin-top:2px">${s}</div></div>
            </div>
          `).join('')}
        </div>`
    }
  };
  return screens[name] || screens.home;
}

async function run() {
  const browser = await chromium.launch({ headless: true });
  const ctx = await browser.newContext({ deviceScaleFactor: 2 });

  // ---- WEBSITE SCREENSHOTS ----
  console.log('📸 Website screenshots...');

  // Desktop
  const desktop = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await desktop.goto(BASE, { waitUntil: 'networkidle' });
  await desktop.screenshot({ path: resolve(out, 'website-desktop.png'), fullPage: false });
  console.log('  ✓ website-desktop.png');

  await desktop.screenshot({ path: resolve(out, 'website-fullpage.png'), fullPage: true });
  console.log('  ✓ website-fullpage.png');

  // Mobile
  const mobile = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await mobile.goto(BASE, { waitUntil: 'networkidle' });
  await mobile.screenshot({ path: resolve(out, 'website-mobile.png'), fullPage: false });
  console.log('  ✓ website-mobile.png');

  await mobile.screenshot({ path: resolve(out, 'website-mobile-full.png'), fullPage: true });
  console.log('  ✓ website-mobile-full.png');

  // Hero region (desktop)
  const hero = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await hero.goto(BASE, { waitUntil: 'networkidle' });
  const heroEl = await hero.locator('.hero');
  await heroEl.screenshot({ path: resolve(out, 'website-hero.png') });
  console.log('  ✓ website-hero.png');

  // ---- LOGO ----
  console.log('🎨 Logo...');
  const logoPage = await browser.newPage();
  await logoPage.setContent(`
    <html><body style="background:#0B1220;display:flex;align-items:center;justify-content:center;height:100vh;margin:0">
      <svg viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg" width="256" height="256">
        <rect width="512" height="512" rx="104" fill="#0B1220"/>
        <path d="M200 380V132h80c32 0 56 8 72 24s24 36 24 60c0 28-10 50-30 66s-48 24-84 24h-38l92 74" stroke="#F8FAFC" stroke-width="36" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        <path d="M280 200l-80 0" stroke="#2563EB" stroke-width="20" stroke-linecap="round" fill="none"/>
      </svg>
    </body></html>
  `);
  await logoPage.screenshot({ path: resolve(out, 'logo-icon.png') });
  console.log('  ✓ logo-icon.png');

  // Logo with wordmark
  await logoPage.setContent(`
    <html><body style="background:#0B1220;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;font-family:system-ui,-apple-system,sans-serif">
      <div style="display:flex;align-items:center;gap:14px">
        <svg viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg" width="64" height="64">
          <rect width="512" height="512" rx="104" fill="#0B1220"/>
          <path d="M200 380V132h80c32 0 56 8 72 24s24 36 24 60c0 28-10 50-30 66s-48 24-84 24h-38l92 74" stroke="#F8FAFC" stroke-width="36" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
          <path d="M280 200l-80 0" stroke="#2563EB" stroke-width="20" stroke-linecap="round" fill="none"/>
        </svg>
        <span style="color:#F8FAFC;font-size:48px;font-weight:700;letter-spacing:-1.5px">FinSwitch</span>
      </div>
    </body></html>
  `);
  await logoPage.screenshot({ path: resolve(out, 'logo-horizontal.png') });
  console.log('  ✓ logo-horizontal.png');

  // ---- APP SCREENSHOTS (HTML mockups) ----
  console.log('📱 App screenshots...');

  for (const [key, screen] of Object.entries({
    home: 'App-Home',
    markets: 'App-Markets',
    ai: 'App-AI',
    portfolio: 'App-Portfolio',
    news: 'App-News'
  })) {
    const data = appHTML(null, key);
    const p = await browser.newPage({ viewport: { width: APP_WIDTH, height: 844 } });
    await p.setContent(`
      <html><body style="margin:0;padding:0;background:#0B1220;font-family:system-ui,-apple-system,sans-serif;overflow:hidden">
        <div style="background:#0B1220;min-height:100vh">${data.body}</div>
      </body></html>
    `);
    await p.screenshot({ path: resolve(out, `${screen}.png`) });
    console.log(`  ✓ ${screen}.png`);
    await p.close();
  }

  // App icon (rounded square, no bg)
  const iconPage = await browser.newPage();
  await iconPage.setContent(`
    <html><body style="margin:0;display:flex;align-items:center;justify-content:center;height:100vh;background:transparent">
      <svg viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg" width="512" height="512">
        <defs>
          <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stop-color="#1D4ED8"/>
            <stop offset="100%" stop-color="#2563EB"/>
          </linearGradient>
        </defs>
        <rect width="512" height="512" rx="104" fill="url(#bg)"/>
        <path d="M200 380V132h80c32 0 56 8 72 24s24 36 24 60c0 28-10 50-30 66s-48 24-84 24h-38l92 74" stroke="#F8FAFC" stroke-width="36" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        <path d="M280 200l-80 0" stroke="#fff" stroke-width="20" stroke-linecap="round" fill="none" opacity="0.4"/>
      </svg>
    </body></html>
  `);
  await iconPage.screenshot({ path: resolve(out, 'app-icon.png') });
  console.log('  ✓ app-icon.png');

  await browser.close();
  console.log('\n✅ All screenshots saved to assets/');
}

run().catch(e => { console.error(e); process.exit(1); });
