import { supabaseAdmin } from '@/lib/supabaseAdmin';
import SettingsClient from './SettingsClient';

export const revalidate = 0; // Fetch fresh database stats on every page load

export default async function SettingsPage() {
  // 1. Measure database connection latency
  const start = Date.now();
  let isHealthy = false;
  let shopsCount = 0;

  try {
    const { data: shops, error: shopsError } = await supabaseAdmin
      .from('shops')
      .select('id')
      .limit(100);

    if (!shopsError) {
      isHealthy = true;
      shopsCount = shops?.length || 0;
    }
  } catch (_) {
    isHealthy = false;
  }
  const latency = Date.now() - start;

  // 2. Fetch database stats (RPC)
  let dbStats = null;
  let rpcError = null;

  try {
    const { data, error } = await supabaseAdmin.rpc('get_db_stats');
    if (error) {
      rpcError = error.message;
    } else {
      dbStats = data;
    }
  } catch (e: any) {
    rpcError = e.message || 'RPC get_db_stats not installed';
  }

  return (
    <SettingsClient
      dbStats={dbStats}
      latency={latency}
      isHealthy={isHealthy}
      rpcError={rpcError}
      shopsCount={shopsCount}
    />
  );
}
