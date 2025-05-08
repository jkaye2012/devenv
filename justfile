
bt-login:
    gitpod login --host https://belvedere.gitpod.cloud
    glab auth login

bt-new-mr title team type:
    glab mr create --create-source-branch --draft --remove-source-branch --title "{{title}}" --label "team::{{team}},type::{{type}}"

bt-mr-from-issue issue:
    glab mr create --create-source-branch --draft --remove-source-branch --issue {{issue}}
