import { onRequest as __api_ai_js_onRequest } from "/Users/omkar/FINSWITCH/website/functions/api/ai.js"
import { onRequest as __downloads_finswitch_apk_js_onRequest } from "/Users/omkar/FINSWITCH/website/functions/downloads/finswitch.apk.js"
import { onRequest as __downloads___path___js_onRequest } from "/Users/omkar/FINSWITCH/website/functions/downloads/[[path]].js"
import { onRequest as ___middleware_js_onRequest } from "/Users/omkar/FINSWITCH/website/functions/_middleware.js"

export const routes = [
    {
      routePath: "/api/ai",
      mountPath: "/api",
      method: "",
      middlewares: [],
      modules: [__api_ai_js_onRequest],
    },
  {
      routePath: "/downloads/finswitch.apk",
      mountPath: "/downloads",
      method: "",
      middlewares: [],
      modules: [__downloads_finswitch_apk_js_onRequest],
    },
  {
      routePath: "/downloads/:path*",
      mountPath: "/downloads",
      method: "",
      middlewares: [],
      modules: [__downloads___path___js_onRequest],
    },
  {
      routePath: "/",
      mountPath: "/",
      method: "",
      middlewares: [___middleware_js_onRequest],
      modules: [],
    },
  ]