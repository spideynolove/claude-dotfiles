#!/bin/bash
set +e
CLASSIFIER=~/.claude/hooks/UserPromptSubmit/workflow-classifier.sh
pass=0; fail=0

check() {
  local label="$1" prompt="$2" expected="$3"
  local json="{\"session_id\":\"test\",\"prompt\":\"$prompt\"}"
  local got
  got=$(echo "$json" | bash "$CLASSIFIER" 2>/dev/null)
  if [[ "$got" == "$expected"* ]]; then
    echo "  PASS: $label"
    pass=$((pass + 1))
  else
    echo "  FAIL: $label — expected '$expected', got '$got'"
    fail=$((fail + 1))
  fi
}

check_empty() {
  local label="$1" prompt="$2"
  local json="{\"session_id\":\"test\",\"prompt\":\"$prompt\"}"
  local got
  got=$(echo "$json" | bash "$CLASSIFIER" 2>/dev/null)
  if [ -z "$got" ]; then
    echo "  PASS: $label (no output)"
    pass=$((pass + 1))
  else
    echo "  FAIL: $label — expected no output, got '$got'"
    fail=$((fail + 1))
  fi
}

echo "=== workflow-classifier tests ==="
check       "debug error"           "why does the auth error happen"         "[workflow:debug]"
check       "debug not working"     "login is not working after redirect"    "[workflow:debug]"
check       "debug broken"          "the pipeline is broken"                 "[workflow:debug]"
check       "plan"                  "how should i approach the new feature"  "[workflow:plan]"
check       "plan design"           "design the database schema"             "[workflow:plan]"
check       "plan scaffold"         "scaffold a new service"                 "[workflow:plan]"
check       "review"                "code review this PR"                    "[workflow:review]"
check       "review audit"          "audit the auth module"                  "[workflow:review]"
check       "review wins over impl" "check this implementation"              "[workflow:review]"
check       "impl"                  "implement the upload feature"           "[workflow:impl]"
check       "impl build"            "build the rate limiter"                 "[workflow:impl]"
check       "impl create"           "create the endpoint"                    "[workflow:impl]"
check_empty "no match greeting"     "hello how are you"
check_empty "no match file"         "read the config file"
check       "debug wins over impl"  "fix the error in the upload feature"   "[workflow:debug]"
check "plan loses to debug" "why should i design this"    "[workflow:debug]"
check "review loses to debug" "why do i need to audit"    "[workflow:debug]"
check "impl loses to review"  "review the implementation" "[workflow:review]"
check "debug trace"    "trace the request path"         "[workflow:debug]"
check "plan architect" "architect the new service"      "[workflow:plan]"
check "impl write"     "write a migration script"       "[workflow:impl]"

echo ""
echo "Results: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
