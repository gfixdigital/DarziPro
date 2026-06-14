import { supabaseAdmin } from '@/lib/supabaseAdmin';
import ShopsListClient from './ShopsListClient';

export const revalidate = 0;

export default async function ShopsPage() {
  const { data: dbShops } = await supabaseAdmin
    .from('shops')
    .select('*')
    .order('created_at', { ascending: false });

  // Map database data safely matching expected types
  const shops = (dbShops || []).map((shop: any) => ({
    id: shop.id,
    name: shop.name || 'Unnamed Shop',
    owner_name: shop.owner_name || 'N/A',
    phone: shop.phone || 'N/A',
    subscription_ends_at: shop.subscription_ends_at || new Date(0).toISOString(),
    created_at: shop.created_at,
  }));

  return (
    <div className="max-w-7xl mx-auto">
      <ShopsListClient initialShops={shops} />
    </div>
  );
}
