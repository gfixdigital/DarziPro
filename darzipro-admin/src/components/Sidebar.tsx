'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { LayoutDashboard, Users, CreditCard, Settings, LogOut, Scissors } from 'lucide-react';
import { supabase } from '@/lib/supabase';

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  const routes = [
    { name: 'Overview', path: '/', icon: LayoutDashboard },
    { name: 'Shops', path: '/shops', icon: Users },
    { name: 'Subscriptions', path: '/subscriptions', icon: CreditCard },
    { name: 'Settings', path: '/settings', icon: Settings },
  ];

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    document.cookie = 'admin_bypass=; path=/; max-age=0';
    router.push('/login');
    router.refresh();
  };

  return (
    <div className="flex h-screen w-64 flex-col border-r border-gray-200 bg-white">
      <div className="flex h-16 items-center px-6 border-b border-gray-100">
        <Scissors className="h-5 w-5 text-gray-900" />
        <span className="ml-3 text-sm font-semibold tracking-tight text-gray-900">
          DarziPro Admin
        </span>
      </div>

      <nav className="flex-1 space-y-1 px-3 py-6 overflow-y-auto">
        {routes.map((route) => {
          const isActive = pathname === route.path;
          const Icon = route.icon;
          return (
            <Link
              key={route.name}
              href={route.path}
              className={`flex items-center rounded-md px-3 py-2 text-sm font-medium transition-colors ${
                isActive
                  ? 'bg-gray-100 text-gray-900'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
            >
              <Icon
                className={`mr-3 h-4 w-4 flex-shrink-0 ${
                  isActive ? 'text-gray-900' : 'text-gray-400'
                }`}
              />
              {route.name}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-gray-100 p-4">
        <div className="flex items-center px-3 py-2 mb-2">
          <div className="h-8 w-8 rounded-full bg-gray-100 flex items-center justify-center text-gray-600 font-medium text-xs border border-gray-200">
            GF
          </div>
          <div className="ml-3">
            <p className="text-sm font-medium text-gray-900">GFix Admin</p>
            <p className="text-xs text-gray-500">Super User</p>
          </div>
        </div>
        <button 
          onClick={handleSignOut}
          className="flex w-full items-center rounded-md px-3 py-2 text-sm font-medium text-gray-600 transition-colors hover:bg-gray-50 hover:text-gray-900"
        >
          <LogOut className="mr-3 h-4 w-4 text-gray-400" />
          Sign Out
        </button>
      </div>
    </div>
  );
}
