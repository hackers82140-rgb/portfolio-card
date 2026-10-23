create table if not exists public.linkdrive_user_data (
    user_id uuid primary key references auth.users (id) on delete cascade,
    items jsonb not null default '[]'::jsonb
);

alter table public.linkdrive_user_data enable row level security;

revoke all on table public.linkdrive_user_data from anon, public;
grant select, insert, update on table public.linkdrive_user_data to authenticated;

drop policy if exists "Users can access their own Link Drive data" on public.linkdrive_user_data;
create policy "Users can access their own Link Drive data"
    on public.linkdrive_user_data
    for all
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

do $$
begin
    if to_regclass('public.linkdrive_data') is not null then
        execute 'revoke all on table public.linkdrive_data from anon, authenticated, public';
        execute 'drop policy if exists "Anyone can read shared Link Drive data" on public.linkdrive_data';
        execute 'drop policy if exists "Anyone can create shared Link Drive data" on public.linkdrive_data';
        execute 'drop policy if exists "Anyone can update shared Link Drive data" on public.linkdrive_data';
    end if;
end
$$;

notify pgrst, 'reload schema';
