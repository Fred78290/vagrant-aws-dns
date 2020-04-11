#!/bin/bash

vagrant plugin uninstall vagrant-aws-dns
rake build
vagrant plugin install pkg/vagrant-aws-dns-0.3.0.gem