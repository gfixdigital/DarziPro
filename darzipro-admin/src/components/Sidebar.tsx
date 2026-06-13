'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { LayoutDashboard, Users, CreditCard, Settings, LogOut, Scissors } from 'lucide-react';

export default function Sidebar() {
  const pathname = usePathname();

  const routes = [
    { name: 'Overview', path: '/', icon: LayoutDashboard },
    { name: 'Shops', path: '/shops', icon: Users },
    { name: 'Subscriptions', path: '/subscriptions', icon: CreditCard },
    { name: 'Platform Settings', path: '/settings', icon: Settings },
  ];

  return (
    <div className="flex h-screen w-64 flex-col border-r border-gray-200 bg-white">
      <div className="flex h-16 items-center px-6 border-b border-gray-100">
        <Scissors className="h-6 w-6 text-blue-600" />
        <span className="ml-3 text-lg font-bold tracking-tight text-gray-900">
          DarziPro Admin
        </span>
      </div>

      <nav className="flex-1 space-y-1 px-4 py-6">
        {routes.map((route) => {
          const isActive = pathname === route.path;
          const Icon = route.icon;
          return (
            <Link
              key={route.name}
              href={route.path}
              className={`flex items-center rounded-md px-3 py-2 text-sm font-medium transition-colors ${
                isActive
                  ? 'bg-blue-50 text-blue-700'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
            >
              <Icon
                className={`mr-3 h-5 w-5 flex-shrink-0 ${
                  isActive ? 'text-blue-700' : 'text-gray-400'
                }`}
              />
              {route.name}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-gray-200 p-4">
        <button className="flex w-full items-center rounded-md px-3 py-2 text-sm font-medium text-gray-600 transition-colors hover:bg-red-50 hover:text-red-700">
          <LogOut className="mr-3 h-5 w-5 text-gray-400" />
          Sign Out
        </button>
      </div>
    </div>
  );
}
