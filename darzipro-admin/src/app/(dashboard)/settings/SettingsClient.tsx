'use client';

import React, { useState, useTransition } from 'react';
import { 
  Settings, Database, Activity, HardDrive, RefreshCw, 
  Terminal, ShieldCheck, Check, Clipboard, Info, Sliders, ToggleLeft, ToggleRight, Download
} from 'lucide-react';
import { runDbOptimization, downloadDbBackup } from './actions';

interface TableStat {
  table_name: string;
  row_count: number;
  total_bytes: number;
}

interface DbStats {
  database_size_bytes: number;
  active_connections: number;
  postgres_version: string;
  tables: TableStat[];
}

interface SettingsClientProps {
  dbStats: DbStats | null;
  latency: number;
  isHealthy: boolean;
  rpcError: string | null;
  shopsCount: number;
}

export default function SettingsClient({
  dbStats,
  latency,
  isHealthy,
  rpcError,
  shopsCount,
}: SettingsClientProps) {
  const [copied, setCopied] = useState(false);
  const [isPending, startTransition] = useTransition();
  const [optimizationMessage, setOptimizationMessage] = useState<string | null>(null);

  // Backup states
  const [backupPending, setBackupPending] = useState(false);
  const [backupError, setBackupError] = useState<string | null>(null);

  // Feature Toggles (Local UI State for demonstration / admin preference)
  const [selfReg, setSelfReg] = useState(true);
  const [maintenance, setMaintenance] = useState(false);
  const [backups, setBackups] = useState(true);

  // Constants
  const FREE_TIER_LIMIT_BYTES = 500 * 1024 * 1024; // 500 MB

  const formatBytes = (bytes: number) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const copySql = () => {
    const sqlCode = `-- 1. Create function to get detailed database statistics
CREATE OR REPLACE FUNCTION public.get_db_stats()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    db_size_bytes BIGINT;
    active_conns INT;
    pg_ver TEXT;
    tables_info JSONB;
BEGIN
    SELECT pg_database_size(current_database()) INTO db_size_bytes;
    SELECT count(*) INTO active_conns FROM pg_stat_activity;
    SELECT version() INTO pg_ver;
    SELECT jsonb_agg(t) INTO tables_info FROM (
        SELECT 
            c.relname AS table_name,
            c.reltuples::bigint AS row_count,
            pg_total_relation_size(c.oid) AS total_bytes
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' 
          AND c.relkind = 'r'
        ORDER BY total_bytes DESC
    ) t;
    RETURN jsonb_build_object(
        'database_size_bytes', db_size_bytes,
        'active_connections', active_conns,
        'postgres_version', pg_ver,
        'tables', tables_info
    );
END;
$$;

-- 2. Create function to optimize database tables (ANALYZE)
CREATE OR REPLACE FUNCTION public.run_db_vacuum()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    ANALYZE;
    RETURN 'Database optimization (ANALYZE) completed successfully.';
END;
$$;

-- 3. Create function to gather a complete JSON dump of public tables
CREATE OR REPLACE FUNCTION public.get_db_backup()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    t_name RECORD;
    temp_json JSONB;
    backup_data JSONB := '{}'::jsonb;
BEGIN
    FOR t_name IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('SELECT jsonb_agg(r) FROM (SELECT * FROM public.%I) r', t_name.table_name) INTO temp_json;
        IF temp_json IS NULL THEN
            temp_json := '[]'::jsonb;
        END IF;
        backup_data := jsonb_set(backup_data, ARRAY[t_name.table_name], temp_json, true);
    END LOOP;
    RETURN backup_data;
END;
$$;`;

    navigator.clipboard.writeText(sqlCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleOptimize = () => {
    setOptimizationMessage(null);
    startTransition(async () => {
      try {
        const msg = await runDbOptimization();
        setOptimizationMessage(msg);
      } catch (err: any) {
        setOptimizationMessage(`Error: ${err.message || 'Optimization failed'}`);
      }
    });
  };

  const handleDownloadBackup = async () => {
    setBackupError(null);
    setBackupPending(true);
    try {
      const data = await downloadDbBackup();
      
      // Format backup as JSON file and trigger browser download
      const jsonStr = JSON.stringify(data, null, 2);
      const blob = new Blob([jsonStr], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `darzipro_backup_${new Date().toISOString().split('T')[0]}.json`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    } catch (err: any) {
      setBackupError(err.message || 'Backup download failed.');
    } finally {
      setBackupPending(false);
    }
  };

  const totalUsed = dbStats?.database_size_bytes || 0;
  const remaining = Math.max(0, FREE_TIER_LIMIT_BYTES - totalUsed);
  const usedPercentage = Math.min(100, (totalUsed / FREE_TIER_LIMIT_BYTES) * 100);

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-semibold text-gray-900 flex items-center">
          <Settings className="mr-3 h-6 w-6 text-gray-500" />
          Platform Settings
        </h1>
        <p className="mt-1 text-sm text-gray-500">
          Monitor real-time database usage, health status, and manage administrative settings.
        </p>
      </div>

      {/* Grid: Health Checks */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-3">
        <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-xs flex items-center space-x-4">
          <div className={`p-3 rounded-lg ${isHealthy ? 'bg-green-50 border border-green-200 text-green-600' : 'bg-red-50 border border-red-200 text-red-600'}`}>
            <Activity className="h-6 w-6 animate-pulse" />
          </div>
          <div>
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">DB Connection</p>
            <p className="text-lg font-bold text-gray-900 mt-0.5">{isHealthy ? 'Healthy & Connected' : 'Disconnected'}</p>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-xs flex items-center space-x-4">
          <div className="p-3 rounded-lg bg-blue-50 border border-blue-200 text-blue-600">
            <RefreshCw className="h-6 w-6" />
          </div>
          <div>
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Response Latency</p>
            <p className="text-lg font-bold text-gray-900 mt-0.5">{latency} ms</p>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-xs flex items-center space-x-4">
          <div className="p-3 rounded-lg bg-purple-50 border border-purple-200 text-purple-600">
            <HardDrive className="h-6 w-6" />
          </div>
          <div>
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Active connections</p>
            <p className="text-lg font-bold text-gray-900 mt-0.5">
              {dbStats ? `${dbStats.active_connections} sessions` : 'N/A'}
            </p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left column: DB size & Tables info */}
        <div className="lg:col-span-2 space-y-8">
          {/* Storage usage */}
          <div className="bg-white shadow-xs rounded-xl border border-gray-200 p-6 space-y-6">
            <div className="flex items-center justify-between border-b border-gray-100 pb-4">
              <h3 className="text-base font-bold text-gray-900 flex items-center">
                <Database className="mr-2 h-5 w-5 text-gray-500" />
                Real-time Database Usage
              </h3>
              <span className="text-xs font-semibold text-gray-500 bg-gray-50 border border-gray-200 px-2.5 py-1 rounded-md">
                Quota: 500 MB Free Tier
              </span>
            </div>

            {dbStats ? (
              <div className="space-y-4">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-500 font-medium">Space Used: <strong className="text-gray-900">{formatBytes(totalUsed)}</strong></span>
                  <span className="text-gray-500 font-medium">Remaining: <strong className="text-gray-900">{formatBytes(remaining)}</strong></span>
                </div>
                {/* Progress bar */}
                <div className="w-full bg-gray-100 rounded-full h-3 overflow-hidden border border-gray-200/50">
                  <div 
                    className={`h-full rounded-full transition-all duration-500 ${usedPercentage > 85 ? 'bg-red-600' : usedPercentage > 60 ? 'bg-amber-500' : 'bg-gray-900'}`}
                    style={{ width: `${usedPercentage}%` }}
                  />
                </div>
                <p className="text-xs text-gray-400">
                  Your platform is currently utilizing {usedPercentage.toFixed(2)}% of the database storage.
                </p>
              </div>
            ) : (
              <div className="rounded-lg bg-amber-50 p-4 border border-amber-200/60 flex items-start text-amber-900">
                <Info className="h-5 w-5 text-amber-600 mr-3 flex-shrink-0 mt-0.5" />
                <div className="text-sm">
                  <p className="font-semibold">Setup Required</p>
                  <p className="mt-1">
                    The database statistics RPC utility is not yet configured. Apply the migration in your Supabase dashboard to enable live metrics tracking.
                  </p>
                </div>
              </div>
            )}
          </div>

          {/* Table Breakdown */}
          {dbStats && dbStats.tables && (
            <div className="bg-white shadow-xs rounded-xl border border-gray-200 overflow-hidden">
              <div className="px-6 py-5 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
                <h3 className="text-sm font-bold text-gray-900 uppercase tracking-wider">Table Storage Breakdown</h3>
                <span className="text-xs text-gray-500 font-medium">Public Schema</span>
              </div>
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200 text-left">
                  <thead className="bg-gray-50 text-xs font-semibold uppercase tracking-wider text-gray-500">
                    <tr>
                      <th className="px-6 py-3">Table Name</th>
                      <th className="px-6 py-3 text-right">Rows</th>
                      <th className="px-6 py-3 text-right">Disk Size</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 bg-white text-sm">
                    {dbStats.tables.map((table) => (
                      <tr key={table.table_name} className="hover:bg-gray-50/50 transition-colors">
                        <td className="px-6 py-4 font-semibold text-gray-900">
                          {table.table_name}
                        </td>
                        <td className="px-6 py-4 text-right text-gray-500">
                          {table.row_count.toLocaleString()}
                        </td>
                        <td className="px-6 py-4 text-right font-medium text-gray-700">
                          {formatBytes(table.total_bytes)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* SQL Assistant if missing or errored */}
          {(rpcError || !dbStats) && (
            <div className="bg-white shadow-xs rounded-xl border border-gray-200 p-6 space-y-4">
              <div className="flex items-center justify-between border-b border-gray-100 pb-3">
                <h3 className="text-sm font-bold text-gray-900 uppercase tracking-wider flex items-center font-mono">
                  <Terminal className="mr-2 h-4 w-4 text-gray-500" />
                  SQL Setup Assistant
                </h3>
                <button 
                  onClick={copySql}
                  className="inline-flex items-center text-xs font-semibold text-gray-600 hover:text-gray-900 bg-gray-50 border border-gray-200 px-2.5 py-1.5 rounded-lg transition-colors cursor-pointer"
                >
                  {copied ? <Check className="h-3.5 w-3.5 text-green-600 mr-1.5" /> : <Clipboard className="h-3.5 w-3.5 mr-1.5" />}
                  {copied ? 'Copied!' : 'Copy Script'}
                </button>
              </div>
              <p className="text-xs text-gray-500 leading-relaxed">
                Run this SQL query in your **Supabase Dashboard &gt; SQL Editor** to create the metrics functions. The admin panel uses them to load live table weights and database connection usage.
              </p>
              <pre className="p-3 bg-gray-900 text-gray-300 font-mono text-[11px] rounded-lg overflow-x-auto border border-gray-800 leading-relaxed max-h-48">
{`CREATE OR REPLACE FUNCTION public.get_db_stats()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    db_size_bytes BIGINT;
    active_conns INT;
    pg_ver TEXT;
    tables_info JSONB;
BEGIN
    SELECT pg_database_size(current_database()) INTO db_size_bytes;
    SELECT count(*) INTO active_conns FROM pg_stat_activity;
    SELECT version() INTO pg_ver;
    SELECT jsonb_agg(t) INTO tables_info FROM (
        SELECT 
            c.relname AS table_name,
            c.reltuples::bigint AS row_count,
            pg_total_relation_size(c.oid) AS total_bytes
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' 
          AND c.relkind = 'r'
        ORDER BY total_bytes DESC
    ) t;
    RETURN jsonb_build_object(
        'database_size_bytes', db_size_bytes,
        'active_connections', active_conns,
        'postgres_version', pg_ver,
        'tables', tables_info
    );
END;
$$;

-- 2. Create function to optimize database tables (ANALYZE)
CREATE OR REPLACE FUNCTION public.run_db_vacuum()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    ANALYZE;
    RETURN 'Database optimization (ANALYZE) completed successfully.';
END;
$$;

-- 3. Create function to gather a complete JSON dump of public tables
CREATE OR REPLACE FUNCTION public.get_db_backup()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    t_name RECORD;
    temp_json JSONB;
    backup_data JSONB := '{}'::jsonb;
BEGIN
    FOR t_name IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('SELECT jsonb_agg(r) FROM (SELECT * FROM public.%I) r', t_name.table_name) INTO temp_json;
        IF temp_json IS NULL THEN
            temp_json := '[]'::jsonb;
        END IF;
        backup_data := jsonb_set(backup_data, ARRAY[t_name.table_name], temp_json, true);
    END LOOP;
    RETURN backup_data;
END;
$$;`}
              </pre>
            </div>
          )}
        </div>

        {/* Right column: Optimization and feature switches */}
        <div className="space-y-8">
          {/* Database Backup Panel */}
          <div className="bg-white shadow-xs rounded-xl border border-gray-200 p-6 space-y-6">
            <h3 className="text-base font-bold text-gray-900 flex items-center">
              <Download className="mr-2 h-5 w-5 text-gray-500" />
              Database Backup
            </h3>
            <p className="text-xs text-gray-500 leading-relaxed">
              Export a complete data snapshot containing all tailor stores, orders, customer records, and measurements in a portable JSON format.
            </p>
            <button
              onClick={handleDownloadBackup}
              disabled={backupPending}
              className="w-full inline-flex items-center justify-center rounded-lg bg-gray-950 px-4 py-2.5 text-sm font-semibold text-white hover:bg-black transition-colors disabled:opacity-50 shadow-sm cursor-pointer"
            >
              {backupPending ? (
                <>
                  <RefreshCw className="mr-2 h-4 w-4 animate-spin" />
                  Generating Backup...
                </>
              ) : (
                <>
                  <Download className="mr-2 h-4 w-4" />
                  Download JSON Backup
                </>
              )}
            </button>
            {backupError && (
              <div className="rounded-lg bg-red-50 p-3 border border-red-200 text-xs font-semibold text-red-700">
                {backupError}
              </div>
            )}
          </div>

          {/* Database Optimization Panel */}
          <div className="bg-white shadow-xs rounded-xl border border-gray-200 p-6 space-y-6">
            <h3 className="text-base font-bold text-gray-900 flex items-center">
              <ShieldCheck className="mr-2 h-5 w-5 text-gray-500" />
              Database Optimizer
            </h3>
            <p className="text-xs text-gray-500 leading-relaxed">
              Run database diagnostics to refresh Postgres planner index weights (`ANALYZE`). This optimizes query speed for syncing customers and orders.
            </p>
            <button
              onClick={handleOptimize}
              disabled={isPending}
              className="w-full inline-flex items-center justify-center rounded-lg bg-gray-900 px-4 py-2.5 text-sm font-semibold text-white hover:bg-black transition-colors disabled:opacity-50 shadow-sm cursor-pointer"
            >
              {isPending ? (
                <>
                  <RefreshCw className="mr-2 h-4 w-4 animate-spin" />
                  Optimizing...
                </>
              ) : (
                'Run ANALYZE optimization'
              )}
            </button>
            {optimizationMessage && (
              <div className="rounded-lg bg-gray-50 p-3 border border-gray-200 text-xs font-semibold text-gray-700">
                {optimizationMessage}
              </div>
            )}
          </div>

          {/* Quick Platform Switches */}
          <div className="bg-white shadow-xs rounded-xl border border-gray-200 p-6 space-y-6">
            <h3 className="text-base font-bold text-gray-900 flex items-center">
              <Sliders className="mr-2 h-5 w-5 text-gray-500" />
              Control Panel
            </h3>
            
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-semibold text-gray-800">Self-Registration</p>
                  <p className="text-xs text-gray-400">Allow tailors to register from mobile</p>
                </div>
                <button onClick={() => setSelfReg(!selfReg)} className="text-gray-600 hover:text-gray-850 transition-all cursor-pointer">
                  {selfReg ? <ToggleRight className="h-8 w-8 text-gray-900" /> : <ToggleLeft className="h-8 w-8 text-gray-300" />}
                </button>
              </div>

              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-semibold text-gray-800">Maintenance Mode</p>
                  <p className="text-xs text-gray-400">Lock tailor access temporarily</p>
                </div>
                <button onClick={() => setMaintenance(!maintenance)} className="text-gray-600 hover:text-gray-850 transition-all cursor-pointer">
                  {maintenance ? <ToggleRight className="h-8 w-8 text-red-650" /> : <ToggleLeft className="h-8 w-8 text-gray-300" />}
                </button>
              </div>

              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-semibold text-gray-800">Daily Backup Alerts</p>
                  <p className="text-xs text-gray-400">Email super admin database dumps</p>
                </div>
                <button onClick={() => setBackups(!backups)} className="text-gray-600 hover:text-gray-855 transition-all cursor-pointer">
                  {backups ? <ToggleRight className="h-8 w-8 text-gray-900" /> : <ToggleLeft className="h-8 w-8 text-gray-300" />}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
