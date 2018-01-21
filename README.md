# Script for Twitch DevOps Tech Challenge

Simply run the script with a numeric PR number argument, e.g. `pr_helper.rb 1`

The script will prompt for login credentials to use.

Once the credentials are provided, it will run the lint, test, and build steps for the other project and comment on the PR.

The script does diverge from the instructions in a minor way: it will perform the test on a merge of the changes with the
branch it the PR is requesting to merge to, whether that be master or some other branch.
