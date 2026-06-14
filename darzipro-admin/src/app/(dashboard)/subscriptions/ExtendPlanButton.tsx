'use client';

import { useTransition } from 'react';
import { extendPlan } from './actions';

export default function ExtendPlanButton({ shopId }: { shopId: string }) {
  const [isPending, startTransition] = useTransition();

  return (
    <button
      onClick={() => {
        startTransition(async () => {
          try {
            await extendPlan(shopId);
          } catch (error) {
            console.error(error);
            alert('Failed to extend plan.');
          }
        });
      }}
      disabled={isPending}
      className="text-blue-600 hover:text-blue-900 bg-blue-50 hover:bg-blue-100 px-3 py-1.5 rounded-md font-medium transition-colors disabled:opacity-50"
    >
      {isPending ? 'Extending...' : 'Extend 1 Year'}
    </button>
  );
}
