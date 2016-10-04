#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright 2015, Nicolas Landais (@nlandais) <nicolas.landais@citrix.com>
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

DOCUMENTATION = '''
---
module: win_certificate
version_added: "2.0"
short_description: Installs a PFX certificate
description:
    - Installs the contents of a PFX package in the selected certificate store
options:
  pfx_file:
    description:
      - Local path to the pfx file to be installed (ie C:\\tmp\\certificate.pfx)
    required: true
    default: null
    aliases: []
  password:
    description:
      - Password used to extract the certificate and key from the PFX file
    required: true
    default: null
    aliases: []  
  state:
    description:
      - State of the package on the system
    required: false
    choices:
      - present
      - absent
    default: present
    aliases: []
  location:
    description:
      - Certificate root store
    required: false
    choices:
      - CurrentUser
      - LocalMachine
    default: CurrentUser
    aliases: []
  store_name:
    description:
      - Name of the store where the certificate will be installed
    required: false
    default: MY
    aliases: []
author: "Nicolas Landais (@nlandais)"
'''

EXAMPLES = '''
  # Install xzf.pfx in the CurrentUser\MY certificate store
  win_certificate:
    pfx_file: 'C:\\tmp\\xzy.pfx'
    password: 'qwert123#'
  # Remove xzy.pfx from the LocalMachine\Remote Desktop certificate store
  win_certificate:
    pfx_file: 'C:\\tmp\\xzy.pfx'
    password: 'qwert123#'
    state: absent
    location: LocalMachine
    store_name: 'Remote Desktop'
'''