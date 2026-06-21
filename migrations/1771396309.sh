#!/bin/bash
# Migration: Retire Fresh Editor

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Retire Fresh Editor"
echo "Fresh Editor is no longer managed by Makaron"

echo "Migration completed successfully"
