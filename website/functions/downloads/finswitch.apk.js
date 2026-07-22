// Cloudflare Edge Function redirect for /downloads/finswitch.apk
export async function onRequest(context) {
  return Response.redirect('https://github.com/OK45batwal/FINSWITCH/releases/download/v1.0.0/app-release.apk', 302);
}
