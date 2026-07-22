// Cloudflare Pages global middleware
export async function onRequest(context) {
  const url = new URL(context.request.url);

  // Direct APK download redirect
  if (url.pathname === '/downloads/finswitch.apk' || url.pathname.endsWith('/finswitch.apk')) {
    return Response.redirect('https://github.com/OK45batwal/FINSWITCH/releases/download/v1.0.0/app-release.apk', 302);
  }

  return context.next();
}
