document.addEventListener('DOMContentLoaded', () => {
  const nav = document.querySelector('.nav');
  window.addEventListener('scroll', () => {
    nav.classList.toggle('scrolled', window.scrollY > 50);
  });

  document.querySelector('.mobile-toggle')?.addEventListener('click', () => {
    document.querySelector('.nav-links')?.classList.toggle('open');
    document.body.classList.toggle('mobile-nav-open');
  });

  document.querySelectorAll('.market-tab').forEach(t => {
    t.addEventListener('click', () => {
      document.querySelectorAll('.market-tab').forEach(x => x.classList.remove('active'));
      t.classList.add('active');
    });
  });

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
  }, { threshold: 0.1 });
  document.querySelectorAll('.animate-in, .bento-item, .stat-card, .testimonial-card').forEach(el => {
    el.classList.add('animate-in');
    observer.observe(el);
  });
});
