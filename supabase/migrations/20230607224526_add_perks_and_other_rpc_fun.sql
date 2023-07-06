create table "public"."perks" (
    "id" bigint generated by default as identity not null,
    "created_at" date not null default now(),
    "giver" uuid,
    "receiver" uuid,
    "amount" bigint not null,
    "reason" text not null
);


alter table "public"."perks" enable row level security;

alter table "public"."apps" add column "role_access" text[];

alter table "public"."time_entries" alter column "approval_status" set default '0'::smallint;

CREATE UNIQUE INDEX perks_pkey ON public.perks USING btree (id);

alter table "public"."perks" add constraint "perks_pkey" PRIMARY KEY using index "perks_pkey";

alter table "public"."perks" add constraint "perks_giver_fkey" FOREIGN KEY (giver) REFERENCES employees(id) ON DELETE SET NULL not valid;

alter table "public"."perks" validate constraint "perks_giver_fkey";

alter table "public"."perks" add constraint "perks_receiver_fkey" FOREIGN KEY (receiver) REFERENCES employees(id) ON DELETE SET NULL not valid;

alter table "public"."perks" validate constraint "perks_receiver_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_perks_event()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
giver RECORD;
receiver RECORD;
BEGIN
  SELECT * INTO STRICT giver FROM employees WHERE employees.id = NEW.giver;
  SELECT * INTO STRICT receiver FROM employees WHERE employees.id = NEW.receiver;
  
  INSERT INTO events (fk, type, description, user_id)
  VALUES (NEW.id, 'perks',  'Perk received from ' || giver.first_name, receiver.id);
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_apps(employee_id uuid)
 RETURNS SETOF apps
 LANGUAGE plpgsql
AS $function$
DECLARE
user_role text;
BEGIN
  SELECT role INTO STRICT user_role FROM employees where employees.id = employee_id;
  RETURN QUERY EXECUTE 'SELECT * FROM apps WHERE ''' ||  user_role || ''' = ANY(apps.role_access);';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_perks()
 RETURNS SETOF perks
 LANGUAGE sql
AS $function$
    select * from perks;
$function$
;

CREATE OR REPLACE FUNCTION public.insert_customer(requester_id uuid, customer_name text)
 RETURNS customer
 LANGUAGE plpgsql
AS $function$
DECLARE
result record;
BEGIN
  INSERT INTO customer (salesperson, name)
  VALUES (requester_id, customer_name)
  RETURNING * INTO result;
  RETURN result;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.insert_perk(giver_id uuid, receiver_id uuid, gift_amount bigint, gift_reason text)
 RETURNS perks
 LANGUAGE plpgsql
AS $function$
DECLARE
result record;
BEGIN
  INSERT INTO perks (giver, receiver, amount, reason)
  VALUES (giver_id, receiver_id, gift_amount, gift_reason)
  RETURNING * INTO result;
  RETURN result;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.insert_pto_request(requester_id uuid, request_start_date date, request_end_date date, request_type text)
 RETURNS pto_requests
 LANGUAGE plpgsql
AS $function$
DECLARE
manager_id uuid;
result record;
BEGIN
  SELECT manager INTO STRICT manager_id FROM employees WHERE employees.id = requester_id;
  INSERT INTO pto_requests (start_date, end_date, approver, requester, type)
  VALUES (request_start_date, request_end_date, manager_id, requester_id, request_type)
  RETURNING * INTO result;
  RETURN result;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.insert_timesheet_request(requester_id uuid, customer_id bigint, timesheet_date date, timesheet_start_time time without time zone, timesheet_end_time time without time zone)
 RETURNS time_entries
 LANGUAGE plpgsql
AS $function$
DECLARE
manager_id uuid;
result record;
BEGIN
  SELECT manager INTO STRICT manager_id FROM employees WHERE employees.id = requester_id;
  INSERT INTO time_entries (contractor, customer, date, start_time, end_time, approver)
  VALUES (requester_id, customer_id, timesheet_date, timesheet_start_time, timesheet_end_time, manager_id)
  RETURNING * INTO result;
  RETURN result;
END;
$function$
;

CREATE TRIGGER perks_trigger AFTER INSERT ON public.perks FOR EACH ROW EXECUTE FUNCTION create_perks_event();
