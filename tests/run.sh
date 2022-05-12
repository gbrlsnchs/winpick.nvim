#!/bin/sh

nvim --headless -u test/minimal.vim --cmd "lua require('plenary.test_harness').test_directory('tests')"
