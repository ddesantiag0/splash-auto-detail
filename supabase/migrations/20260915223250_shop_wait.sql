-- Public status contains no customer or owner identity data.
create table public.shop_owners (
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.shop_owners enable row level security;
revoke all on public.shop_owners from anon, authenticated;
grant select on public.shop_owners to authenticated;
create policy owner_reads_self on public.shop_owners for select to authenticated
  using (user_id = (select auth.uid()));

create table public.shop_wait (
  id integer primary key check (id = 1),
  status text not null check (status in ('available','moderate','busy','closed')),
  wait_min integer,
  wait_max integer,
  valid_minutes integer not null default 30 check (valid_minutes in (15,30,60)),
  updated_at timestamptz not null default now(),
  expires_at timestamptz not null default now(),
  version bigint not null default 1,
  check ((status = 'closed' and wait_min is null and wait_max is null) or
    (status <> 'closed' and wait_min is not null and wait_max is not null and wait_min >= 0 and wait_max >= wait_min and wait_max <= 240))
);
alter table public.shop_wait enable row level security;
revoke all on public.shop_wait from anon, authenticated;
grant select on public.shop_wait to anon, authenticated;
grant update (status, wait_min, wait_max, valid_minutes) on public.shop_wait to authenticated;
create policy public_reads_wait on public.shop_wait for select to anon, authenticated using (true);
create policy owners_update_wait on public.shop_wait for update to authenticated
  using (exists(select 1 from public.shop_owners where user_id = (select auth.uid())))
  with check (exists(select 1 from public.shop_owners where user_id = (select auth.uid())));

create function public.stamp_shop_wait() returns trigger
language plpgsql security invoker set search_path = '' as $$
begin
  new.updated_at := statement_timestamp();
  new.expires_at := new.updated_at + make_interval(mins => new.valid_minutes);
  new.version := old.version + 1;
  return new;
end;
$$;
revoke all on function public.stamp_shop_wait() from public;
create trigger stamp_shop_wait before update on public.shop_wait
  for each row execute function public.stamp_shop_wait();

-- Seed deliberately expired: never invent a current green status.
insert into public.shop_wait(id,status,wait_min,wait_max) values (1,'closed',null,null);
create function public.read_shop_wait() returns jsonb
language sql stable security invoker set search_path = '' as $$
  select jsonb_build_object('server_now', now(), 'status', (select to_jsonb(w) from public.shop_wait w where id=1));
$$;
revoke all on function public.read_shop_wait() from public;
grant execute on function public.read_shop_wait() to anon, authenticated;
alter publication supabase_realtime add table public.shop_wait;
