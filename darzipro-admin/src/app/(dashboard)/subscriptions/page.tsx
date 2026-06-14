import { supabaseAdmin } from '@/lib/supabaseAdmin';
import { CreditCard, ShieldAlert } from 'lucide-react';
import ExtendPlanButton from './ExtendPlanButton';

export const revalidate = 0;

export default async function SubscriptionsPage() {
  const { data: dbShops } = await supabaseAdmin
    .from('shops')
    .select('*')
    .order('subscription_ends_at', { ascending: true });

  const shops = dbShops || [];

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      <div>
        <h1 className="text-2xl font-semibold text-gray-900 flex items-center">
          <CreditCard className="mr-3 h-6 w-6 text-gray-500" />
          Subscription Management
        </h1>
        <p className="mt-1 text-sm text-gray-500">
          Monitor and extend SaaS plans for all tailors.
        </p>
      </div>

      {shops.length === 0 ? (
        <div className="text-center py-16 bg-white border border-gray-200 rounded-xl shadow-sm">
          <CreditCard className="mx-auto h-12 w-12 text-gray-300" />
          <h3 className="mt-2 text-sm font-semibold text-gray-900">No subscriptions found</h3>
          <p className="mt-1 text-sm text-gray-500">
            Create a shop under the "Shops" tab or check if SUPABASE_SERVICE_ROLE_KEY is set in your .env.local.
          </p>
        </div>
      ) : (
        <div className="bg-white shadow-sm rounded-xl border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th scope="col" className="py-4 pl-6 pr-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Shop Name</th>
                  <th scope="col" className="px-3 py-4 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Status</th>
                  <th scope="col" className="px-3 py-4 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Expiration Date</th>
                  <th scope="col" className="relative py-4 pl-3 pr-6 text-right">
                    <span className="sr-only">Extend</span>
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 bg-white">
                {shops.map((shop) => {
                  const isExpired = new Date(shop.subscription_ends_at) < new Date();
                  const isPaused = new Date(shop.subscription_ends_at) < new Date(10000);
                  return (
                    <tr key={shop.id} className="hover:bg-gray-50/50 transition-colors">
                      <td className="whitespace-nowrap py-4 pl-6 pr-3 text-sm font-semibold text-gray-900">
                        {shop.name}
                      </td>
                      <td className="whitespace-nowrap px-3 py-4 text-sm">
                        <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${isExpired ? 'bg-red-50 text-red-800 border border-red-200' : 'bg-green-50 text-green-800 border border-green-200'}`}>
                          {isPaused ? 'Paused' : isExpired ? 'Expired' : 'Active'}
                        </span>
                      </td>
                      <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-600 font-medium">
                        {isPaused ? 'Paused / Locked' : new Date(shop.subscription_ends_at).toLocaleDateString()}
                      </td>
                      <td className="relative whitespace-nowrap py-4 pl-3 pr-6 text-right text-sm font-medium">
                        <ExtendPlanButton shopId={shop.id} />
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
