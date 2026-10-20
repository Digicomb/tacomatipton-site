-- The site no longer names cities, so the contact form stopped sending a location.
-- Make the column optional and keep it out of the alert email.
-- Run once in the Supabase dashboard: SQL Editor -> New query -> paste -> Run.

alter table public.tt_contact_requests alter column location drop not null;

grant insert (name, email, phone, topic, address, message, source) on public.tt_contact_requests to anon, authenticated;

create or replace function public.notify_tt_contact_request()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
	api_key text;
	notify_to text;
	notify_from text;
	body_text text;
begin
	select decrypted_secret into api_key from vault.decrypted_secrets where name = 'resend_api_key';
	select decrypted_secret into notify_to from vault.decrypted_secrets where name = 'tt_contact_notify_to';
	select decrypted_secret into notify_from from vault.decrypted_secrets where name = 'tt_contact_notify_from';

	-- Not configured yet: keep the request, skip the email.
	if api_key is null or notify_to is null or notify_from is null then
		return new;
	end if;

	-- Plain text only, so nothing a visitor types can inject HTML into the email.
	body_text := concat_ws(E'\n',
		'New message from tacomatipton.com',
		'',
		'Topic:    ' || new.topic,
		'Name:     ' || new.name,
		'Email:    ' || new.email,
		'Phone:    ' || coalesce(new.phone, '(not given)'),
		'Address:  ' || coalesce(new.address, '(not given)'),
		'Sent:     ' || to_char(new.created_at at time zone 'America/New_York', 'YYYY-MM-DD HH24:MI TZ'),
		'',
		new.message,
		'',
		'-- Reply to this email to answer ' || new.name || ' directly.'
	);

	-- Asynchronous: the HTTP call runs after the insert commits and never blocks the visitor.
	perform net.http_post(
		url := 'https://api.resend.com/emails',
		headers := jsonb_build_object(
			'Authorization', 'Bearer ' || api_key,
			'Content-Type', 'application/json'
		),
		body := jsonb_build_object(
			'from', notify_from,
			'to', jsonb_build_array(notify_to),
			'reply_to', new.email,
			'subject', '[' || new.topic || '] ' || left(new.name, 80),
			'text', body_text
		)
	);

	return new;
end;
$$;

revoke all on function public.notify_tt_contact_request() from public, anon, authenticated;
