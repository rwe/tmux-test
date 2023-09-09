# shellcheck shell=bash
# This file is a symlink from 'tmux-test' plugin.
# You probably don't want to edit it.

# PRIVATE FUNCTIONS

_clone_the_plugin() {
	local plugin_path="${HOME}/.tmux/plugins/tmux-plugin-under-test/"
	rm -rf "$plugin_path"

	# Resolve symlinks to this file in the `tmux-test` repo.
	local tmux_test_helpers_script
	tmux_test_helpers_script="$(realpath "${BASH_SOURCE[0]}")"

	# Get the path of the parent repository containing `tmux-test`.
	local plugin_src_repo
	plugin_src_repo="$(git -C "$(dirname "${tmux_test_helpers_script}")" rev-parse --show-superproject-working-tree)"
	git clone --recursive "$plugin_src_repo" "$plugin_path" >/dev/null 2>&1
}

_add_plugin_to_tmux_conf() {
	set_tmux_conf_helper<<-HERE
	run-shell '~/.tmux/plugins/tmux-plugin-under-test/*.tmux'
	HERE
}

# PUBLIC HELPER FUNCTIONS

teardown_helper() {
	rm -f ~/.tmux.conf
	rm -rf ~/.tmux/
	tmux kill-server >/dev/null 2>&1
}

set_tmux_conf_helper() {
	cat > ~/.tmux.conf
}

test:ok() {
	printf 'SUCCESS\n\n'
	teardown_helper
}

test:fail() {
	printf '%s\n' "$1" >&2
	printf 'FAIL!\n\n'
	teardown_helper
	return 1
}

install_tmux_plugin_under_test_helper() {
	_clone_the_plugin
	_add_plugin_to_tmux_conf
}
