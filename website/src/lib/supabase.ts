import { createClient, SupabaseClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://dgvtznykoyyxgwgtpbqf.supabase.co';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRndnR6bnlrb3l5eGd3Z3RwYnFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQxMTgzMTUsImV4cCI6MjA5OTY5NDMxNX0.a3dgjgZbXbCK6_DTPvjn99eb_T9HDvfPKTcNq-M49Ac';

export const supabase: SupabaseClient = createClient(supabaseUrl, supabaseAnonKey);