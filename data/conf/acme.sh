#!/bin/bash
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DNS_SLOWRATE=2
acme.sh --issue -d us-tls.teacher2070.com --dns dns_aws --dnssleep 30
