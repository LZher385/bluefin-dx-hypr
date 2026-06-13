#!/bin/bash
set -euxo pipefail

dnf5 install -y \
  fprintd \
  fprintd-pam
