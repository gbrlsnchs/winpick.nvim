#!/bin/sh

nvim --headless --noplugin -u tests/minimal.vim -c "lua require(\"plenary.test_harness\").test_directory_command('tests {minimal_init = \"tests/minimal.vim\"}')"
