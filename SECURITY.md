# Authentication and access control

The site uses Firebase Authentication and Cloud Firestore. Browser checks improve the user experience, but `firestore.rules` is the security boundary.

## One-time Firebase setup

1. In Firestore, create `admins/<firebase-auth-uid>` for each administrator:

   ```json
   { "active": true, "email": "administrator@example.org" }
   ```

   The document ID must be that administrator's Firebase Authentication UID, and the email must exactly match their verified Firebase email. Admin documents cannot be created or changed by the website.

2. Deploy the rules from the repository root:

   ```bash
   firebase use mbciu-auth
   firebase deploy --only firestore:rules
   ```

3. Existing records in Realtime Database are not used by the hardened pages. Re-create or migrate them to Firestore collection `users`, keyed by Firebase Authentication UID, with this shape:

   ```json
   { "email": "user@example.org", "approved": false, "tools": {} }
   ```

4. Enable only the required Firebase Authentication providers and restrict authorized domains to the production MBCIU domain and any explicitly required development domain.

5. In EmailJS, restrict the public key to the production MBCIU origin. The `template_signup_alert` template receives only `email`, `tool`, and `request_type`; configure its recipient as the fixed administrator address rather than accepting a recipient from the browser.

## Security properties

- New users can create only their own pending profile.
- Users cannot approve themselves or grant themselves tool access.
- Verified, approved users can read only their own profile.
- Only administrators listed in the locked `admins` collection can list users or change approvals.
- Unknown collections are denied by default.
- Tool identifiers are allow-listed.

## GitHub Pages limitation

GitHub Pages is public static hosting. Authentication can protect Firestore data, but it cannot make an HTML file or other asset in this public repository private. Do not commit confidential data or restricted tool content here. Host genuinely restricted content behind a server or storage service that validates Firebase ID tokens on every request.
