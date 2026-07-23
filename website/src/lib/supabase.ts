import { createClient, SupabaseClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://lydliyjidlzzwggywwpd.supabase.co';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'sb_publishable_wBSqQQfKwNl9ikf4YXJ0Vg_RiNvTzGs';

export const supabase: SupabaseClient = createClient(supabaseUrl, supabaseAnonKey);