function asp -d 'Switches AWS profile' -a 'asp_profile'
    set -x CONFIG_FILE ~/.aws/config
    set -x CREDENTIAL_FILE ~/.aws/credentials

    if test asp_profile != "$aws_profile"
        if fgrep -q "[profile $aws_profile]" $CONFIG_FILE
            echo Setting aws_profile to $asp_profile
            set -gx aws_profile $asp_profile
        else
            echo "Could NOT find profile $aws_profile in config file ($CONFIG_FILE). No profile set"
        end
    end
end
