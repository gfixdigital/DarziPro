'use server';

import { supabaseAdmin } from '@/lib/supabaseAdmin';

export async function runDbOptimization() {
  const { data, error } = await supabaseAdmin.rpc('run_db_vacuum');
  if (error) {
    throw new Error(error.message);
  }
  return data as string;
}

export async function downloadDbBackup() {
  const { data, error } = await supabaseAdmin.rpc('get_db_backup');
  if (error) {
    throw new Error(`Backup failed: ${error.message}`);
  }
  return data;
}
