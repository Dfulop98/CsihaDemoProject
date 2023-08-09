#!/bin/bash

EMAIL_TO="$1"
SUBJECT="$2"
BODY="$3"
SENDER_EMAIL="$4"
SENDER_NAME="$5"
SENDGRID_API_KEY="$6"
base64_content_build="$7"
base64_content_test="$8"

# Initialize the json data without attachments
jsonData=$(jq -n \
    --arg subj "$SUBJECT" \
    --arg to "$EMAIL_TO" \
    --arg sender_email "$SENDER_EMAIL" \
    --arg sender_name "$SENDER_NAME" \
    --arg body "$BODY" \
    '{
        "personalizations": [
            {
                "to": [
                    {
                        "email": $to
                    }
                ],
                "subject": $subj
            }
        ],
        "from": {
            "email": $sender_email,
            "name": $sender_name
        },
        "content": [
            {
                "type": "text/plain",
                "value": $body
            }
        ]
    }'
)

# Add attachments if provided
if [ -n "$base64_content_build" ]; then
    jsonData=$(echo "$jsonData" | jq \
        --arg content "$(base64 <<< "$base64_content_build")" \
        --arg filename "build.log" \
        '.attachments += [ { "content": $content, "filename": $filename, "type": "text/plain", "disposition": "attachment" } ]'
    )
fi

if [ -n "$base64_content_test" ]; then
    jsonData=$(echo "$jsonData" | jq \
        --arg content "$(base64 <<< "$base64_content_test")" \
        --arg filename "test.log" \
        '.attachments += [ { "content": $content, "filename": $filename, "type": "text/plain", "disposition": "attachment" } ]'
    )
fi


# Send notification using SendGrid API
curl -s --verbose POST \
  --url https://api.sendgrid.com/v3/mail/send \
  --header "Authorization: Bearer $SENDGRID_API_KEY" \
  --header 'Content-Type: application/json' \
  --data "$jsonData"
