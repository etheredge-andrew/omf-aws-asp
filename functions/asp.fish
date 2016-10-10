function asp -d 'Switches AWS profile' -a 'aws_profile'
  if test -n "$aws_profile"
    if fgrep -q "[profile $aws_profile]" ~/.aws/config
      set -l region (awk "/\[profile\ $aws_profile\]/,/^\$/ { if (\$1 == \"region\") { print \$3 }}" ~/.aws/config)

      if test -z "$region"
        echo "No region listed for $aws_profile profile"
        return 1
      end

      set -l access_key (awk "/\[profile $aws_profile\]/,/^\$/ { if (\$1 == \"aws_access_key_id\") { print \$3 }}" ~/.aws/config)
      set -l secret_key (awk "/\[profile $aws_profile\]/,/^\$/ { if (\$1 == \"aws_secret_access_key\") { print \$3 }}" ~/.aws/config)
      set -l session_token ""

      if test -z "$access_key" -o -z "$secret_key"
        set -l role_arn (awk "/\[profile $aws_profile\]/,/^\$/ { if (\$1 == \"role_arn\") { print \$3 }}" ~/.aws/config)
        set -l source_profile (awk "/\[profile $aws_profile\]/,/^\$/ { if (\$1 == \"source_profile\") { print \$3 }}" ~/.aws/config)

        if test -n "$role_arn" -a -n "$source_profile"
          set -l json (aws sts assume-role --profile "$source_profile" --role-arn "$role_arn" --role-session-name "$aws_profile" --output json)

          set access_key (echo $json | jq -r '.Credentials.AccessKeyId')
          set secret_key (echo $json | jq -r '.Credentials.SecretAccessKey')
          set session_token (echo $json | jq -r '.Credentials.SessionToken')
        else
          echo "Invalid $aws_profile profile in ~/.aws/config"
          return 1
        end
      end

      set -gx AWS_ACCESS_KEY_ID "$access_key"
      set -gx AWS_SECRET_ACCESS_KEY "$secret_key"
      set -gx AWS_SESSION_TOKEN "$session_token"
      set -gx AWS_SECURITY_TOKEN "$AWS_SESSION_TOKEN"
      set -gx AWS_DEFAULT_REGION "$region"
      set -gx AWS_DEFAULT_PROFILE "$aws_profile"
    else
      echo "No $aws_profile profile found in ~/.aws/config"
      return 1
    end

  else
    if test -n "$AWS_DEFAULT_PROFILE"
      asp "$AWS_DEFAULT_PROFILE"
      echo "$AWS_DEFAULT_PROFILE"
    else
      echo "No profile set"
    end
  end
end
