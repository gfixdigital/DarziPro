'use server';

import { supabaseAdmin } from '@/lib/supabaseAdmin';
import { revalidatePath } from 'next/cache';

export async function extendPlan(shopId: string) {
  // Add 1 year to current date
  const newDate = new Date();
  newDate.setFullYear(newDate.getFullYear() + 1);

  const { error } = await supabaseAdmin
    .from('shops')
    .update({ subscription_ends_at: newDate.toISOString() })
    .eq('id', shopId);

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath('/');
  revalidatePath('/subscriptions');
}
