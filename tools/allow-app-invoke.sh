#!/usr/bin/env bash
# Lets the PauseAsk app reach its callable Cloud Functions when the
# multisarv.com organisation policy "Domain restricted sharing" forbids the
# usual allUsers invoker binding. It turns OFF Cloud Run's invoker IAM check
# on each app-facing function (Google's documented workaround). Every function
# still rejects unauthenticated users itself and validates its input.
#
# This bypasses the intent of an organisation security policy for this one
# project, so run it only if your organisation is OK with that. The clean
# alternative is an org admin overriding iam.allowedPolicyMemberDomains for
# project pasuse-ask.
#
# Uses the Firebase CLI login (firebase login). Re-run after a deploy if the
# app gets 403 errors again.
#
# Usage: bash tools/allow-app-invoke.sh [projectId] [region]
set -euo pipefail

PROJECT="${1:-pasuse-ask}"
REGION="${2:-asia-south1}"
SERVICES=(createcircle createinvite joincircle leavecircle removemember
  analyzecheck respondtocheck deletecheck checkin savecheckinsettings
  sendsos sendtestalert updateroles deletemyaccount healthcheck)

FT="$(npm root -g)/firebase-tools"
TOK="$(node -e '
const auth = require(process.argv[1] + "/lib/auth");
const acct = auth.getGlobalDefaultAccount();
if (!acct) { console.error("Run `firebase login` first."); process.exit(1); }
auth.getAccessToken(acct.tokens.refresh_token, [])
  .then(t => process.stdout.write(t.access_token))
  .catch(e => { console.error(e.message); process.exit(1); });
' "$FT")"

echo "Project $PROJECT ($REGION): turning off the invoker IAM check on ${#SERVICES[@]} functions"
fail=0
for s in "${SERVICES[@]}"; do
  printf "  %-22s " "$s"
  out="$(curl -s -m 60 -X PATCH \
    "https://run.googleapis.com/v2/projects/$PROJECT/locations/$REGION/services/$s?updateMask=invokerIamDisabled,template.revision" \
    -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
    -d '{"invokerIamDisabled":true,"template":{"revision":""}}')"
  if grep -q '"error"' <<<"$out"; then
    echo "ERROR: $(grep -o '"message": *"[^"]*' <<<"$out" | head -1 | cut -c13-)"
    fail=1
  else
    echo "ok"
  fi
done
[ "$fail" = 0 ] && echo "Done. Wait ~1 minute before testing the app." || exit 1
