const API = 'http://localhost:8000/api/v1';

document.addEventListener('DOMContentLoaded', () => {
  const nav = document.querySelector('.nav');
  window.addEventListener('scroll', () => {
    nav.classList.toggle('scrolled', window.scrollY > 50);
  });

  // Mobile menu
  document.querySelector('.mobile-toggle')?.addEventListener('click', () => {
    document.querySelector('.nav-links')?.classList.toggle('open');
    document.body.classList.toggle('mobile-nav-open');
  });

  // Intersection Observer for animations
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
  }, { threshold: 0.1 });
  document.querySelectorAll('.animate-in, .bento-item, .stat-card, .testimonial-card').forEach(el => {
    el.classList.add('animate-in');
    observer.observe(el);
  });

  // Load data
  loadIndices();
  loadStocks();
  loadPortfolio();
  loadNews();
  setupAIChat();
  setupMarketTabs();
  updateTicker();
  setInterval(updateTicker, 30000);
});

async function api(path) {
  try {
    const res = await fetch(API + path);
    const json = await res.json();
    return json.success ? json.data : [];
  } catch { return []; }
}

async function updateTicker() {
  const data = await api('/markets/indices');
  const items = document.querySelectorAll('.ticker-item');
  data.forEach((d, i) => {
    if (items[i]) {
      const up = d.change_percent >= 0;
      items[i].innerHTML = `<span>${d.symbol}</span><span class="num" style="color:${up?'#10B981':'#EF4444'};">${d.last_value.toLocaleString()} <span style="color:${up?'#10B981':'#EF4444'};">${d.change_percent > 0 ? '+' : ''}${d.change_percent.toFixed(2)}%</span></span>`;
    }
  });
}

async function loadIndices() {
  const data = await api('/markets/indices');
  const container = document.querySelector('.mockup-header + div');
  if (!container || !data.length) return;
  container.innerHTML = data.slice(0, 5).map(d => {
    const up = d.change_percent >= 0;
    return `<div class="mockup-line"><span class="sym">${d.symbol}</span><span class="prc num">₹${d.last_value.toLocaleString()}</span><span class="chg ${up?'up':'dn'} num">${d.change_percent > 0 ? '+' : ''}${d.change_percent.toFixed(2)}%</span></div>`;
  }).join('');
}

async function loadStocks(sector) {
  const data = await api(`/markets/stocks${sector ? '?sector='+sector : ''}`);
  const tbody = document.querySelector('.stock-table tbody');
  if (!tbody) return;
  tbody.innerHTML = (Array.isArray(data) ? data : []).map(s => {
    const up = s.change >= 0;
    return `<tr>
      <td style="font-weight:600;">${s.symbol}</td>
      <td style="color:#64748B;font-size:13px;">${s.name}</td>
      <td style="text-align:right;font-family:'JetBrains Mono',monospace;">₹${s.last_price.toFixed(2)}</td>
      <td style="text-align:right;"><span class="${up?'price-up':'price-down'} num">${s.change > 0 ? '+' : ''}${s.change.toFixed(2)}</span></td>
      <td style="text-align:right;"><span class="${up?'price-up':'price-down'} num">${s.change_percent > 0 ? '+' : ''}${s.change_percent.toFixed(2)}%</span></td>
      <td style="text-align:right;color:#64748B;font-family:'JetBrains Mono',monospace;">${(s.volume/1000000).toFixed(1)}M</td>
    </tr>`;
  }).join('');
}

function setupMarketTabs() {
  document.querySelectorAll('.market-tab').forEach(t => {
    t.addEventListener('click', () => {
      document.querySelectorAll('.market-tab').forEach(x => x.classList.remove('active'));
      t.classList.add('active');
      const sectorMap = { 'Nifty 50': 'oil & gas', 'Bank Nifty': 'banking', 'Gainers': 'gainers', 'Losers': 'losers' };
      const sector = sectorMap[t.textContent];
      if (sector === 'gainers') loadGainers();
      else if (sector === 'losers') loadLosers();
      else loadStocks(sector);
    });
  });
}

async function loadGainers() {
  const data = await api('/markets/gainers?limit=8');
  const tbody = document.querySelector('.stock-table tbody');
  if (!tbody) return;
  tbody.innerHTML = (Array.isArray(data) ? data : []).map(s => {
    return `<tr>
      <td style="font-weight:600;">${s.symbol}</td>
      <td style="color:#64748B;font-size:13px;">${s.name}</td>
      <td style="text-align:right;font-family:'JetBrains Mono',monospace;">₹${s.last_price.toFixed(2)}</td>
      <td style="text-align:right;"><span class="price-up num">+${s.change.toFixed(2)}</span></td>
      <td style="text-align:right;"><span class="price-up num">+${s.change_percent.toFixed(2)}%</span></td>
      <td style="text-align:right;color:#64748B;font-family:'JetBrains Mono',monospace;">${(s.volume/1000000).toFixed(1)}M</td>
    </tr>`;
  }).join('');
}

