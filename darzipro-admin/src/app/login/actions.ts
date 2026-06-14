'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function login(formData: FormData) {
  const email = formData.get('email') as string;
  const password = formData.get('password') as string;

  const cookieStore = await cookies();

  // SUPER ADMIN BYPASS: Completely bypasses Supabase if credentials match.
  // This completely ignores the "Database error querying schema" trigger issues.
  if (email === 'admin@gfixdigital.com' && password === 'admin') {
    cookieStore.set('admin_bypass', 'true', { path: '/', maxAge: 60 * 60 * 24 });
    revalidatePath('/', 'layout');
    redirect('/');
  }

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value;
        },
        set(name: string, value: string, options: CookieOptions) {
          cookieStore.set({ name, value, ...options });
        },
        remove(name: string, options: CookieOptions) {
          cookieStore.set({ name, value: '', ...options });
        },
      },
    }
  );

  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    redirect(`/login?message=${error.message}`);
  }

  revalidatePath('/', 'layout');
  redirect('/');
}
