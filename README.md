# YesPanchi PQC Ticketing System — Vercel + Neon

A simple Flask ticketing portal with Customer, Partner and Admin roles. The existing Flask/Jinja interface and ticket workflow have been retained. Persistence now uses Neon PostgreSQL; uploaded files are stored as PostgreSQL `BYTEA` data so they do not depend on Vercel's temporary filesystem.

## Included

- Customer and partner registration and separate customer/partner and admin sign-in
- Customer ticket creation, tracking, replies and attachment downloads
- Partner tickets for their own account and tickets raised on behalf of customers mapped by an administrator
- Admin dashboard, ticket assignment, department selection, status updates and status history
- Public conversation replies and admin-only internal notes
- Ticket categories/subcategories based on the PQC SSL support requirements
- Priority-based starter SLA policy records (P1–P4)
- Admin management of partner-to-customer mappings
- Neon PostgreSQL persistence for users, mappings, tickets, messages, history, SLA policies and attachments

## 1. Create a Neon database

1. Create a project at [Neon](https://console.neon.tech/).
2. Open the project and select **Connect**.
3. Choose the database and role. Turn on **Connection pooling** and copy the pooled connection string.
4. Keep `sslmode=require` in the connection string. Do not share the connection string or commit it to Git.

## 2. Configure environment variables

Set these in Vercel → Project → Settings → Environment Variables:

| Variable | Value |
|---|---|
| `DATABASE_URL` | Your Neon pooled PostgreSQL connection string |
| `SECRET_KEY` | A long, random secret used to sign sessions |
| `ADMIN_EMAIL` | Email address for the first administrator |
| `ADMIN_PASSWORD` | Strong password for the first administrator |

Optional: `COOKIE_SECURE=true` (enabled automatically on Vercel). Do not use the sample values in `.env.example` for a live deployment.

Generate a secret locally with:

```bash
python -c "import secrets; print(secrets.token_urlsafe(48))"
```

The first administrator account is inserted automatically when the app first connects to Neon and both `ADMIN_EMAIL` and `ADMIN_PASSWORD` are set. If you change these variables later, the existing admin password is not overwritten. Change it through a future password-management feature or update its password hash through a secure database administration process.

## 3. Deploy to Vercel

1. Extract this ZIP.
2. Create a GitHub repository and upload the **contents** of `PQC_Ticketing_System_Fixed` to the repository root. The root must contain `app.py`, `requirements.txt`, `templates/` and `static/`.
3. Open [Vercel New Project](https://vercel.com/new), import the repository and deploy. Vercel detects the root Flask `app` automatically; no custom build command or output directory is required.
4. Add the four environment variables above for Production (and Preview if needed), then redeploy.
5. Open the deployed site and use `/admin/login` to sign in as the administrator. Customers and partners use the normal `/login` page.

## 4. Local run in VS Code (Windows)

Install Python 3.12+, create a Neon database, and create a local `.env` file by copying `.env.example`. Fill in the real values; never commit `.env`.

```powershell
py -3.12 -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python app.py
```

Open `http://127.0.0.1:5000`. You can also use `vercel dev` after installing the Vercel CLI and linking the project.

## 5. First-use setup

1. Sign in at `/admin/login` with the administrator credentials.
2. Register customer and partner accounts from the public registration page.
3. Open **Settings & mappings** in the admin navigation and map each customer to the correct partner.
4. Partners can then choose only mapped customers when raising a customer-related ticket.

## Data and deployment notes

- Neon is the persistent database. The app does not create a local SQLite database and does not write uploads to the Vercel filesystem.
- Attachments are stored in Neon as binary data, limited to 10 MB and restricted to PNG, JPG, PDF, TXT, CSV and LOG extensions. Database storage can grow; for high-volume or large attachments, move binary files to object storage later.
- Vercel's Flask deployment runs as a serverless function. The app initializes its schema on the first request of a fresh runtime; the DDL is idempotent.
- The current project is a standalone ticketing prototype. The source requirements document describes deeper integrations with an existing PQC certificate platform (live certificate/order/inventory lookup, SSO, email/SMS notifications, automated SLA breach escalation, knowledge base, diagnostics, analytics and API integration). Those require the platform APIs, operational policies and service credentials, which were not present in the supplied project. They are not simulated or represented as live integrations here.
- SLA policy seed values follow the document's proposed initial targets: P1 30-minute response / 4 working-hour resolution; P2 2 working-hour response / 8 working-hour resolution; P3 4 working-hour response / 2 working-day resolution; P4 1 working-day response / 3 working-day resolution. Working-hour calendars, pause rules and automated escalation still need an agreed operational policy and scheduled worker.

## Important security checklist before production use

- Use strong unique secrets and passwords; restrict access to Vercel and Neon projects.
- Do not upload private keys, passwords or other secret credentials as ticket attachments.
- Add CSRF protection, password reset/MFA, login rate limiting, email verification and automated backup/restore testing before exposing the portal broadly.
- Review the deployment with your organization's security team and run role/access-control and attachment tests.
