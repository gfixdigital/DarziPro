import { supabase } from '@/lib/supabase';
import { Building2, Activity, CreditCard, ArrowUpRight } from 'lucide-react';

export const revalidate = 0; // Fetch fresh data on every load

export default async function Dashboard() {
  const { data: shops } = await supabase
    .from('shops')
    .select('*')
    .order('created_at', { ascending: false });

  const totalShops = shops?.length || 0;
  const activeSubscriptions =
    shops?.filter(
      (s) => new Date(s.subscription_ends_at) > new Date()
    ).length || 0;
  const expiredSubscriptions = totalShops - activeSubscriptions;

  const stats = [
    { name: 'Total Shops on Platform', stat: totalShops, icon: Building2 },
    { name: 'Active Subscriptions', stat: activeSubscriptions, icon: Activity },
    { name: 'Expired Subscriptions', stat: expiredSubscriptions, icon: CreditCard },
  ];

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-gray-900">
          Global Overview
        </h1>
        <p className="mt-1 text-sm text-gray-500">
          Manage all DarziPro shops and view high-level metrics.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-3">
        {stats.map((item) => {
          const Icon = item.icon;
          return (
            <div
              key={item.name}
              className="relative overflow-hidden rounded-lg bg-white px-4 pb-12 pt-5 shadow sm:px-6 sm:pt-6 border border-gray-100"
            >
              <dt>
                <div className="absolute rounded-md bg-blue-50 p-3">
                  <Icon className="h-6 w-6 text-blue-600" aria-hidden="true" />
                </div>
                <p className="ml-16 truncate text-sm font-medium text-gray-500">
                  {item.name}
                </p>
              </dt>
              <dd className="ml-16 flex items-baseline pb-6 sm:pb-7">
                <p className="text-2xl font-semibold text-gray-900">
                  {item.stat}
                </p>
              </dd>
            </div>
          );
        })}
      </div>

      <div className="bg-white shadow rounded-lg border border-gray-100">
        <div className="border-b border-gray-200 px-4 py-5 sm:px-6 flex justify-between items-center">
          <h3 className="text-base font-semibold leading-6 text-gray-900">
            Recent Shops
          </h3>
          <button className="text-sm text-blue-600 font-medium hover:text-blue-500 flex items-center">
            View All <ArrowUpRight className="ml-1 h-4 w-4" />
          </button>
        </div>
        <ul role="list" className="divide-y divide-gray-200">
          {shops?.slice(0, 5).map((shop) => {
            const isExpired = new Date(shop.subscription_ends_at) < new Date();
            return (
              <li key={shop.id} className="px-4 py-5 sm:px-6 hover:bg-gray-50 transition-colors">
                <div className="flex items-center justify-between">
                  <div className="flex flex-col">
                    <p className="text-sm font-medium text-blue-600 truncate">
                      {shop.name}
                    </p>
                    <p className="text-sm text-gray-500 truncate mt-1">
                      {shop.owner_name} &bull; {shop.phone}
                    </p>
                  </div>
                  <div className="flex flex-col items-end">
                    <span
                      className={`inline-flex items-center rounded-md px-2.5 py-0.5 text-xs font-medium ${
                        isExpired
                          ? 'bg-red-50 text-red-700 ring-1 ring-inset ring-red-600/10'
                          : 'bg-green-50 text-green-700 ring-1 ring-inset ring-green-600/20'
                      }`}
                    >
                      {isExpired ? 'Plan Expired' : 'Active Plan'}
                    </span>
                    <p className="text-xs text-gray-500 mt-2">
                      Ends: {new Date(shop.subscription_ends_at).toLocaleDateString()}
                    </p>
                  </div>
                </div>
              </li>
            );
          })}
        </ul>
      </div>
    </div>
  );
}