async function loadLosers() {
  const data = await api('/markets/losers?limit=8');
  const tbody = document.querySelector('.stock-table tbody');
  if (!tbody) return;
  tbody.innerHTML = (Array.isArray(data) ? data : []).map(s => {
    return `<tr>
      <td style="font-weight:600;">${s.symbol}</td>
      <td style="color:#64748B;font-size:13px;">${s.name}</td>
      <td style="text-align:right;font-family:'JetBrains Mono',monospace;">₹${s.last_price.toFixed(2)}</td>
      <td style="text-align:right;"><span class="price-down num">${s.change.toFixed(2)}</span></td>
      <td style="text-align:right;"><span class="price-down num">${s.change_percent.toFixed(2)}%</span></td>
      <td style="text-align:right;color:#64748B;font-family:'JetBrains Mono',monospace;">${(s.volume/1000000).toFixed(1)}M</td>
    </tr>`;
  }).join('');
}

async function loadPortfolio() {
  const summary = await api('/portfolio/summary');
  const holdings = await api('/portfolio/holdings');
  if (!summary) return;

  const summaryEl = document.querySelector('.portfolio-summary');
  if (summaryEl) {
    summaryEl.innerHTML = `
      <div class="stat-card"><div class="stat-label">Total Invested</div><div class="stat-value" style="color:#38BDF8;">₹${summary.total_invested?.toLocaleString()}</div></div>
      <div class="stat-card"><div class="stat-label">Current Value</div><div class="stat-value" style="color:#10B981;">₹${summary.current_value?.toLocaleString()}</div><div class="stat-change pos">+${summary.returns_percent?.toFixed(1)}% overall</div></div>
      <div class="stat-card"><div class="stat-label">Today's P&L</div><div class="stat-value" style="color:#10B981;">+₹${summary.today_pl?.toLocaleString()}</div><div class="stat-change pos">+${summary.today_pl_percent?.toFixed(2)}% today</div></div>`;
  }

  const holdingsEl = document.querySelector('.portfolio-holdings');
  if (holdingsEl && Array.isArray(holdings)) {
    const header = holdingsEl.querySelector('div:first-child');
    const rows = holdings.map(h => {
      const up = h.pl >= 0;
      return `<div class="holding-row"><div><div class="h-symbol">${h.symbol}</div><div class="h-name">${h.name}</div></div><span class="num" style="color:#64748B;">${h.quantity}</span><span class="num" style="color:#64748B;">${h.avg_price.toFixed(0)}</span><span class="num" style="color:#F8FAFC;">${h.ltp.toFixed(0)}</span><span class="h-value" style="color:#F8FAFC;">₹${h.value.toLocaleString()}</span><span class="h-pl" style="color:${up?'#10B981':'#EF4444'};">${up?'+':''}${h.pl_percent.toFixed(2)}%</span></div>`;
    }).join('');
    holdingsEl.innerHTML = (header ? header.outerHTML : '') + rows;
  }
}

async function loadNews() {
  const data = await api('/news');
  const container = document.querySelector('.ai-section + .portfolio-section') || document.querySelector('#portfolio');
  if (!container || !Array.isArray(data)) return;

  const newsSection = document.createElement('section');
  newsSection.className = 'testimonials';
  newsSection.innerHTML = `<div class="container">
    <div class="section-header" style="justify-content:center;text-align:center;">
      <div><div class="section-label">News Feed</div><h2 class="section-title">Market News</h2></div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:16px;">
      ${data.slice(0, 6).map(n => `
        <div style="background:#131D2E;border:1px solid rgba(255,255,255,.06);border-radius:20px;padding:24px;">
          <div style="display:flex;gap:8px;margin-bottom:8px;">
            <span style="background:rgba(56,189,248,.15);padding:2px 8px;border-radius:4px;font-size:11px;color:#38BDF8;font-weight:600;">${n.category}</span>
            <span style="color:#64748B;font-size:11px;">${n.sentiment}</span>
          </div>
          <h3 style="font-size:16px;margin-bottom:4px;">${n.title}</h3>
          <p style="color:#64748B;font-size:13px;line-height:1.6;">${n.summary}</p>
          <div style="margin-top:8px;font-size:12px;color:#475569;">${n.source}</div>
        </div>
      `).join('')}
    </div>
  </div>`;
  container.parentNode.insertBefore(newsSection, container.nextSibling);
}

function setupAIChat() {
  const input = document.querySelector('.ai-input input');
  const demoChat = document.querySelector('.ai-demo');
  if (!input || !demoChat) return;

  input.addEventListener('keydown', async (e) => {
    if (e.key !== 'Enter' || !input.value.trim()) return;
    const msg = input.value.trim();
    input.value = '';

    const userBubble = document.createElement('div');
    userBubble.className = 'ai-msg user';
    userBubble.innerHTML = `<div class="sender">You</div>${msg}`;
    demoChat.insertBefore(userBubble, demoChat.lastElementChild);

    const loading = document.createElement('div');
    loading.className = 'ai-msg bot';
    loading.innerHTML = `<div class="sender">FinSwitch AI</div>Thinking...`;
    demoChat.insertBefore(loading, demoChat.lastElementChild);

    const res = await fetch(API + '/ai/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: msg }),
    });
    const json = await res.json();

    loading.innerHTML = `<div class="sender">FinSwitch AI</div>${json.data?.response || 'Sorry, try again.'}`;
  });
}
