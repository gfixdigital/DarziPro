'use server';

import { supabaseAdmin } from '@/lib/supabaseAdmin';
import { revalidatePath } from 'next/cache';

export async function addShop(formData: FormData) {
  const name = formData.get('name') as string;
  const owner_name = formData.get('owner_name') as string;
  const phone = formData.get('phone') as string;
  const password = formData.get('password') as string;
  const planYears = parseInt(formData.get('plan_years') as string || '1', 10);

  // Normalize phone number to match the Flutter app's E.164 formatting (+923XXXXXXXXX)
  let formattedPhone = phone.trim().replace(/[\s\-]/g, '');
  if (formattedPhone.startsWith('+')) {
    formattedPhone = formattedPhone.substring(1);
  }
  if (formattedPhone.startsWith('92') && formattedPhone.length > 10) {
    formattedPhone = formattedPhone.substring(2);
  }
  if (formattedPhone.startsWith('0')) {
    formattedPhone = formattedPhone.substring(1);
  }
  formattedPhone = `+92${formattedPhone}`;

  const subscriptionEndsAt = new Date();
  subscriptionEndsAt.setFullYear(subscriptionEndsAt.getFullYear() + planYears);

  // 1. Create the user account in Supabase Auth first
  const { data: userData, error: authError } = await supabaseAdmin.auth.admin.createUser({
    phone: formattedPhone,
    password: password,
    phone_confirm: true,
  });

  if (authError) {
    throw new Error(`Auth account creation failed: ${authError.message}`);
  }

  // 2. Insert the shop record and store the auth_user_id (if the column exists)
  const shopData: any = {
    name,
    owner_name,
    phone: formattedPhone,
    subscription_ends_at: subscriptionEndsAt.toISOString(),
    created_at: new Date().toISOString(),
  };

  // Safely attempt to add auth_user_id to the payload
  if (userData?.user?.id) {
    shopData.auth_user_id = userData.user.id;
  }

  const { data: shop, error: shopError } = await supabaseAdmin
    .from('shops')
    .insert(shopData)
    .select()
    .single();

  if (shopError) {
    // Cleanup the auth user if shop insertion fails
    if (userData?.user?.id) {
      await supabaseAdmin.auth.admin.deleteUser(userData.user.id);
    }
    throw new Error(`Shop registration failed: ${shopError.message}`);
  }

  // 3. Update the user metadata with the created shop_id
  if (userData?.user?.id && shop?.id) {
    await supabaseAdmin.auth.admin.updateUserById(userData.user.id, {
      user_metadata: {
        shop_id: shop.id,
        shop_name: name,
        owner_name: owner_name,
      },
    });
  }

  revalidatePath('/');
  revalidatePath('/shops');
  revalidatePath('/subscriptions');
}

export async function updateShop(shopId: string, formData: FormData) {
  const name = formData.get('name') as string;
  const owner_name = formData.get('owner_name') as string;
  const phone = formData.get('phone') as string;
  const password = formData.get('password') as string; // Optional new password

  // Normalize phone number to match the Flutter app's E.164 formatting (+923XXXXXXXXX)
  let formattedPhone = phone.trim().replace(/[\s\-]/g, '');
  if (formattedPhone.startsWith('+')) {
    formattedPhone = formattedPhone.substring(1);
  }
  if (formattedPhone.startsWith('92') && formattedPhone.length > 10) {
    formattedPhone = formattedPhone.substring(2);
  }
  if (formattedPhone.startsWith('0')) {
    formattedPhone = formattedPhone.substring(1);
  }
  formattedPhone = `+92${formattedPhone}`;

  // 1. Fetch the existing shop details
  const { data: oldShop, error: fetchError } = await supabaseAdmin
    .from('shops')
    .select('*')
    .eq('id', shopId)
    .single();

  if (fetchError || !oldShop) {
    throw new Error(`Failed to retrieve existing shop: ${fetchError?.message || 'Shop not found'}`);
  }

  // 2. Update the shop record in database
  const { error: shopError } = await supabaseAdmin
    .from('shops')
    .update({
      name,
      owner_name,
      phone: formattedPhone,
    })
    .eq('id', shopId);

  if (shopError) {
    throw new Error(shopError.message);
  }

  // 3. Find/Update the Auth User using auth_user_id directly
  let authUserId = oldShop.auth_user_id;

  if (authUserId) {
    const updatePayload: any = {
      phone: formattedPhone,
      user_metadata: {
        shop_id: shopId,
        shop_name: name,
        owner_name: owner_name,
      },
    };

    if (password && password.trim().length >= 6) {
      updatePayload.password = password;
    }

    const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
      authUserId,
      updatePayload
    );

    if (updateError) {
      throw new Error(`Failed to update Auth credentials: ${updateError.message}`);
    }
  } else {
    // Fallback: If no auth_user_id exists, create a new one
    if (!password || password.trim().length < 6) {
      throw new Error('No login account exists for this shop. You must provide a password (minimum 6 characters) to create one.');
    }

    const { data: newUserData, error: createError } = await supabaseAdmin.auth.admin.createUser({
      phone: formattedPhone,
      password: password,
      user_metadata: {
        shop_id: shopId,
        shop_name: name,
        owner_name: owner_name,
      },
      phone_confirm: true,
    });

    if (createError) {
      throw new Error(`Failed to create Auth account: ${createError.message}`);
    }

    // Update the shop record with the newly created auth_user_id
    if (newUserData?.user?.id) {
      await supabaseAdmin
        .from('shops')
        .update({ auth_user_id: newUserData.user.id })
        .eq('id', shopId);
    }
  }

  revalidatePath('/');
  revalidatePath('/shops');
  revalidatePath('/subscriptions');
}

export async function deleteShop(shopId: string) {
  // Get shop details to find and delete the Auth user
  const { data: shop } = await supabaseAdmin
    .from('shops')
    .select('auth_user_id')
    .eq('id', shopId)
    .single();

  // Delete from Auth if linked
  if (shop?.auth_user_id) {
    await supabaseAdmin.auth.admin.deleteUser(shop.auth_user_id);
  }

  const { error } = await supabaseAdmin.from('shops').delete().eq('id', shopId);

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath('/');
  revalidatePath('/shops');
  revalidatePath('/subscriptions');
}

export async function togglePauseShop(shopId: string, isCurrentlyPaused: boolean) {
  let subscriptionEndsAt: string;

  if (isCurrentlyPaused) {
    // Unpause: Set to 1 year in the future
    const futureDate = new Date();
    futureDate.setFullYear(futureDate.getFullYear() + 1);
    subscriptionEndsAt = futureDate.toISOString();
  } else {
    // Pause: Set to Unix epoch (past date)
    subscriptionEndsAt = new Date(0).toISOString();
  }

  const { error } = await supabaseAdmin
    .from('shops')
    .update({ subscription_ends_at: subscriptionEndsAt })
    .eq('id', shopId);

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath('/');
  revalidatePath('/shops');
  revalidatePath('/subscriptions');
}
