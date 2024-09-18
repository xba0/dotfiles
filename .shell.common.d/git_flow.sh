function trace_exec() {
  if [ $GIT_FLOW_TRACE ]; then echo $@; fi
  $@
}

function flow() {
  local command="$1"
  if [ -z "$command" ]; then
    flow-usage
    return 1
  fi
  shift

  if [ "${command}" = "base" ]; then
    flow-base "$@"
  elif [ "${command}" = "branch" ]; then
    flow-new-branch $@
  elif [ "${command}" = "fix" ]; then
    flow-new-branch fix-$1
  elif [ "${command}" = "feat" ]; then
    flow-new-branch feat-$1
  elif [ "${command}" = "neat" ]; then
    flow-new-branch neat-$1
  elif [ "${command}" = "cr" ]; then
    flow-cr
  elif [ "${command}" = "list" ]; then
    flow-list
  elif [ "${command}" = "help" ]; then
    flow-usage
  else
    echo "unrecognized command ${command}"
    flow-usage
    return 1
  fi
}

function flow-usage() {
  echo "usage: flow [base | cr | list | help | branch | fix | feat | neat]"
}

function flow-base() {
  local branch_path=$(git config --get branch.$(git branch --show-current).merge)
  local remote_branch_name=${branch_path##*/}

  trace_exec git checkout $remote_branch_name
}

# create and checkout to a new feature branch
function flow-new-branch() {
  local new_branch=$1
  if [ -z "${new_branch}" ]; then echo "please specify the name" && return 1; fi

  local remote=$(git config --get branch.$(git branch --show-current).remote)
  local branch_path=$(git config --get branch.$(git branch --show-current).merge)
  local remote_branch_name=${branch_path##*/}

  if [ -z "${remote}" ]; then echo "empty remote" && return 1; fi
  if [ -z "${remote_branch_name}" ]; then echo "empty branch name" && return 1; fi
  if [ -z "${new_branch}" ]; then echo "empty branch name" && return 1; fi

  trace_exec git checkout -b $new_branch ${remote}/$remote_branch_name
  trace_exec git config --local branch.${new_branch}.remote $remote_repo
  trace_exec git config --local branch.${new_branch}.merge $branch_path
}

# push current branch to gerrit
function flow-cr() {
  local remote=$(git config --get branch.$(git branch --show-current).remote)
  local branch_path=$(git config --get branch.$(git branch --show-current).merge)
  local remote_branch_name=${branch_path##*/}

  if [ -z "${remote}" ]; then echo "empty remote" && return 1; fi
  if [ -z "${remote_branch_name}" ]; then echo "empty branch name" && return 1; fi

  trace_exec git push $remote HEAD:refs/for/${remote_branch_name}
}

function flow-list() {
  trace_exec git for-each-ref --sort=-committerdate refs/heads/ --format="%(committerdate:short) %(refname:short)"
}
