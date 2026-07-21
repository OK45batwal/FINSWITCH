document.addEventListener('DOMContentLoaded', () => {

  // Nav scroll
  const nav = document.querySelector('.nav');
  let lastScroll = 0;
  window.addEventListener('scroll', () => {
    const current = window.scrollY;
    if (current > 50) {
      nav.classList.add('scrolled');
    } else {
      nav.classList.remove('scrolled');
    }
    lastScroll = current;
  });

  // Mobile menu
  const toggle = document.querySelector('.mobile-toggle');
  const navLinks = document.querySelector('.nav-links');
  if (toggle) {
    toggle.addEventListener('click', () => {
      navLinks.classList.toggle('open');
      document.body.classList.toggle('mobile-nav-open');
    });
  }

  // FAQ accordion
  document.querySelectorAll('.faq-question').forEach(q => {
    q.addEventListener('click', () => {
      const item = q.parentElement;
      const isOpen = item.classList.contains('open');
      document.querySelectorAll('.faq-item').forEach(i => i.classList.remove('open'));
      if (!isOpen) item.classList.add('open');
    });
  });

  // Market tabs
  document.querySelectorAll('.market-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.market-tab').forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
    });
  });

  // Intersection Observer for animations
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

  document.querySelectorAll('.animate-in').forEach(el => observer.observe(el));
  document.querySelectorAll('.feature-card, .testimonial-card, .roadmap-item, .portfolio-preview').forEach(el => {
    el.classList.add('animate-in');
    observer.observe(el);
  });

  // Animated counters
  function animateCounter(el, target, suffix = '') {
    let current = 0;
    const step = Math.ceil(target / 60);
    const interval = setInterval(() => {
      current += step;
      if (current >= target) {
        current = target;
        clearInterval(interval);
      }
      el.textContent = current.toLocaleString() + suffix;
    }, 16);
  }

  const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const el = entry.target;
        const val = parseInt(el.dataset.value);
        if (val) animateCounter(el, val, el.dataset.suffix || '');
        statsObserver.unobserve(el);
      }
    });
  }, { threshold: 0.5 });

  document.querySelectorAll('.hero-stat h3').forEach(el => statsObserver.observe(el));

  // AI Chat demo
  const chatInput = document.querySelector('.ai-input-bar input');
  const chatSend = document.querySelector('.ai-input-bar button');
  const chatMessages = document.querySelector('.ai-demo');
  if (chatSend && chatInput) {
    chatSend.addEventListener('click', sendMessage);
    chatInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') sendMessage();
    });
  }
  function sendMessage() {
    const text = chatInput.value.trim();
    if (!text) return;
    const userMsg = document.createElement('div');
    userMsg.className = 'ai-message user';
    userMsg.innerHTML = `<div class="sender">You</div><p>${text}</p>`;
    chatMessages.appendChild(userMsg);
    chatInput.value = '';
    chatMessages.scrollTop = chatMessages.scrollHeight;
    setTimeout(() => {
      const responses = [
        "Based on current market trends, HDFC Bank shows strong fundamentals with a P/E ratio of 18.5, below its 5-year average of 22.3.",
        "The Nifty 50 is down 0.3% today, largely driven by selling in IT stocks. However, banking stocks are showing resilience.",
        "A P/E ratio of 15-20 is considered reasonable for Indian large-cap stocks. Growth companies typically command higher multiples.",
        "Your portfolio has 65% large-cap allocation, which provides stability. Consider adding mid-cap exposure for growth potential."
      ];
      const botMsg = document.createElement('div');
      botMsg.className = 'ai-message assistant';
      botMsg.innerHTML = `<div class="sender">FinSwitch AI</div><p>${responses[Math.floor(Math.random() * responses.length)]}</p>`;
      chatMessages.appendChild(botMsg);
      chatMessages.scrollTop = chatMessages.scrollHeight;
    }, 800);
  }

  // Sparkline charts
  document.querySelectorAll('.stock-chart').forEach(canvas => {
    const ctx = canvas.getContext('2d');
    const isUp = canvas.dataset.up === 'true';
    const width = canvas.width, height = canvas.height;
    const points = Array.from({length: 20}, () => Math.random() * (height * 0.6) + height * 0.2);
    ctx.strokeStyle = isUp ? '#10B981' : '#EF4444';
    ctx.lineWidth = 2;
    ctx.beginPath();
    points.forEach((p, i) => {
      const x = (i / (points.length - 1)) * width;
      if (i === 0) ctx.moveTo(x, p);
      else ctx.lineTo(x, p);
    });
    ctx.stroke();
    ctx.fillStyle = isUp ? 'rgba(16,185,129,0.08)' : 'rgba(239,68,68,0.08)';
    ctx.lineTo(width, height);
    ctx.lineTo(0, height);
    ctx.closePath();
    ctx.fill();
  });
});
